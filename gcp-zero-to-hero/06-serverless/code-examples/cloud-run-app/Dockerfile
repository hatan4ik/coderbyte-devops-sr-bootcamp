# Dockerfile for the Python Flask web application

# Use an official lightweight Python image.
FROM python:3.9-slim

# Set the working directory in the container
WORKDIR /app

# Copy the dependencies file to the working directory
COPY requirements.txt .

# Install any dependencies
RUN pip install --no-cache-dir -r requirements.txt

# Copy the content of the local src directory to the working directory
COPY . .

# Specify the command to run on container startup.
# Gunicorn is a production-grade WSGI server.
# We bind to 0.0.0.0 to accept connections from any IP.
# The port is specified by the PORT environment variable, which Cloud Run sets.
CMD ["gunicorn", "--bind", "0.0.0.0:8080", "main:app"]
