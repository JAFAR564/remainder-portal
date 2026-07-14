import fs from 'fs';
import path from 'path';
import { fileURLToPath } from 'url';

const __filename = fileURLToPath(import.meta.url);
const __dirname = path.dirname(__filename);

const KNOWLEDGE_DIR = path.join(__dirname, '../assets/okf');
const OUTPUT_FILE = path.join(__dirname, 'knowledge_payload.json');

// Simple regex helper to pull out YAML frontmatter
function parseFrontmatter(fileContent) {
  const frontmatterRegex = /^---\r?\n([\s\S]*?)\r?\n---/;
  const match = fileContent.match(frontmatterRegex);
  
  if (!match) return { metadata: {}, content: fileContent };

  const rawYaml = match[1];
  const content = fileContent.replace(frontmatterRegex, '').trim();
  const metadata = {};

  rawYaml.split('\n').forEach(line => {
    const parts = line.split(':');
    if (parts.length >= 2) {
      const key = parts[0].trim();
      let value = parts.slice(1).join(':').trim();
      value = value.replace(/^["']|["']$/g, '');
      if (value.startsWith('[') && value.endsWith(']')) {
        value = value.slice(1, -1).split(',').map(t => t.trim().replace(/^["']|["']$/g, ''));
      }
      metadata[key] = value;
    }
  });

  return { metadata, content };
}

// Simple sliding window semantic-ish text chunker
function chunkText(text, maxWords = 200, overlapWords = 40) {
  const words = text.split(/\s+/);
  const chunks = [];
  
  if (words.length <= maxWords) {
    return [text];
  }

  for (let i = 0; i < words.length; i += (maxWords - overlapWords)) {
    const chunkWords = words.slice(i, i + maxWords);
    chunks.push(chunkWords.join(' '));
    if (i + maxWords >= words.length) break;
  }

  return chunks;
}

function processDirectory(dir, filesList = []) {
  const files = fs.readdirSync(dir);
  
  files.forEach(file => {
    const filePath = path.join(dir, file);
    const stat = fs.statSync(filePath);
    
    if (stat.isDirectory()) {
      processDirectory(filePath, filesList);
    } else if (file.endsWith('.md')) {
      filesList.push(filePath);
    }
  });
  
  return filesList;
}

function buildPayload() {
  console.log('🚀 Starting OKF Parsing Ingest...');
  const allMarkdownFiles = processDirectory(KNOWLEDGE_DIR);
  const processedPayload = [];

  allMarkdownFiles.forEach(filePath => {
    const rawContent = fs.readFileSync(filePath, 'utf8');
    const { metadata, content } = parseFrontmatter(rawContent);
    
    if (!metadata.uid) {
      console.warn(`⚠️ Warning: Missing UID in file ${path.basename(filePath)}. Skipping.`);
      return;
    }

    const textualChunks = chunkText(content);

    textualChunks.forEach((chunk, index) => {
      processedPayload.push({
        id: `${metadata.uid}_chunk_${index}`,
        parent_uid: metadata.uid,
        title: metadata.title || 'Untitled Node',
        category: metadata.category || 'general',
        tags: metadata.tags || [],
        chunk_index: index,
        text_content: chunk
      });
    });
  });

  fs.writeFileSync(OUTPUT_FILE, JSON.stringify(processedPayload, null, 2), 'utf8');
  console.log(`✅ Success! Generated ${processedPayload.length} knowledge chunks at ${OUTPUT_FILE}`);
}

buildPayload();
