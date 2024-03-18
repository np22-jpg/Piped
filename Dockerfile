FROM node:lts-alpine AS build

WORKDIR /app/

RUN --mount=type=cache,target=/var/cache/apk \
    apk add --no-cache \
    curl

COPY . .

RUN corepack enable && corepack prepare pnpm@latest --activate

RUN --mount=type=cache,target=/root/.local/share/pnpm \
    --mount=type=cache,target=/app/node_modules \
    pnpm install --prefer-offline && \
    pnpm build && ./localizefonts.sh

FROM nginx:alpine@sha256:02d8d94023878cedf3e3acc55372932a9ba1478b6e2f3357786d916c2af743ba

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
