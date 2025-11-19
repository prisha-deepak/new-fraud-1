# Use the official Python 3.10 slim image
FROM python:3.10.0-slim

# Set the working directory in the container
WORKDIR /app

# Install system build tools needed for native extensions (adjust as needed)
RUN apt-get update && apt-get install -y \
    cmake \
    build-essential \
    libssl-dev \
    && rm -rf /var/lib/apt/lists/*

# Install pipenv
RUN pip install --no-cache-dir pipenv

# Copy Pipfile and Pipfile.lock first to leverage layer caching
COPY Pipfile Pipfile.lock ./

# Install dependencies using pipenv (regenerates lock inside container)
RUN pipenv install --skip-lock --python /usr/local/bin/python \
 && pipenv lock \
 && pipenv install --deploy --ignore-pipfile --python /usr/local/bin/python

# Copy the rest of the application code
COPY . .

# Default port for Cloud Run and local testing
ENV PORT=8080
ENV FLASK_APP=lab.backend.app.py
ENV FLASK_RUN_HOST=0.0.0.0

# Expose the port (use numeric constant for clarity)
EXPOSE 8080

# Use sh -c so environment variables (like $PORT) are expanded at runtime
CMD ["sh", "-c", "pipenv run flask run --host=0.0.0.0 --port=$PORT"]

