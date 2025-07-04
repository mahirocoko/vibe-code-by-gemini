FROM node:20-alpine AS development-dependencies-env
COPY package.json pnpm-lock.yaml /app/
WORKDIR /app
RUN npm install -g pnpm && pnpm install
COPY . /app/

FROM node:20-alpine AS production-dependencies-env
COPY ./package.json pnpm-lock.yaml /app/
WORKDIR /app
RUN npm install -g pnpm && pnpm install --prod --ignore-scripts

FROM node:20-alpine AS build-env
COPY . /app/
COPY --from=development-dependencies-env /app/node_modules /app/node_modules
WORKDIR /app
RUN npm install -g pnpm && pnpm run build

FROM node:20-alpine
RUN npm install -g pnpm
COPY ./package.json pnpm-lock.yaml /app/
COPY --from=production-dependencies-env /app/node_modules /app/node_modules
COPY --from=build-env /app/build /app/build
WORKDIR /app
EXPOSE 3000
ENV NODE_ENV=production
CMD ["pnpm", "run", "start"]