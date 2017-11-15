# Build and test futurekit in linux with this Dockerfile by just running `docker build .` from the root of the repo

FROM swift:latest

WORKDIR .

COPY Package.swift ./
COPY Source ./Sources
COPY Tests ./Tests

RUN swift build
