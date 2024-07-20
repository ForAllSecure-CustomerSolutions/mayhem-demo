# Use the official Python image
FROM python:3.9-slim

# Set the working directory
WORKDIR /app

# Copy the requirements file and install dependencies
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy the app code
COPY ./app /app/app
RUN mkdir /app/app/coverage

# Set the PYTHONPATH
ENV PYTHONPATH=/app

CMD ["coverage", "run", "--data-file=coverage/.coverage", "-m", "uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
