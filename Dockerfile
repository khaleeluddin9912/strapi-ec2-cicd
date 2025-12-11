FROM node:20-alpine

# Install required OS packages
RUN apk add --no-cache python3 make g++ libc6-compat

WORKDIR /app

COPY package*.json ./

# Install dependencies
RUN npm install

COPY . .

# Build the Strapi admin panel
RUN npm run build

EXPOSE 1337

CMD ["npm", "start"]
