FROM python:3.10-slim

ENV DEBIAN_FRONTEND=noninteractive
WORKDIR /app

# System dependencies
RUN apt-get update && apt-get install -y \
    git build-essential cmake wget libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install pipenv

# Install PyTorch CPU wheels FIRST (avoids Pipenv conflicts)
RUN pip install torch==2.2.0 torchvision torchaudio --index-url https://download.pytorch.org/whl/cpu

# Install DGL CPU wheel
RUN pip install dgl==1.1.3 -f https://data.dgl.ai/wheels/repo.html

# Copy Pipfile
COPY Pipfile Pipfile.lock ./

# Install your remaining dependencies
RUN pipenv install --skip-lock --system --deploy

# Copy project files
COPY . .

ENV FLASK_APP=app.py
ENV PORT=10000

EXPOSE 10000

CMD ["sh", "-c", "flask run --host=0.0.0.0 --port=${PORT}"]
