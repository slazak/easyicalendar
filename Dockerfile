# build stage
FROM node:lts-alpine as build
WORKDIR /app
COPY package.json* ./
RUN npm install
COPY . .
RUN npm run build -- --mode custom

# production stage #
FROM nginx:stable-alpine AS runtime
COPY ./nginx/nginx.conf /etc/nginx/nginx.conf
COPY --from=build /app/dist /usr/share/nginx/html
# EXPOSE 80
# CMD ["nginx", "-g", "daemon off;"]


