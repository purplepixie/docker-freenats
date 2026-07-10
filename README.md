# Docker package for FreeNATS Network Monitor

This is the "official" [FreeNATS](https://www.purplepixie.org/freenats/) docker image built as part of the [FreeNATS](https://www.purplepixie.org/freenats/) project. Periodically the stored [Dockerhub image](https://hub.docker.com/r/purplepixie/freenats) will be updated but you can build your own custom version easily from here also.

## Running FreeNATS Docker

FreeNATS by default will start, provision an internal database (see below if you want to change that) and listen on port 80 for connections (note the version of FreeNATS is baked in at build time, the upgrade process is under development/testing).

So for example to run FreeNATS in a container and listen on host port 8080:

```
docker run -d -p 8080:80 purplepixie/freenats
```

## Remote Database

The database is normally local to the container however you can, at runtime, specify an external/alternative MySQL/MariaDB database connection. The environment variables are ```DB_SERVER```, ```DB_USERNAME```, ```DB_PASSWORD``` and ```DB_DATABASE``` (also note ```DB_PORT``` can be set but this will only be effective with FreeNATS 1.32.00 or later).

Note that for any flags to be read ```DB_SERVER``` must be set and if ```DB_SERVER``` is set the other variables (apart from ```DB_PORT``` must be provided).

```
docker run -e DB_SERVER=some.database.com -e DB_USERNAME=natsuser -e DB_PASSWORD=secret -e DB_DATABASE=freenatsdb purplepixie/freenats
```

## Issues or Problems

With the docker container please raise [an issue in the docker-freenats repository](https://github.com/purplepixie/docker-freenats) or for more generate FreeNATS support see the [FreeNATS website](https://www.purplepixie.org/freenats/).

## Building a Container Image

By default the build process will grab the _latest stable_ release. It is possible to specify at ```build time``` the version of FreeNATS to bake into the container using the build env VERSION, so for example:

```
docker build --build-arg VERSION=1.30.13a -t purplepixie/freenats .
```

Would build the container with the specific version 1.30.13a. Note if the download does not exist then the build process will fail.

Note that the default distribution should be ```linux/amd64``` format so on an ARM (i.e. Apple Silicon) the build should include a ```--platform``` flag:

```
docker build --platform linux/amd64 -t purplepixie/freenats .
```
