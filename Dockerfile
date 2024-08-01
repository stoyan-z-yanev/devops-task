# Use an official Python runtime as a parent image
FROM python:3.9-slim as base

# Set environment variables - avoid writing .pyc files and ensure stdout and stderr are unbuffered
ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

# Install build dependencies with pinned versions
RUN apt-get update \
    && apt-get install -y --no-install-recommends \
       build-essential=12.9 \
       gcc=4:10.2.1-1.1 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/*

# Install dependencies in a separate stage to leverage Docker's caching mechanism
FROM base as builder
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Final stage: copy only the necessary files and dependencies
FROM base
WORKDIR /app
COPY --from=builder /usr/local/lib/python3.9/site-packages /usr/local/lib/python3.9/site-packages
COPY --from=builder /usr/local/bin /usr/local/bin
COPY app/ .

# Expose the port FastAPI will run on
EXPOSE 80

# Command to run the application
CMD ["uvicorn", "main:app", "--host", "0.0.0.0", "--port", "80"]
