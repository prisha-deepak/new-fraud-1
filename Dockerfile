# Use a slim but compatible Python base
FROM python:3.10-slim

# Prevent interactive prompts
ENV DEBIAN_FRONTEND=noninteractive

# Set working directory
WORKDIR /app

# Install system deps required for PyTorch, DGL, and scientific libs
RUN apt-get update && apt-get install -y \
    git \
    build-essential \
    cmake \
    wget \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install pipenv

# Copy Pipenv files
COPY Pipfile Pipfile.lock ./

# Install dependencies inside container
RUN pipenv install --skip-lock

# Copy entire project
COPY . .

# Set environment variables
ENV FLASK_APP=app.py
ENV PORT=10000

# Expose port for Render
EXPOSE 10000

# Run Flask through pipenv
CMD ["sh", "-c", "pipenv run flask run --host=0.0.0.0 --port=${PORT}"]


