# Build

the following steps outline how to create a new docker image for a go application.

## Dependency manager (`Glide`)

Go does not have a built in package manager, so I chose `glide` as it has docker image support.

Glide can be initialized in a project using the following `docker run` command, it will likely first download the docker image:

```
docker run --rm -it -v $PWD:/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo treeder/glide init
```
```
$ docker run --rm -it -v $PWD:/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo treeder/glide init
Unable to find image 'treeder/glide:latest' locally
latest: Pulling from treeder/glide
6b03e1135128: Pull complete
9fe26e1c9bb7: Pull complete
0fe0cbec98ed: Pull complete
c0d6fa040e8a: Pull complete
83f56e98c090: Pull complete
5c7ad352bc88: Pull complete
87cd9e1075b3: Pull complete
7604ba465ce4: Pull complete
6e6e9037139f: Pull complete
9628aaf4ecb0: Pull complete
3f0767dc4918: Pull complete
109c6b846bfe: Pull complete
1570c4e504b8: Pull complete
Digest: sha256:29ab37762c34545383b1acc8b3abd4e495c1d96ec52d81685609f499b5b5d6e4
```

When it starts running it should ask you for an input, simply type `N` and enter key:

```
[INFO]	Generating a YAML configuration file and guessing the dependencies
[INFO]	Attempting to import from other package managers (use --skip-import to skip)
[INFO]	Scanning code to look for dependencies
[INFO]	--> Found reference to github.com/gorilla/mux
[INFO]	Writing configuration file (glide.yaml)
[INFO]	Would you like Glide to help you find ways to improve your glide.yaml configuration?
[INFO]	If you want to revisit this step you can use the config-wizard command at any time.
[INFO]	Yes (Y) or No (N)?
N
[INFO]	You can now edit the glide.yaml file. Consider:
[INFO]	--> Using versions and ranges. See https://glide.sh/docs/versions/
[INFO]	--> Adding additional metadata. See https://glide.sh/docs/glide.yaml/
[INFO]	--> Running the config-wizard command to improve the versions in your configuration
```

Once it has initialised we are ready to perform a dependency update so we can pull down any packages our app needs.
- Glide is quite intelligent here and should scan your local project for package requirements

Again, Glide has docker image support so we can run an update using the following `docker run` command:

```
docker run --rm -it -v $PWD:/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo treeder/glide update
```
```
$ docker run --rm -it -v $PWD:/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo treeder/glide update
[INFO]	Downloading dependencies. Please wait...
[INFO]	--> Fetching github.com/gorilla/mux.
[INFO]	Resolving imports
[INFO]	--> Fetching github.com/gorilla/context.
[INFO]	Downloading dependencies. Please wait...
[INFO]	Setting references for remaining imports
[INFO]	Exporting resolved dependencies...
[INFO]	--> Exporting github.com/gorilla/mux
[INFO]	--> Exporting github.com/gorilla/context
[INFO]	Replacing existing vendor dependencies
[INFO]	Project relies on 2 dependencies.
```

You should now have a `vendor/` folder initialised in your project, containing third party dependencies.

## Go binary

Once you have the packages initialised you are ready to create the Go binary by compiling the application source code.

This can be achieved using the `go build` command, however... to be consistent... we can also use a go docker image again.

The following `docker run` command can be used to compile the application into an executable binary:

```
docker run --rm -v "$PWD":/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo iron/go:dev go build -o api
```
```
$ docker run --rm -v "$PWD":/go/src/github.com/treeder/dockergo -w /go/src/github.com/treeder/dockergo iron/go:dev go build -o api
$ ls -l
total 11784
-rw-r--r--  1 danbelden  staff      461 21 Sep 13:43 Dockerfile
-rw-r--r--  1 danbelden  staff     4137 21 Sep 16:20 README.md
-rwxr-xr-x  1 danbelden  staff  6006564 21 Sep 16:24 api
-rw-r--r--  1 danbelden  staff      306 21 Sep 13:51 glide.lock
-rw-r--r--  1 danbelden  staff       79 21 Sep 13:48 glide.yaml
-rw-r--r--  1 danbelden  staff      182 21 Sep 12:19 server.go
drwxr-xr-x  3 danbelden  staff      102 21 Sep 13:51 vendor
```

As you can see there is now a binary executable file in the project root called `api`.

This `api` binary file will be needed in this next stage of building a new docker image for the application.

## Docker image

Once you have acquired the `api` go binary using the steps above, you are ready to create a new docker image.

The home folder of this application contains a `Dockerfile`, so the following simple `docker build` command should work for you:

```
docker build -t go-api .
```
```
$ docker build -t go-api .
Sending build context to Docker daemon  6.218MB
Step 1/5 : FROM iron/go
 ---> c05f82fa066a
Step 2/5 : WORKDIR /go
 ---> 6d0eae9b5bef
Removing intermediate container 997cf033668b
Step 3/5 : ADD api /go
 ---> 320abdb34853
Removing intermediate container f42355b426c7
Step 4/5 : EXPOSE 8000
 ---> Running in 22c5fb150aa2
 ---> b4aedaada483
Removing intermediate container 22c5fb150aa2
Step 5/5 : ENTRYPOINT ./api
 ---> Running in 7dcb7d8c469b
 ---> 5d4f5960e617
Removing intermediate container 7dcb7d8c469b
Successfully built 5d4f5960e617
Successfully tagged go-api:latest
```

Once you recieve the successful status, you should have a fresh docker image ready to launch... you can confirm this using the `docker images` command:

```
$ docker images | grep api
go-api             latest              5d4f5960e617        8 seconds ago       16.5MB
```

You are now ready to launch your go application to test it.

## Docker run

Once you have created a docker image using the go build, compile and docker build steps above... you are ready to run your docker image.

To do that you can run your application in a number of ways, in this test it is a HTTP server listening on port 8000, so I want to run it in daemon mode with this port connected to host.

```
docker run -p8000:8000 -d go-api
```
```
$ docker run -p8000:8000 -d go-api
641efb548a95e91aa7cb478ba93756380be29e5f490a3635eb3659cbb4a21851
```

This is indicated the image has launched and it has given you the container id, but it's better to check it using a `docker ps` command:


```
docker ps | grep api
```
```
$ docker ps | grep api
641efb548a95        go-api              "./api"             4 seconds ago       Up 3 seconds        0.0.0.0:8000->8000/tcp   zealous_fermi
```

From this we can see the container is running and the port is wired to the host port `8000`, this should mean we can test the service using our web browser!

```
curl -I http://localhost:8000
```
```
$ curl -I http://localhost:8000
HTTP/1.1 404 Not Found
Content-Type: text/plain; charset=utf-8
X-Content-Type-Options: nosniff
Date: Thu, 21 Sep 2017 15:40:24 GMT
Content-Length: 19
```

Yes it was not a valid response with data, but the server gave us a `404` idnicating a response but no route defined... meaning the service is running!

Try the same process again with no running container:

```
$ curl -I http://localhost:8000
curl: (7) Failed to connect to localhost port 8000: Connection refused
```

The container is terminated, there is no route/connection and we get an error.
