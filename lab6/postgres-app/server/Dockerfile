FROM node:10 AS builder
WORKDIR /app
COPY ./package.json ./
RUN npm install
COPY . .
ADD . /app
CMD ["npm", "run", "start:prod"]
