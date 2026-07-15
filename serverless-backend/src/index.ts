import { genkit, z } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import express from 'express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Initialize Genkit leveraging Google AI Studio (Free Tier)
const ai = genkit({
  plugins: [googleAI()],
});

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const payloadPath = path.join(__dirname, '../knowledge_payload.json');

// Structured logging helper following Google Cloud Logging format
function logStructured(
  severity: 'INFO' | 'WARNING' | 'ERROR',
  message: string,
  payload?: Record<string, any>
) {
  console.log(
    JSON.stringify({
      severity,
      message,
      time: new Date().toISOString(),
      ...payload,
    })
  );
}

// Helper to retrieve grounded lore context based on user prompt keywords
function retrieveContext(
  prompt: string,
  characterClass?: string,
  limit: number = 3,
  requestId?: string
): { contextText: string; retrievedCount: number; metadata: any[] } {
  try {
    const startTime = Date.now();
    logStructured('INFO', `RAG: Starting retrieval for prompt: "${prompt}"`, {
      requestId,
      characterClass,
    });

    if (!fs.existsSync(payloadPath)) {
      logStructured('WARNING', `RAG: File not found at ${payloadPath}. Ingestion required.`, {
        requestId,
      });
      return { contextText: '', retrievedCount: 0, metadata: [] };
    }

    const rawData = fs.readFileSync(payloadPath, 'utf8');
    const knowledgeBase = JSON.parse(rawData);

    if (!Array.isArray(knowledgeBase) || knowledgeBase.length === 0) {
      logStructured('WARNING', 'RAG: Knowledge base is empty.', { requestId });
      return { contextText: '', retrievedCount: 0, metadata: [] };
    }

    // Strip punctuation and split into lowercase words
    const cleanPrompt = prompt.toLowerCase().replace(/[^\w\s]/g, ' ');
    const promptWords = cleanPrompt.split(/\s+/).filter((w) => w.length > 2);
    if (characterClass) {
      promptWords.push(characterClass.toLowerCase());
    }

    const scoredChunks = knowledgeBase.map((chunk) => {
      let score = 0;
      const text = `${chunk.text_content} ${chunk.title} ${(chunk.tags || []).join(' ')}`.toLowerCase();
      promptWords.forEach((word) => {
        if (text.includes(word)) {
          score += 1;
        }
      });
      return { chunk, score };
    });

    // Filter out chunks with 0 score, sort by score descending, and take the top limit
    const relevantChunks = scoredChunks
      .filter((item) => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);

    const durationMs = Date.now() - startTime;
    const metadata = relevantChunks.map((item) => ({
      title: item.chunk.title,
      parent_uid: item.chunk.parent_uid,
      score: item.score,
    }));

    logStructured('INFO', `RAG: Completed retrieval in ${durationMs}ms`, {
      requestId,
      retrievedCount: relevantChunks.length,
      durationMs,
      chunks: metadata,
    });

    const contextText = relevantChunks
      .map((item) => `[Source: ${item.chunk.title} (${item.chunk.parent_uid})]\n${item.chunk.text_content}`)
      .join('\n\n');

    return {
      contextText,
      retrievedCount: relevantChunks.length,
      metadata,
    };
  } catch (error: any) {
    logStructured('ERROR', 'RAG: Exception occurred during local RAG retrieval', {
      requestId,
      error: error.message,
      stack: error.stack,
    });
    return { contextText: '', retrievedCount: 0, metadata: [] };
  }
}

const app = express();
app.use(express.json());

// Express middleware for logging incoming requests and outgoing responses
app.use((req, res, next) => {
  const requestId =
    (req.headers['x-request-id'] as string) ||
    Math.random().toString(36).substring(2, 11);
  const startTime = Date.now();

  logStructured('INFO', `HTTP: ${req.method} ${req.url} received`, {
    requestId,
    method: req.method,
    url: req.url,
    userAgent: req.headers['user-agent'],
  });

  res.on('finish', () => {
    const durationMs = Date.now() - startTime;
    logStructured('INFO', `HTTP: ${req.method} ${req.url} completed`, {
      requestId,
      statusCode: res.statusCode,
      durationMs,
    });
  });

  // Inject requestId into request body to propagate into flow
  if (req.body && typeof req.body === 'object') {
    req.body.requestId = requestId;
  }

  next();
});

// Core Game Master Inference Flow
export const gameMasterFlow = ai.defineFlow(
  {
    name: 'gameMasterFlow',
    inputSchema: z.object({
      prompt: z.string(),
      characterClass: z.string().optional(),
      requestId: z.string().optional(),
    }),
    outputSchema: z.string(),
  },
  async (input) => {
    const flowStartTime = Date.now();
    
    // Perform local retrieval
    const { contextText } = retrieveContext(
      input.prompt,
      input.characterClass,
      3,
      input.requestId
    );

    const systemInstruction = `You are the AI Game Master for The Remainder Portal. 
Your goal is to guide the player through their narrative journey in this post-collapse digital landscape.

Here is the relevant game lore and context retrieved for this session:
${contextText || 'No specific lore found for this query. Use general setting details.'}

Format guidelines:
- Remain immersive, descriptive, and aligned with the game's atmosphere (cyberpunk/high fantasy hybrid).
- Reflect the player's character class: ${input.characterClass || 'Wanderer'}.
- End your responses by giving the player options or asking what they want to do next.`;

    logStructured('INFO', 'LLM: Requesting generation from Gemini 2.5 Flash', {
      requestId: input.requestId,
      promptLength: input.prompt.length,
      hasContext: contextText.length > 0,
    });

    const geminiStartTime = Date.now();
    const response = await ai.generate({
      model: 'googleai/gemini-2.5-flash',
      messages: [
        { role: 'system', content: [{ text: systemInstruction }] },
        { role: 'user', content: [{ text: input.prompt }] },
      ],
    });
    const geminiDurationMs = Date.now() - geminiStartTime;
    const totalDurationMs = Date.now() - flowStartTime;

    logStructured('INFO', 'LLM: Response generated successfully', {
      requestId: input.requestId,
      geminiDurationMs,
      totalDurationMs,
      responseLength: response.text.length,
    });

    return response.text;
  }
);

// Expose standard REST endpoint for our scale-to-zero Cloud Run container
app.post('/api/gm', async (req, res) => {
  try {
    const result = await gameMasterFlow(req.body);
    res.json({ response: result });
  } catch (error: any) {
    logStructured('ERROR', 'API: Failed to generate response', {
      requestId: req.body?.requestId,
      error: error.message,
      stack: error.stack,
    });
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  logStructured('INFO', `Remainder Portal Serverless Engine live on port ${PORT}`);
});


