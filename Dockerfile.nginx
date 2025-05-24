FROM nginx:mainline-alpine3.18-slim

RUN rm /etc/nginx/conf.d/default.conf
COPY ./nginx.conf /etc/nginx/conf.d/mirror.conf
