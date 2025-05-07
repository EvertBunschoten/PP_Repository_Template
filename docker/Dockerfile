FROM ubuntu:latest
ENV LANG=C.UTF-8
RUN apt-get update && apt-get install -y \
    python3 \
    git \
    build-essential \
    ccache && \ 
    apt-get update && \
    apt-get install -y python3-virtualenv && \
    apt-get install -y python3.12-venv 

# Copies your code file from your action repository to the filesystem path `/` of the container
COPY runCode.sh /runCode.sh

ENTRYPOINT ["/runCode.sh"]