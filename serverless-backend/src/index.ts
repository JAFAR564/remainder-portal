import { genkit, z } from 'genkit';
import { googleAI } from '@genkit-ai/google-genai';
import express from 'express';
import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

// Initialize Genkit leveraging Google AI Studio (Free Tier)
const ai = genkit({
  plugins: [googleAI()],
  logLevel: 'debug',
});

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);
const payloadPath = path.join(__dirname, '../knowledge_payload.json');

// Helper to retrieve grounded lore context based on user prompt keywords
function retrieveContext(prompt: string, characterClass?: string, limit: number = 3): string {
  try {
    console.log(`🔍 RAG: Retrieving context for prompt: "${prompt}"`);
    if (!fs.existsSync(payloadPath)) {
      console.warn(`⚠️ Warning: knowledge_payload.json not found at ${payloadPath}. Run ingest first.`);
      return '';
    }

    const rawData = fs.readFileSync(payloadPath, 'utf8');
    const knowledgeBase = JSON.parse(rawData);

    if (!Array.isArray(knowledgeBase) || knowledgeBase.length === 0) {
      console.warn("⚠️ Warning: knowledgeBase is empty.");
      return '';
    }
    
    // Strip punctuation and split into lowercase words
    const cleanPrompt = prompt.toLowerCase().replace(/[^\w\s]/g, ' ');
    const promptWords = cleanPrompt.split(/\s+/).filter(w => w.length > 2);
    if (characterClass) {
      promptWords.push(characterClass.toLowerCase());
    }
    console.log("🔍 RAG: Filtered query words:", promptWords);

    const scoredChunks = knowledgeBase.map(chunk => {
      let score = 0;
      const text = (chunk.text_content + " " + chunk.title + " " + (chunk.tags || []).join(" ")).toLowerCase();
      promptWords.forEach(word => {
        if (text.includes(word)) {
          score += 1;
        }
      });
      return { chunk, score };
    });

    // Filter out chunks with 0 score, sort by score descending, and take the top limit
    const relevantChunks = scoredChunks
      .filter(item => item.score > 0)
      .sort((a, b) => b.score - a.score)
      .slice(0, limit);

    console.log(`🔍 RAG: Found ${relevantChunks.length} relevant chunks`);
    relevantChunks.forEach(item => {
      console.log(`   - Chunk: "${item.chunk.title}" (Score: ${item.score})`);
    });

    const contextText = relevantChunks
      .map(item => `[Source: ${item.chunk.title} (${item.chunk.parent_uid})]\n${item.chunk.text_content}`)
      .join('\n\n');

    return contextText;
  } catch (error) {
    console.error("Error performing local RAG retrieval:", error);
    return '';
  }
}

const app = express();
app.use(express.json());

// Core Game Master Inference Flow
export const gameMasterFlow = ai.defineFlow(
  {
    name: 'gameMasterFlow',
    inputSchema: z.object({
      prompt: z.string(),
      characterClass: z.string().optional(),
    }),
    outputSchema: z.string(),
  },
  async (input) => {
    // Perform local retrieval
    const context = retrieveContext(input.prompt, input.characterClass);
    
    const systemInstruction = `You are the AI Game Master for The Remainder Portal. 
Your goal is to guide the player through their narrative journey in this post-collapse digital landscape.

Here is the relevant game lore and context retrieved for this session:
${context || 'No specific lore found for this query. Use general setting details.'}

Format guidelines:
- Remain immersive, descriptive, and aligned with the game's atmosphere (cyberpunk/high fantasy hybrid).
- Reflect the player's character class: ${input.characterClass || 'Wanderer'}.
- End your responses by giving the player options or asking what they want to do next.`;

    const response = await ai.generate({
      model: 'googleai/gemini-2.5-flash', // Latest stable flash model
      messages: [
        { role: 'system', content: [{ text: systemInstruction }] },
        { role: 'user', content: [{ text: input.prompt }] }
      ]
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
    res.status(500).json({ error: error.message });
  }
});

const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`🤖 Remainder Portal Serverless Engine live on port ${PORT}`);
});

