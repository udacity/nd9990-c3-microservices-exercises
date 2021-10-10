# Use NodeJS base image
FROM node:12

# Create app directory
WORKDIR /usr/src/app

# Install app dependencies
# A wildcard is used to ensure both package.json AND package-lock.json are copied where available (npm@5+)
COPY package*.json ./

# Install dependencies
RUN npm ci 

# Bundle app source

# Copy app source
COPY . .
# Bind the port that the image will run on
EXPOSE 8080
# Define the Docker image's behavior at runtime
CMD ["npm","run", "start"]