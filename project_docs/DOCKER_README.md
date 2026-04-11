# Alumni Connect — Docker Setup Guide

This guide explains how to run all project services using Docker and Docker Compose.

---

## Services

| Service           | Description                              | Ports              |
|-------------------|------------------------------------------|--------------------|
| `backend`         | Spring Boot REST + WebSocket API         | `8080`             |
| `signaling_server`| Node.js WebRTC signaling + media stream  | `3000`, `8000`, `1935` |

---

## Prerequisites

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) installed and **running**
- No local processes occupying ports `8080`, `3000`, `8000`, or `1935`

---

## Quick Start

```bash
# 1. Start Docker Desktop (or ensure the daemon is running)

# 2. From the project root, build all images
docker compose build

# 3. Start all services in the background
docker compose up -d

# 4. Tail logs for all services
docker compose logs -f

# 5. Stop all services
docker compose down
```

---

## Individual Service Logs

```bash
docker compose logs -f backend
docker compose logs -f signaling_server
```

---

## Rebuild a Specific Service

```bash
docker compose build backend
docker compose build signaling_server
```

---

## Environment Variables

Secrets are stored in the `.env` file at the project root (see `.env.example`).
Docker Compose reads this file automatically.

| Variable           | Used By   | Description                  |
|--------------------|-----------|------------------------------|
| `OPENROUTER_API_KEY` | backend | AI API key for features       |
| `FFMPEG_PATH`      | signaling | Path to ffmpeg inside container (auto-set) |

---

## Ports Reference

| Port  | Service           | Protocol |
|-------|-------------------|----------|
| 8080  | backend           | HTTP     |
| 3000  | signaling_server  | HTTP/WS  |
| 8000  | signaling_server (NodeMediaServer) | HTTP (HLS/DASH) |
| 1935  | signaling_server (RTMP ingest)     | TCP/RTMP |

---

## Flutter App Connection

When running Docker on the same machine, configure your Flutter app to point to:

- **Backend API** → `http://localhost:8080`
- **Signaling/WebRTC** → `http://localhost:3000`

For physical devices on the same network, replace `localhost` with your machine's local IP (e.g. `192.168.1.x`).

---

## File Structure

```
alumini_screen/
├── docker-compose.yml           ← Orchestrates all services
├── .env                         ← Secrets (gitignored)
├── backend/
│   ├── Dockerfile               ← Multi-stage Spring Boot image
│   └── .dockerignore
└── signaling_server/
    ├── Dockerfile               ← Node.js + ffmpeg image
    └── .dockerignore
```
