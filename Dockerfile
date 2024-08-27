# BUILD STAGE
FROM node:14-alpine as build-step

WORKDIR /app

# Install dependencies separately to leverage Docker cache
COPY package.json package-lock.json /app/

RUN npm ci --silent

# Copy the rest of the application code
COPY . /app

RUN npm run build

# ========================================
# NGINX STAGE
# ========================================

FROM nginx:1.23-alpine

# Setting non-root user for better security
RUN chown -R nginx:nginx /usr/share/nginx/html && \
    chmod -R 755 /usr/share/nginx/html && \
    echo 'server_tokens off;' > /etc/nginx/conf.d/security.conf

WORKDIR /usr/share/nginx/html/

COPY --from=build-step /app/build ./

# Use exec format for CMD to enable graceful shutdown and signals handling
CMD ["nginx", "-g", "daemon off;"]

