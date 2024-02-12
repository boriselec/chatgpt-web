# ---- Base Node ----
FROM node:19-alpine AS base
WORKDIR /app
COPY package*.json ./

# ---- Dependencies ----
FROM base AS dependencies
RUN npm ci

# ---- Build ----
FROM dependencies AS build
COPY . .
RUN npm run build

# Start the application
FROM nginx:stable-alpine
WORKDIR /usr/share/nginx/html
COPY --from=build /app/dist .
CMD /bin/sh -c "\
for file in assets/index*.js; do \
  sed -i 's/your_api_key/'\"\$OPENAPI_KEY\"'/g' \$file; \
  sed -i 's|https://api.openai.com|'\"\$API_BASE\"'|g' \$file; \
done && \
exec nginx -g 'daemon off;'\
"
EXPOSE 80
