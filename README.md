# Norsebank Accounts Demo App

This repository contains the Norsebank Accounts Demo application, which includes both backend and frontend components. The backend is written in Java and the frontend in JavaScript.

## Prerequisites
- An existing Kubernetes cluster with Istio enabled & [Gateway CRDs](https://gateway-api.sigs.k8s.io/guides/#getting-started-with-gateway-api) installed
- kubectl configured to interact with your Kubernetes cluster
- Terraform installed on your local machine
- A Styra DAS instance with an [API token](https://docs.styra.com/das/administration/token-management/create-api-token) created

## Setting Up a Local Minikube Cluster

If you don't have a Kubernetes cluster available, you can set up a local Minikube cluster:

### 1. Install Minikube
Follow the instructions to install Minikube from the [official documentation](https://minikube.sigs.k8s.io/docs/start/).

### 2. Start Minikube with Istio
```bash
minikube start --cpus=4 --memory=8192 --addons=istio,istio-provisioner
```

### 3. Verify Minikube Installation
```bash
kubectl get pods -n istio-system
```

## Setup Instructions

### 1. Clone the Repository
```bash
git clone https://github.com/kroekle/accounts-demo-app.git
cd accounts-demo-app
```

### 2. Configure Terraform
Navigate to the directory containing the Terraform scripts for setting up the demo app.

### 3. Initialize and Apply Terraform Scripts
```bash
cd terraform
terraform init
terraform apply
```
Make sure to provide the required variables (these can be set in a terraform.tfvars file).

  * bearer_token (DAS API token)
  * server_url (DAS tentant url e.g. https://TENANT.styra.com)
  * kube_config (default: ~/.kube/config)
  * kube_context (default: default)
  * eopa_license_key
  * application_host (default: accounts.norsebank.com)

### 4. Verify Deployment
Use the following command to verify that the services are running in your Kubernetes cluster:
```bash
kubectl get pods -n accounts-demo
```

There should also be two new Systems and one new Stack in your DAS tenant.
   * Norsebank US Accounts (system)
   * Norsebank Global Accounts (System)
   * Norsebank All Accounts (Stack)

### 5. Using the app
Ingressing to the application will be dependant on how your cluster is setup.  A working UI will look like the the following:

![Demo UI](./demoApp.png)

#### Ingressing with minikube
If you are using minikube the following step should work for you (tested on an Intel Mac)
Get the gateway ip address

```bash
kubectl get gateways.gateway.networking.k8s.io gateway -n accounts-demo -ojsonpath='{.status.addresses[0].value}'
```

Add this to your hosts file with the host name provided for the app (the default is accounts.norsebank.com)

```bash
127.0.0.1       accounts.norsebank.com
```
Start the minikube tunnel (in my experience each time you destroy/create the entire terraform script the tunnel needs to be restarted)

```bash
minikube tunnel
```
Now you should be able to go to the host in your browser (and curl the endpoints)

## Understanding the application
The application is designed to be a true demostration of application Authz policies at mutliple layers in a ReactJS/Java application.  The application is setup like the following:

![app arch](./AppArch.png)

### APIs
Each service has the same APIs defined with the only difference being the name of the object (v1/accounts for us, v1/gaccounts for global).  The application has the following API paths:
   * GET / - list all accounts
   * GET /{id} - find by account id
   * DELETE /{id] - close account
   * PATCH /{id] - reopen account
   * POST /txfr/{fromId}/{toId}/{amount} - transfer funds between accounts

### Policy structure
The DAS systems and stacks have policy/ingress policies that will authorize both API calls and UI checks with allow & deny rules.  The policy/ui rules has a predefined "check" rule for the UI to call for checking UI Authz, this rule delegates to the policy/ingress rules.

### SQL filtering
The application is checking two special headers that it uses for filtering sql calls.  These headers are "x-max-balance" and "x-blocked-regions".  The max balance header expects a single string represented number.  The blocked regions header will take a list of string separated by a semi-colon (;).  Each of these are optional, but if present, they will be used in the sql call when listing all accounts.

### JWT tokens
The JWT tokens are signed with the passphrase "super-secret".  You can decode the claims with the following code:
```rego
claims := payload if {
  io.jwt.verify_hs256(bearer_token, "super-secret")
  [_, payload, _] := io.jwt.decode(bearer_token)
}

bearer_token := t if {
  v := input.attributes.request.http.headers.authorization
  startswith(v, "Bearer ")
  t := substring(v, count("Bearer "), -1)
}
```

### Sample Rules

Allow closing of accounts for Alice
```rego
allow if {
  input.attributes.request.http.method == "DELETE"
  input.parsed_path = ["v1", _, account_id]
  claims.sub == "5002"
}
```



## Additional Information
For more information, refer to the individual README files in the `accounts-service` and `accounts-ui` directories.
