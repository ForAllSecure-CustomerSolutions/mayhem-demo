# Use the official Node.js image.
FROM node:22

# Set the working directory.
WORKDIR /app

# Copy the package.json and package-lock.json files.
COPY package*.json ./

# Install the dependencies.
RUN npm install

# Copy the rest of the application files.
COPY . .

# Expose the port the app runs on.
EXPOSE 3000

# Start the React development server.
CMD ["npm", "start"]
