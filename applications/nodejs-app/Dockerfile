FROM node:20-alpine

WORKDIR /app

# Copy package files
COPY package*.json ./

# Install dependencies (if any)
RUN npm install --production

# Copy application code
COPY . .

# Set environment variables
ENV APP_NAME=nodejs-app
ENV ENVIRONMENT=development

# Run the application
CMD ["node", "app.js"]
