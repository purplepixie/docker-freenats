# Docker package for FreeNATS Network Monitor

This is the "official" [FreeNATS](https://www.purplepixie.org/freenats/) docker image built as part of the [FreeNATS](https://www.purplepixie.org/freenats/) project. Periodically the stored [Dockerhub image](https://hub.docker.com/r/purplepixie/freenats) will be updated but you can build your own custom version easily from here also.

## 2024 Refresh

There was a major change to the docker build process and contents in mid-2024.

## Remote Database

The database is local to the container and there is a plan to make it possible to use a remote database. If this is a major issue raise an issue on the FreeNATS docker github here: https://github.com/purplepixie/docker-freenats 

## Issues or Problems

With the docker container please raise [an issue in the docker-freenats repository](https://github.com/purplepixie/docker-freenats) or for more generate FreeNATS support see the [FreeNATS website](https://www.purplepixie.org/freenats/).

## Build Options

By default the build process will grab the _latest stable_ release. It is possible to specify at ```build time``` the version of FreeNATS to bake into the container using the build env VERSION, so for example:

```
docker build --build-arg VERSION=1.30.13a -t purplepixie/freenats .
```

Would build the container with the specific version 1.30.13a. Note if the download does not exist then the build process will fail.

Note that the default distribution should be ```linux/amd64``` format so on an ARM (i.e. Apple Mx) the build should include a ```--platform``` flag:

```
docker build --platform linux/amd64 -t purplepixie/freenats .
```
