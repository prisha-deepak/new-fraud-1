FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# Install system deps
RUN apt-get update && apt-get install -y \
    git build-essential cmake wget libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install pipenv

# Install PyTorch
RUN pip install torch==2.2.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install DGL
RUN pip install dgl==1.1.3 -f https://data.dgl.ai/wheels/repo.html

# Copy Pipfile
COPY Pipfile Pipfile.lock ./

# ❗ Install WITHOUT lockfile (Linux-safe)
RUN pipenv install --skip-lock --system

# Copy project files
COPY . .

ENV FLASK_APP=lab/backend/app.py
ENV PORT=10000

EXPOSE 10000

CMD ["sh", "-c", "flask run --host=0.0.0.0 --port=${PORT}"]

