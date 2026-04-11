# ─────────────────────────────────────────
# Node.js Signaling + Media Server
# ─────────────────────────────────────────
FROM node:20-alpine

# Install ffmpeg (required by node-media-server for HLS/DASH transcoding)
RUN apk add --no-cache ffmpeg

WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm ci --omit=dev

# Copy application source
COPY . .

# Update ffmpeg path for Linux (overrides the Windows path in media_server.js)
ENV FFMPEG_PATH=/usr/bin/ffmpeg

EXPOSE 3000 8000 1935

CMD ["node", "index.js"]
