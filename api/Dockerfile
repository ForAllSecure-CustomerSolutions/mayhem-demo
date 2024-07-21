# Use the official Python image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY ./app /app/app
COPY run-it.sh /app

RUN echo "[run]\nrelative_files = True" > .coveragerc

ENV PYTHONPATH=/app

CMD ["/bin/bash", "./run-it.sh"]
