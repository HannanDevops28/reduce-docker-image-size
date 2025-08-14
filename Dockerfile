FROM node:20 AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci  # clean install, avoids mixing host-installed modules

COPY .env.production .env

COPY . .

RUN npm run build

FROM node:20-slim AS runner
WORKDIR /app

ENV NODE_ENV=production

COPY --from=builder /app/package*.json ./
RUN npm ci --omit=dev

COPY --from=builder /app/.next ./.next
COPY --from=builder /app/public ./public
COPY --from=builder /app/next.config.ts ./

EXPOSE 3000
CMD ["npm", "start"]
