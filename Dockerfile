# Use a modern, small Python image
FROM python:3.11-slim

# Avoid Python writing .pyc files and buffer stdout
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1

# Create app directory
WORKDIR /app

# System deps (only if you need them; most wheels don't)
# RUN apt-get update && apt-get install -y --no-install-recommends \
#     build-essential && rm -rf /var/lib/apt/lists/*

# Install Python deps first (better Docker cache)
COPY requirements.txt /app/
RUN pip install --no-cache-dir -r requirements.txt

# Copy the rest (including model.pkl)
COPY . /app

# Render sets $PORT for you — expose it for clarity
EXPOSE $PORT

# Healthcheck (optional but helpful)
HEALTHCHECK --interval=30s --timeout=3s --retries=3 CMD wget -qO- http://localhost:$PORT/health || exit 1

# Start Gunicorn — IMPORTANT: no colon after --bind
# Keep workers low on free tier to save memory while debugging
CMD gunicorn --workers=1 --bind 0.0.0.0:$PORT app:app --log-level info