# docker-go-mysql
Just a light-weighted(490M for golang, 266MB for mysql/mariadb) local environment for developers using golang, and mysql stack. No nginx is needed for local development, though you have to set up upstream for bionic servers.

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
