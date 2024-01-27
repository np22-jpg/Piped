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

FROM nginx:alpine@sha256:363e10bd564f68a966d3fd3e5e59b701f8d0e36b68ef8517d0527bf7e844092c

COPY --from=build /app/dist/ /usr/share/nginx/html/
COPY docker/nginx.conf /etc/nginx/conf.d/default.conf

EXPOSE 80
