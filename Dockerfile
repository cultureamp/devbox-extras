FROM ubuntu:latest

RUN apt-get update \
 && apt-get install -y sudo curl ca-certificates git

ARG NETSKOPE_CERT
RUN if [ "${NETSKOPE_CERT}z" != "z" ];  then \
      echo "Installing Netskope MitM certificates" && \
      echo "${NETSKOPE_CERT}" >> /usr/local/share/ca-certificates/netskope.crt; \
      update-ca-certificates; \
    fi 

WORKDIR /app

COPY . .

# Wrap and run bootstrap
RUN ./mock_functions.sh

# CMD command 
# TODO: introduce optionality for individual shell tests
CMD ["devbox", "run", "bats", "test"]
