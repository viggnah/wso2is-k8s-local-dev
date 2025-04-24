# Local WSO2 IS 7.0.0 Kubernetes Deployment

A simple setup to deploy WSO2 Identity Server 7.0.0 on a local Kubernetes cluster (like Rancher Desktop) with **persistent H2 database storage**.

This configuration uses an **Init Container** to fix the common "Table UM_DOMAIN not found" error when starting WSO2 IS 7.0.0 with an empty persistent volume.

## Purpose

* Provides a quick way to get a **persistent** WSO2 IS 7.0.0 instance running locally on Kubernetes.
* Ideal for development and testing where data (users, apps) needs to survive pod restarts.
* Demonstrates the Init Container workaround for the H2 database initialization issue.

## Prerequisites

* Local Kubernetes Cluster (Tested with [Rancher Desktop](https://rancherdesktop.io/) on Mac M1 Sonoma 14.4.1)
* `kubectl` configured for your cluster.
* Default StorageClass supporting dynamic PV provisioning (most local clusters have this).
* `bash` shell (for scripts).

## Files

* `wso2is-manifest.yaml`: Contains all Kubernetes resources (Namespace, ConfigMap, PVC, Deployment, Service).
* `deployment.toml`: WSO2 IS configuration file. **Edit this file** for custom settings (e.g., port offset) before setup.
* `setup.sh`: Script to deploy WSO2 IS.
* `teardown.sh`: Script to remove the deployment.

## Quick Start

1.  **Clone:** `git clone <repository-url> && cd <repository-name>`
2.  **(Optional) Customize:** Edit `deployment.toml` if needed (e.g., `[server].offset`). Ensure ports in `wso2is-manifest.yaml` match! Default uses ports 9453/9773 (offset 10).
3.  **Deploy:**
    ```bash
    chmod +x setup.sh teardown.sh
    ./setup.sh
    ```
4.  **Access Console:** Wait for the script to confirm success, then access `https://localhost:9453/console` (or adjusted port). Login: `admin`/`admin`. Accept browser security warning for self-signed certificate.
5.  **Remove:**
    ```bash
    ./teardown.sh
    ```

## How it Works

* A dedicated `wso2is-local` namespace is created.
* A `ConfigMap` provides the `deployment.toml` to the pod.
* A `PersistentVolumeClaim` requests persistent storage for the H2 database.
* An `Init Container` runs first, copying the initial `.mv.db` files from the WSO2 IS image into the empty persistent volume.
* The main `Deployment` runs WSO2 IS, mounting the ConfigMap and the now-prepared persistent volume.
* A `LoadBalancer` Service exposes the instance on `localhost:9453` (requires LB support in your K8s tool).

## Manual Steps (Alternative)

* **Apply:** `kubectl apply -f wso2is-manifest.yaml`
* **Delete:** `kubectl delete -f wso2is-manifest.yaml`