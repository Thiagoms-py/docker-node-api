ARG NODE_IMAGE=node:22-bookworm-slim@sha256:5ec23b7c622b00547753bc6ffd78085dd868a68aeb41c8e0a1418f033e13d96d
ARG APP_VERSION=1.0.0

FROM ${NODE_IMAGE} AS dev

WORKDIR /app

ENV NODE_ENV=development

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

RUN chown node:node /app

COPY --chown=node:node tsconfig.json ./
COPY --chown=node:node src ./src

USER node

EXPOSE 3000

CMD ["npm", "run", "dev"]


FROM --platform=$BUILDPLATFORM ${NODE_IMAGE} AS build

WORKDIR /app

COPY package.json package-lock.json ./
RUN --mount=type=cache,target=/root/.npm npm ci

COPY tsconfig.json ./
COPY src ./src

RUN npm run build


FROM ${NODE_IMAGE} AS production

ARG APP_VERSION

WORKDIR /app

ENV NODE_ENV=production

LABEL org.opencontainers.image.title="Flags API" \
    org.opencontainers.image.description="API REST de feature flags com Node.js, TypeScript e PostgreSQL" \
    org.opencontainers.image.version="${APP_VERSION}" \
    org.opencontainers.image.source="https://github.com/Thiagoms-py/docker-node-api"

COPY package.json package-lock.json ./

# Corrige a CVE-2026-90711 somente nos manifestos copiados para a imagem.
RUN --mount=type=cache,target=/root/.npm \
    npm pkg set overrides.proxy-addr=2.0.8 \
    && npm install --package-lock-only --ignore-scripts --no-audit --no-fund \
    && npm ci --omit=dev --no-audit --no-fund

COPY --from=build --chown=node:node /app/dist ./dist

USER node

EXPOSE 3000

HEALTHCHECK --interval=30s --timeout=5s --start-period=10s --retries=3 \
    CMD node -e "fetch('http://127.0.0.1:' + (process.env.PORT || 3000) + '/health').then(r => process.exit(r.ok ? 0 : 1)).catch(() => process.exit(1))"

ENTRYPOINT ["sh", "-c", "node dist/db/migrate.js && exec \"$@\"", "--"]
CMD ["node", "dist/server.js"]
