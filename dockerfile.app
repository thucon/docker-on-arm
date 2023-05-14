FROM ubuntu:20.04

ARG HOME=/home/user

# install app dependencies
RUN apt update && apt install -y python3 python3-pip

# Create home endpoint
RUN mkdir -p ${HOME}/app
WORKDIR ${HOME}/app

# copy local sources into container
COPY app.py ${HOME}/app/app.py

# always run this command
ENTRYPOINT ["/usr/bin/python3", "/home/user/app/app.py"]