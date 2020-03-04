if [ "$1" == "rebuild" ]; then
    docker build -t gogogoimage .
fi

docker container rm gogogodocker
docker run --name gogogodocker -v `cd .. && pwd`:/gogogospace -p 8480:80 -d gogogoimage