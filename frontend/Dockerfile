# build
FROM node:16.17.0 as builder
ARG VUE_APP_API_URL=https://kyn07c0.ru/api
ARG NODE_ENV=dev
WORKDIR /usr/src/app
COPY ./package*.json ./
RUN npm install
COPY . .
RUN npm run build

# release
FROM nginx:stable
RUN rm -rf /usr/share/nginx/html/*
COPY --from=builder /usr/src/app/dist /usr/share/nginx/html/
EXPOSE 80
ENTRYPOINT ["nginx", "-g", "daemon off;"]