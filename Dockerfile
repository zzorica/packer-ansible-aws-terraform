###
ARG ANSIBLE_VERSION="2.10.1"
ARG AWSCLI_VERSION="1.18.159"
ARG PACKER_VERSION="1.6.4"
ARG TERRAFORM_VERSION="0.13.4"
###

FROM alpine:3.9 AS builder
RUN set -eux \
        && apk add --no-cache \
                bc \
                gcc \
                libffi-dev \
                jq \
                make \
                musl-dev \
                openssl-dev \
                python3 \
                python3-dev
ARG ANSIBLE_VERSION="2.10.1"
ARG AWSCLI_VERSION="1.18.159"
ENV AWSCLI_VERSION=${AWSCLI_VERSION}
ENV ANSIBLE_VERSION=${ANSIBLE_VERSION}
RUN set -eux \
	&& if [ "${ANSIBLE_VERSION}" = "latest" ]; then \
		pip3 install --no-cache-dir --no-compile ansible; \
	else \
		pip3 install --no-cache-dir --no-compile ansible==${ANSIBLE_VERSION} awscli==${AWSCLI_VERSION}; \
	fi \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf

FROM hashicorp/packer:${PACKER_VERSION} AS packer
FROM hashicorp/terraform:${TERRAFORM_VERSION} AS terraform

FROM alpine:3.9 as stage
RUN set -eux \
	&& apk add --no-cache python3 bash git jq openssh \
	&& ln -sf /usr/bin/python3 /usr/bin/python \
	&& ln -sf ansible /usr/bin/ansible-config \
	&& ln -sf ansible /usr/bin/ansible-console \
	&& ln -sf ansible /usr/bin/ansible-doc \
	&& ln -sf ansible /usr/bin/ansible-galaxy \
	&& ln -sf ansible /usr/bin/ansible-inventory \
	&& ln -sf ansible /usr/bin/ansible-playbook \
	&& ln -sf ansible /usr/bin/ansible-pull \
	&& ln -sf ansible /usr/bin/ansible-test \
	&& ln -sf ansible /usr/bin/ansible-vault \
	&& find /usr/lib/ -name '__pycache__' -print0 | xargs -0 -n1 rm -rf \
	&& find /usr/lib/ -name '*.pyc' -print0 | xargs -0 -n1 rm -rf
COPY --from=builder /usr/lib/python3.6/site-packages/ /usr/lib/python3.6/site-packages/
COPY --from=builder /usr/bin/ansible /usr/bin/ansible
COPY --from=builder /usr/bin/ansible-connection /usr/bin/ansible-connection
COPY --from=builder /usr/bin/aws /usr/bin/aws
COPY --from=packer /bin/packer /usr/bin/packer
COPY --from=terraform /bin/terraform /usr/bin/terraform

FROM scratch
###
ARG VERSION="latest"
ARG ANSIBLE_VERSION="2.10.1"
ARG AWSCLI_VERSION="1.18.159"
ARG PACKER_VERSION="1.6.4"
ARG TERRAFORM_VERSION="0.13.4"
###
LABEL maintainer="Zoran Zorica <zzorica@soultrace.net>"
LABEL packer_version=${PACKER_VERSION}
LABEL terraform_version=${TERRAFORM_VERSION}
LABEL ansible_version=${ANSIBLE_VERSION}
LABEL awscli_version=${AWSCLI_VERSION}

#ADD VERSION .
COPY --from=stage / /
WORKDIR /opt
ENTRYPOINT []
CMD    ["/bin/bash"]
