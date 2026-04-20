# ─────────────────────────────────────────
# Node.js Signaling + Media Server
# ─────────────────────────────────────────
FROM node:20-alpine

# Install ffmpeg (required by node-media-server for HLS/DASH transcoding)
RUN apk add --no-cache ffmpeg

WORKDIR /app

# Install dependencies first (layer cache)
COPY package*.json ./
RUN npm install --omit=dev

# Copy application source with explicit permissions
COPY --chown=node:node . .
RUN chown -R node:node /app

# Update ffmpeg path for Linux
ENV FFMPEG_PATH=/usr/bin/ffmpeg

# Switch to non-root user for OpenShift compatibility
USER node

EXPOSE 3000 8000 1935

CMD ["node", "index.js"]
