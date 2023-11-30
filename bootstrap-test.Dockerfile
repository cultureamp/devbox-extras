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

ARG SHELL_VAR
RUN "./test/docker-test-wrapper-$SHELL_VAR.sh"

RUN ["devbox", "run", "echo", "installed"]
ENTRYPOINT ["devbox", "run"]
