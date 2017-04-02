## About
Application to easily make groups for teachers in danish high schools.
Fetches data from the lection site.

## Run the application locally
The application relies on an API that serves as a proxy. An implementation packaged in a docker container can be downloaded by executing:
```bash
docker pull dr0l3/grouper-api
```
The site currently relies on hardcoded endpoints, but assuming that is fixed the application can be run by executing:
```bash
elm-reactor
```
Go to localhost:8000

## Package the application in an Nginx docker container
```bash
elm make src/Main.js --output=./dist/main.js
cp index.html ./dist/index.html
docker build -t <yournamehere> .
```

## Run the packaged application

```bash
docker run -d -p 80:80 <yournamehere>
```