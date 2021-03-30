FROM node:12-alpine3.10

WORKDIR /usr/src/app

COPY . .
RUN npm install && npm build

EXPOSE 8080

CMD npm run prod
