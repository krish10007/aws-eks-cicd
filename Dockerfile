# ── Stage 1: builder ──────────────────────────────────────────────
FROM python:3.11-slim AS builder

WORKDIR /build

# Install dependencies into an isolated directory so Stage 2
# can copy just the installed packages — not pip's cache or metadata
COPY app/requirements.txt .
RUN pip install --upgrade pip \
    && pip install --prefix=/install --no-cache-dir -r requirements.txt


# ── Stage 2: runtime ──────────────────────────────────────────────
FROM python:3.11-slim

# Non-root user — running as root inside a container is a security risk
RUN useradd --create-home appuser
WORKDIR /home/appuser

# Copy installed packages from builder stage
COPY --from=builder /install /usr/local

# Copy application code
COPY app/ ./app/

# Switch to non-root user before starting the process
USER appuser

# Document which port the app listens on (doesn't publish it — that's docker run's job)
EXPOSE 8000

# Uvicorn serves the FastAPI app
# --host 0.0.0.0 makes it reachable from outside the container
# --workers 1 is correct for Kubernetes — HPA scales pods, not workers
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]