FROM node:20.11-alpine

WORKDIR /app
COPY . .
RUN npm install

EXPOSE 3000

USER node
CMD ["node", "index.js"]
