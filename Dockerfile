FROM ubuntu:latest

RUN apt-get update \
 && apt-get install -y sudo curl ca-certificates git fish

ARG NETSKOPE_CERT
RUN if [ "${NETSKOPE_CERT}z" != "z" ];  then \
      echo "Installing Netskope MitM certificates" && \
      echo "${NETSKOPE_CERT}" >> /usr/local/share/ca-certificates/netskope.crt; \
      update-ca-certificates; \
    fi 

WORKDIR /app

COPY . .

RUN ./scripts/docker-test-wrapper-bash.sh

RUN ["devbox", "run", "echo", "installed"]
ENTRYPOINT ["devbox", "run"]
