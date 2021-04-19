FROM python:alpine
ARG TARGETPLATFORM
WORKDIR /srv
RUN apk add curl
RUN curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/${TARGETPLATFORM}/kubectl" && chmod +x kubectl && mv kubectl /usr/bin/kubectl
RUN curl -O https://dl.google.com/dl/cloudsdk/channels/rapid/downloads/google-cloud-sdk-336.0.0-linux-x86_64.tar.gz && tar -zxf google-cloud-sdk-336.0.0-linux-x86_64.tar.gz
RUN curl -Lo skaffold https://storage.googleapis.com/skaffold/builds/latest/skaffold-${TARGETPLATFORM/\//-} && mv skaffold /usr/bin/skaffold && chmod +x /usr/bin/skaffold
COPY run.sh /srv/run.sh
RUN mkdir -p /.config/gcloud && chown -R nobody:nogroup /.config && mkdir -p /.kube && chown -R nobody:nogroup /.kube && mkdir /srv/data
ENTRYPOINT ["/srv/run.sh"]

#
# docker buildx build --push --platform linux/arm64,linux/amd64 --tag ghcr.io/lukaszraczylo/gke-kubectl:latest .
#