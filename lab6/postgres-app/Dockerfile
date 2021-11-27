FROM node:13.12.0-alpine

WORKDIR /postgres-app

ENV PATH /postgres-app/node_modules/.bin:$PATH

COPY package.json ./
RUN npm install --silent
RUN npm install react-scripts@3.4.1 -g --silent

COPY . ./

EXPOSE 3011

CMD ["npm", "run", "start"]
