# docker-go-mysql
This is a light-weighted(490M for golang, 266MB for mysql/mariadb) local environment set up for developers using nginx, golang, nodejs and mysql stack. 

For significantly better performance, the nodejs should not be installed inside the container. It should be installed on your local.

For separation of frontend (using nodejs) and backend/api (using go gin), nginx should be installed in your local, with upstream pointing to nodejs's port 3000 and go gin's port 8080 (forwarded from local port 8480). See nginx config example below,
`
# your local /etc/nginx/conf.d/default.conf
# or for brew nginx service, /usr/local/etc/nginx/servers/default.conf
server {
    listen 80 default_server;

    location /api {
        proxy_pass http://127.0.0.1:8480;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }

    location / {
        proxy_pass http://127.0.0.1:3000;
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection 'upgrade';
        proxy_set_header Host $host;
        proxy_cache_bypass $http_upgrade;
    }
}
`

## Your workspace structure
Clone this repository into your workspace folder with the following structure
- workspace/
  - docker-go-mysql/
  - project 1
  - project 2
  - ...
  
Your *workspace/* will be mapped to */gogogospace* inside container named *gogogocontainer*.

## Command Instructions
Compose it:

`docker-compose up -d`

Or just start docker container without mysql container

`bash start_docker.sh [rebuild]`

where `rebuild` is optional.

Tear it down:

`docker-compose down`

## Working inside your container

`docker exec -it gogogodocker bash`

`cd /gogogospace`

`export PS1="\u@\w $"`

## Connecting to your database from your local mysql client
Use *127.0.0.1* as host, *gogogoapp* as user name, *secret* as password, *gogogodb* as database name.
