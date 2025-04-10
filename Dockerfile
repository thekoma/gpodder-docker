# Use a stable Python 3.x base image (mygpo requires >= 3.5)
FROM python:3.9-slim-bullseye

# Set environment variables
ENV PYTHONUNBUFFERED=1 \
    DEBIAN_FRONTEND=noninteractive \
    # Default configuration values (can be overridden at runtime)
    # Note: SECRET_KEY and DATABASE_URL MUST be provided at runtime for production
    DJANGO_SETTINGS_MODULE=mygpo.settings \
    DEBUG=False \
    PORT=8000

# Install system dependencies required by mygpo and its Python packages
RUN apt-get update && \
    apt-get install -y --no-install-recommends \
    # For git clone
    git \
    # For psycopg2 (PostgreSQL adapter)
    libpq-dev \
    # For Pillow (image processing)
    libjpeg-dev \
    zlib1g-dev \
    libwebp-dev \
    # For building some Python packages
    build-essential \
    # For cffi
    libffi-dev \
    # For running psql commands if needed (e.g., wait scripts)
    postgresql-client \
    # For HTTPS requests
    ca-certificates \
    && apt-get clean && \
    rm -rf /var/lib/apt/lists/*

# Set the working directory
WORKDIR /app

# Clone the mygpo source code
# Using https instead of git protocol for broader compatibility
RUN git clone --depth 1 https://github.com/gpodder/mygpo.git .

# Install Python dependencies
# requirements-setup.txt likely contains gunicorn/uwsgi for production
RUN pip install --no-cache-dir -r requirements.txt -r requirements-setup.txt

# Create a non-root user to run the application
RUN useradd --system --create-home --shell /bin/bash appuser
USER appuser
WORKDIR /app

# Expose the port the app runs on
EXPOSE 8000

# Command to run the application using Gunicorn
# Assumes gunicorn is in requirements-setup.txt and the WSGI app is at mygpo.wsgi:application
# The number of workers can be adjusted based on the server resources
CMD ["gunicorn", "--bind", "0.0.0.0:8000", "--workers", "4", "mygpo.wsgi:application"]
