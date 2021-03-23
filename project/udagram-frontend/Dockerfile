FROM node:lts-alpine3.13 as build

WORKDIR /usr/src/app

COPY . .
RUN npm install -g @ionic/cli && npm install && ionic build --prod

FROM nginx:stable-alpine

COPY --from=build /usr/src/app/www/ /var/www

COPY ./nginx.conf /etc/nginx/conf.d/default.conf
RUN chmod go+r /etc/nginx/conf.d/default.conf

EXPOSE 80

CMD ["nginx", "-g", "daemon off;"]
