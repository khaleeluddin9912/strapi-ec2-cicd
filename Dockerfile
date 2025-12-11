FROM node:20-alpine

# Install required OS packages
RUN apk add --no-cache python3 make g++ libc6-compat

WORKDIR /app

# Copy package.json and package-lock.json from Strapi folder
COPY strapi-project/package*.json ./

# Install dependencies
RUN npm install

# Copy the rest of Strapi app
COPY strapi-project/ ./

# Build the Strapi admin panel
RUN npm run build

EXPOSE 1337

CMD ["npm", "start"]
