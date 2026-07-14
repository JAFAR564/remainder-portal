#!/usr/bin/env node
const { execSync } = require('child_process');

const command = process.argv[2];

function run(cmd) {
  console.log(`\x1b[36m⚡ Antigravity executing: ${cmd}\x1b[0m`);
  execSync(cmd, { stdio: 'inherit' });
}

switch (command) {
  case 'ingest':
    run('node serverless-backend/parse-okf.js');
    break;
  case 'run':
    console.log('--- Phase: Ingesting OKF Lore ---');
    run('node serverless-backend/parse-okf.js');
    console.log('--- Phase: Starting Serverless Engine ---');
    run('npx tsx serverless-backend/src/index.ts');
    break;
  case 'help':
    console.log(`
Antigravity CLI
---------------
ingest  : Parse markdown lore into knowledge_payload.json
run     : Ingest lore, then start the serverless API engine
    `);
    break;
  default:
    console.log('Unknown command. Try "antigravity help"');
}
