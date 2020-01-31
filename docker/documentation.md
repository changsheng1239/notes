---
title: 'Docker documentation'
tags: 'docker'
---

Docker documentation
===

Installation
---
### Docker For Linux Installation (Debian amd64)
[Snippet](https://git.dev.sql.com.my/snippets/26)
```bash=
sudo apt-get update
sudo apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    gnupg2 \
    software-properties-common
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo apt-key add -
sudo apt-key fingerprint 0EBFCD88
sudo add-apt-repository \
   "deb [arch=amd64] https://download.docker.com/linux/debian \
   $(lsb_release -cs) \
   stable"
sudo apt-get update
sudo apt-get install -y docker-ce docker-ce-cli containerd.io
sudo curl -L "https://github.com/docker/compose/releases/download/1.24.0/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
sudo chmod +x /usr/local/bin/docker-compose
sudo ln -s /usr/local/bin/docker-compose /usr/bin/docker-compose
```
```bash
curl -s https://git.dev.sql.com.my/snippets/26/raw | bash 
```

[Full Guide](https://docs.docker.com/install/linux/docker-ce/debian/)

---

### Docker Toolbox Installation (Win 10 Home)
1. [Change default directory for Docker Toolbox](https://stackoverflow.com/a/37246965)
2. [Download](https://docs.docker.com/toolbox/overview/)
3. [Docker toolbox installation guide](https://docs.docker.com/toolbox/toolbox_install_windows/)



#### Mount shared folder into docker-machine
```
1. docker-machine stop
2. Add a shared folder in VirtualBox with a proper folder name and auto-mount checked (e.g. Docker)
3. docker-machine start
4. docker-machine ssh
5. mkdir projects (pwd: /home/docker/projects)
6. sudo mount -t vboxsf -o uid=1000,gid=50 Docker /home/docker/projects
7. sudo vi /mnt/sda1/var/lib/boot2docker/profile
8. add 2 lines:
    mkdir /home/docker/projects
    sudo mount -t vboxsf -o uid=1000,gid=50 Docker /home/docker/projects
```
[Full Guide](http://support.divio.com/local-development/docker/how-to-use-a-directory-outside-cusers-with-docker-toolboxdocker-for-windows)

#### Issues
> Problem looking for vboxmanage.exe

Make sure the path in environment variable is system wide.

---
Dockerfile
---
### Sample
```dockerfile=
# Use an official Python runtime as a parent image
FROM python:2.7-slim

# Set the working directory to /app
WORKDIR /app

# Copy the current directory contents into the container at /app
COPY . /app

# Install any needed packages specified in requirements.txt
RUN pip install --trusted-host pypi.python.org -r requirements.txt

# Make port 80 available to the world outside this container
EXPOSE 80

# Define environment variable
ENV NAME World

# Run app.py when the container launches
CMD ["python", "app.py"]
```

### Multi-stage build
```dockerfile=
# Dockerfile References: https://docs.docker.com/engine/reference/builder/

# Start from golang v1.11 base image
FROM golang:1.12 as builder

# Set the Current Working Directory inside the container
WORKDIR /app

# Copy everything from the current directory to the PWD(Present Working Directory) inside the container
COPY . .

# Download dependencies
RUN go get -d -v ./...

# Build the Go app with static linked library
RUN CGO_ENABLED=0 GOOS=linux go build -a -installsuffix cgo -o /go/bin/main .

######## Start a new stage from scratch #######
FROM alpine:latest  

RUN apk --no-cache add ca-certificates

WORKDIR /root/

# Copy the Pre-built binary file from the previous stage
COPY --from=builder /go/bin/main .

CMD ["./main"]
```
---
docker-compose.yml
---
### Sample
```dockerfile=
version: '2'

services:
  novel_backend:
    restart: unless-stopped
    build:
      context: ..
      dockerfile: docker/novel_backend/Dockerfile
    depends_on:
      - redis
      - db
    ports:
      - "8002:8002"
    environment:
      DB_PROTOCOL: tcp
      DB_HOST: db:3306
      DB_USERNAME: admin
      DB_PASSWORD: p@ssw0rd
      DB_NAME: novel
      APP_PORT: 8002
      REDIS_HOST: redis:6379

  db:
    restart: unless-stopped
    image: mariadb
    volumes:
      - "novel_mariadb:/var/lib/mysql"
      - "./db:/docker-entrypoint-initdb.d"
    environment:
      MYSQL_ROOT_PASSWORD: p@ssw0rd
      MYSQL_DATABASE: novel
      MYSQL_USER: admin
      MYSQL_PASSWORD: p@ssw0rd

  redis:
    restart: unless-stopped
    image: redis:5-alpine
    volumes:
      - "novel_redis:/data"

volumes:
  novel_redis:
  novel_mariadb:
```
> docker-compose --project-name name up -d --build

MySQL backup and restore from container
---
### Backup
```bash
docker exec CONTAINER /usr/bin/mysqldump -u root --password=root DATABASE > backup.sql
```
### Restore
```bash
cat backup.sql | docker exec -i CONTAINER /usr/bin/mysql -u root --password=root DATABASE
```
---
Docker Command
---
### Images
#### Create image using this directory's Dockerfile
    docker build -t image_name .  
#### List all images
    docker images ls -a
#### Remove specified image 
    docker image rm <image id>
#### Remove all images
    docker rmi $(docker image ls -aq)
#### Remove dangling images
    docker rmi $(docker images -f "dangling=true" -q)
---
### Containers
#### Run "image" mapping port 4000 to 80 with name in detached mode
    docker run -d -p 4000:80 --name my_container image
#### List all running containers
    docker container ls / docker ps 
#### List all containers including those not running
    docker container ls -a / docker ps -a
#### Gracefully stop the specified container
    docker container stop <hash>
#### Force shutdown the specified container
    docker container kill <hash>
#### Remove specified container
    docker container rm <hash>
#### Remove all containers
    docker container rm $(docker ps -aq)
#### Force remove all containers (even it's running)
    docker container rm -f $(docker ps -aq)
#### Attach into container's bash
    docker exec -it <container_id> bash
---
### Registry
#### Login docker CLI
    docker login
#### Tag an image for upload to registry
    docker tag <image> username/repo:tag
#### Upload image to registry
    docker push username/repo:tag
#### Run image from a registry
    docker run username/repo:tag
---
### Stack
#### List stacks or apps
    docker stack ls
#### Run the specified Compose file
    docker stack deploy -c <composefile> <appname>
#### View all tasks of a stack
    docker stack ps <appname>
#### Tear down an app
    docker stack rm <appname>
---
### Service
#### List running services associated with an app
    docker service ls
#### List task associated with an app
    docker service ps <service>
---
### Nginx
#### Reload nginx
    docker kill -s HUP <container>
---