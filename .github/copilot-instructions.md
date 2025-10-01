# GitHub Copilot Instructions for Paperless PDF Viewer Development

## Project Context

This repository contains a **minimal, lightweight development environment** for customizing the **PDF.js interactive viewer** in Paperless-NGX. It's specifically designed for developing interactive PDF features like audio annotations, JavaScript execution, enhanced hyperlinks, and multimedia support for the **Digital Dakwah Platform**.

## Key Information for Copilot

### Project Purpose

- **Primary Goal**: Develop interactive PDF viewer with multimedia support (audio, video, JavaScript)
- **Use Case**: Islamic educational materials with Quran recitation, Arabic text, and interactive features
- **Approach**: Minimal Docker container cloned from Paperless-NGX (~2GB vs 7GB+ production)
- **Development Focus**: PDF.js customization with hot-reload, no rebuilds needed

docker compose down -v && docker system prune -af

### External Resources

- Paperless-NGX: https://docs.paperless-ngx.com/

---

# GitHub Copilot Instructions for Paperless PDF Viewer Development

## Project snapshot

- Minimal Paperless-NGX clone dedicated to PDF.js feature work; stack runs through Docker Compose on port 8003.
- Services: `webserver` (built from `Dockerfile`), `db` (PostgreSQL 17-alpine), `broker` (Redis 8-alpine), `gotenberg` (`gotenberg/gotenberg:8`), `tika` (`apache/tika:3.0.0.0-full`). Keep these tags current; mistyped tags prevent pulls.

## Running the environment

- Use `./scripts/setup.sh` for end-to-end bootstrap: builds `paperless-pdf-dev`, extracts `pdf.min.mjs`/`pdf.worker.min.mjs` into `pdfjs-custom/lib/`, and starts the five services with health checks.
- Manual alternative: `docker compose up -d`; volumes mount `config/pdf-viewer-config.js`, `pdfjs-custom/`, `consume/`, `export/`, and `assets/` directly into the container for hot-reload.
- If the webserver loops on `/sbin/docker-entrypoint.sh`, open `/usr/src/paperless/dev-scripts/dev-start.sh`; it must end with `exec /init "$@"` because the base image uses s6-overlay.

## Editing hotspots

- `config/pdf-viewer-config.js`: runtime config; edits apply immediately.
- `pdfjs-custom/lib/*.mjs`: patch-level changes to PDF.js; restart `webserver` afterwards (`docker compose restart webserver`) and keep copies in `pdfjs-custom/backup/`.
- Avoid expanding the Dockerfile unless absolutely necessary—the goal is to keep the image <800 MB.

## Configuration pattern

```javascript
PAPERLESS_PDFJS_CONFIG.featureName = { enabled: true /* options */ };
PAPERLESS_PDFJS_CONFIG.onFeatureEvent = (payload) => {
  /* handler */ return result;
};
```

- Use the pattern for audio (`onAudioAnnotation`), hyperlinks (`onLinkClick`), JS sandbox (`javascript.allowedAPIs`), multimedia, and Islamic library helpers (RTL, Quran audio).

## Security & constraints

- Leave sandboxing enabled, guard external links with confirmations, and respect size limits (10 MB audio, 50 MB video).
- Document any Islamic/RTL-specific behaviour you add so downstream teams know why it exists.

## Testing & debugging

- Upload PDFs to `./consume/` or `POST /api/documents/post_document/`; review in the UI at http://localhost:8003.
- Watch `docker compose logs -f webserver` and browser DevTools (`pdfjs` filter) to verify handlers.
- If PDF.js assets vanish, run `/usr/src/paperless/dev-scripts/extract-pdfjs.sh`; for stubborn containers, inspect `docker compose ps` and prune volumes before retrying.
  │ └── pdf-viewer-config.js # PDF.js configuration (HOT-RELOAD)
