# Base alpine image with go tools
# https://github.com/iron-io/dockers/tree/master/go
FROM iron/go

# Setup the /go working directory for the app
WORKDIR /go

# Mount the "api" go binary into the docker image
# go build -o api server.go
ADD api /go

# Expose the port the go api server is listening on
EXPOSE 8000

# Configure the entrypoint which runs the go app
ENTRYPOINT ["./api"]
