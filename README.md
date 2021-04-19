# Google Cloud GKE docker kubectl

- [Google Cloud GKE docker kubectl](#google-cloud-gke-docker-kubectl)
    - [Purpose](#purpose)
    - [Really important thing](#really-important-thing)
    - [Preinstalled binaries](#preinstalled-binaries)
    - [Example usage](#example-usage)
      - [In Docker](#in-docker)
      - [In Kubernetes](#in-kubernetes)

### Purpose

I've created this project with the sole purpose of enabling port forwarding from my GKE cluster into the
test cluster I've been running locally. It should support most of the functions ( except of pre-compiled binaries like Anthos ),
although due to Google Cloud SDK being closed source I am unable to verify what exactly works.

*This image supports both ARM64 and AARCH64 ( raspberry Pi 4 ) architectures.*

This docker image works fine with Kubernetes and local run and requires supplying following environment variables to set up the configuration.

* *GCP_PROJECT:* Your GCP project name
* *GCP_CLUSTER:* Your GKE cluster name
* *GCP_REGION:* Your GKE cluster region
* *GOOGLE_APPLICATION_CREDENTIALS:* Your GCP credentials JSON file path

### Really important thing
Please make sure that Docker NETWORK is set to HOST ( which unfortunately does not work too well on Macs ), otherwise `gcloud` have issues with reaching the cluster endpoint for kubectl.
( Yes, took me few hours to figure it out so I'm trying to save your time here ).

### Preinstalled binaries

* Google Cloud SDK
* Kubectl
* Skaffold

If you'd like to mount directories ( for example for skaffold ) I'd recommend `-v $PATH/skaffold:/srv/data`.

### Example usage

#### In Docker

```bash
docker run
  --network host \
  -v $(echo $HOME)/.gcp/cred.json:/srv/.kube/gcp.json \
  -e GOOGLE_APPLICATION_CREDENTIALS=/srv/.kube/gcp.json \
  -e GCP_PROJECT=myGCPProjectName -e GCP_CLUSTER=myGKEClusterName \
  -e GCP_REGION=europe-west1-a \
  -it ghcr.io/lukaszraczylo/docker-gcp-kubectl:latest \
  kubectl port-forward --address 0.0.0.0 -n myProjectNamespace service/tgnats-client 4222:4222
```

#### In Kubernetes

```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: tg7-fwd-live
  labels:
    app: tg7-fwd-live
    type: support
  namespace: tg7
spec:
  replicas: 1
  selector:
    matchLabels:
      app: tg7-fwd-live
      type: support
  template:
    metadata:
      labels:
        app: tg7-fwd-live
        type: support
    spec:
      volumes:
        - name: kubefwd-storage
          persistentVolumeClaim:
            claimName: nfs-shared-pvc
      securityContext:
        runAsUser: 65534 # nobody
      hostNetwork: true
      imagePullSecrets:
      - name: docker-ghcr
      containers:
      - name: tg7-fwd-live
        image: ghcr.io/lukaszraczylo/docker-gcp-kubectl:latest
        ports:
          - name: fwd-nats-pt
            containerPort: 4222
        volumeMounts:
          - mountPath: /srv/.kube
            name: kubefwd-storage
            subPath: kube-fwd
        args: ["kubectl", "port-forward", "--address", "0.0.0.0", "-n", "tg", "service/tgnats-client", "4222:4222"]
        env:
          - name: GOOGLE_APPLICATION_CREDENTIALS
            value: /srv/.kube/gcp.json
          - name: GCP_PROJECT
            value: MyGCPProject
          - name: GCP_CLUSTER
            value: MyGKECluster
          - name: GCP_REGION
            value: europe-west1-a
---
apiVersion: v1
kind: Service
metadata:
  namespace: tg7
  name: nats-fwd-cli
spec:
  ports:
  - name: nats-fwd-pt
    port: 4222
    targetPort: 4222
  selector:
    app: tg7-fwd-live
    type: support
```