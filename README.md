# Container with ansible, packer, aws and terraform CLI tools
Image created for the purpose of CI/CD tools. 

For example in circleci pipeline to automatically create packer images provisioned by ansible and then uploaded to aws.

In dockerfile you can specify which version of the tools you need

```
ARG ANSIBLE_VERSION="2.10.1"
ARG AWSCLI_VERSION="1.18.159"
ARG PACKER_VERSION="1.6.4"
ARG TERRAFORM_VERSION="0.13.4"
```
