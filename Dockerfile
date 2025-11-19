FROM python:3.10-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Copy everything (backend + gnn)
COPY . .

# Install Python dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Correct path to Flask app
ENV FLASK_APP=lab/backend/app.py
ENV FLASK_RUN_HOST=0.0.0.0

EXPOSE 8080

CMD ["flask", "run", "--host=0.0.0.0", "--port=8080"]


