# Use official Node.js 20 slim image
FROM node:20-slim

# Set working directory
WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies
RUN npm ci

# Copy application files (includes src/ and knowledge_payload.json)
COPY . .

# Expose the standard Cloud Run port
EXPOSE 8080

# Environment setup
ENV PORT=8080
ENV NODE_ENV=production

# Start the Express server using tsx
CMD ["npx", "tsx", "src/index.ts"]
