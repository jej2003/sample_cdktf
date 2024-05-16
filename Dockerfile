
FROM redhat/ubi8

ARG CDKTF_VERSION=0.20.0
ARG TERRAFORMVERSION=1.8.0

RUN dnf -y install \
  vim \
  zip \
  cpio && \
  dnf module install -y nodejs:20 && \
  curl -k "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip" && \
  unzip awscliv2.zip && \
  ./aws/install && \
  curl -k https://releases.hashicorp.com/terraform/${TERRAFORMVERSION}/terraform_${TERRAFORMVERSION}_linux_amd64.zip -o terraform.zip && \
  unzip terraform.zip && rm -f terraform.zip && mv terraform /usr/bin/terraform && \
  npm install --global cdktf-cli@$CDKTF_VERSION

WORKDIR /opt/app

COPY . /opt/app

RUN echo 'plugin_cache_dir = "/var/cache/terraform_providers_cache"' > /root/.terraformrc \
    && echo 'provider_installation {' > /root/.terraformrc \
    && echo '  filesystem_mirror {' >> /root/.terraformrc \
    && echo '    path = "/root/.terraform.d/plugins/"' >> /root/.terraformrc \
    && echo '    include = ["*/*"]' >> /root/.terraformrc \
    && echo '  }' >> /root/.terraformrc \
    && echo '  direct {' >> /root/.terraformrc \
    && echo '    exclude = ["*/*"]' >> /root/.terraformrc \
    && echo '  }' >> /root/.terraformrc \
    && echo '}' >> /root/.terraformrc 

ENV DISABLE_VERSION_CHECK=1

RUN echo "export DISABLE_VERSION_CHECK=1" >> /root/.bashrc && \
  npm install && \
  cdktf synth && \
  cd $(ls -d /opt/app/cdktf.out/stacks/*|head -n 1) && \
  terraform providers mirror /root/.terraform.d/plugins/ && \
  rm -rf /opt/app/cdktf.out/

ENTRYPOINT ["cdktf"]
CMD ["--help"]

