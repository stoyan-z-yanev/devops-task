# DEVOPS exercise statement 1

## Solution
For this solution I used python and fastapi to create the backend with 2 endpoints. Docker image is created and pushed to repository using github actions. The backend uses a real API(https://api.coingecko.com/api/v3/coins/markets) to get random data and then populate it in the DB.

- The helm charts are currently local. In a Project I would make a pipeline to push them to repository like AWS S3.
- I made use of multi-stage builds to further optimize the Dockerfile and have only the necessary dependencies.
- For the db schema, bitnami supports init.sql which I made use of.
- The helm chart deploys an ingress resource with the two routes for /populate and /delete.

## Prerequisites
The easist way to test the helm chart is to deploy it on Minikube and enable ingress addon

## Creating secret for the backend:
In order to pull the image for the backend, which is initially pushed by github action (docker-build.yaml). We need to create a ghcr secret with PAT 

```  
kubectl create secret docker-registry ghcr-secret \
  --docker-server=ghcr.io \
  --docker-username=<YOUR_GITHUB_USERNAME> \
  --docker-password=<YOUR_GHCR_PAT> \
  --docker-email=<YOUR_EMAIL>

```
Once we have the secret we can package and install our helm chart

```
helm dependency build
helm package .
helm upgrade -i my-app ./backend-0.1.3.tgz --set postgresql.auth.password=testpass --set pgadmin.env.email=admin@admin.com --set pgadmin.env.password=testpass --set pgadmin.enabled=true
```
Due to time restrictions I am passing the values with --set, in normal scenario I would store them in AWS SSM, and use the parameter store operator to pull the data into the chart.

## How to validate the app

After the helm chart is deployed , you can use "minikube tunnel" to expose the ingress and curl the two endpoints.

```
curl --location --request POST 'localhost/populate''
curl --location --request DELETE 'localhost/delete'
```

You can see the changes with the PG UI.

## Final Thoughts 

- I have added helm-example dir, where I have showcased a chart which I have written in the past
- I have also added terraform dir, which is not a module, but something that I have written for a small project. Looking at it now, I would definately extract the logic in terraform modules - vpc, rds, dashboards and pass some of the values in more dynamic ways.
