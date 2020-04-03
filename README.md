# Exercism PureScript Test Runner

The Docker image for automatically run tests on PureScript solutions submitted
to [exercism][web-exercism].

This repository contains the Java test runner, which implements the
[test runner interface][test-runner-interface].


## Running the Tests in Docker container

To run a solution's test in the Docker container, do the following:
1. Open terminal in project's root
2. Run `./run-in-docker.sh <exercise> <solution-folder> <output-folder>`
