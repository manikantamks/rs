FROM node:16.13.1 as build
WORKDIR /app

RUN npm install -g @angular/cli

COPY ./package.json .
RUN npm install
COPY . .
RUN ng build
FROM nginx as runtime
COPY --from=build /app/dist/query-box /usr/share/nginx/html

RUN chgrp -R 0 /etc/nginx/conf.d && \
    chmod -R g=u /etc/nginx/conf.d

# support running as arbitrary user which belogs to the root group
RUN chmod g+rwx /var/cache/nginx /var/run /var/log/nginx

# 80 is a priviliged port
RUN sed -i.bak 's/listen\(.*\)80;/listen 8080;/' /etc/nginx/conf.d/default.conf

# Expose port 80
EXPOSE 80

# remove the user directive
RUN sed -i.bak 's/^user/#user/' /etc/nginx/nginx.conf