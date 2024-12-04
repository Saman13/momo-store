FROM node:16.17.0 as builder
ENV NODE_ENV=dev \
    VUE_APP_API_URL=http://saman-store.ru:8081
WORKDIR /usr/src/app
COPY ./package*.json ./
RUN npm install
COPY . .

RUN npm run build

FROM nginx:stable
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html/
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
