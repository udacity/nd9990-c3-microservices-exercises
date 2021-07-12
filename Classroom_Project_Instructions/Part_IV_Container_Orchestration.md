# Part 4 - Container Orchestration with Kubernetes

For the current part, verify that you have the `kubectl` utility installed locally:
```bash
kubectl version --short
```
In addition, you will create a Kubernetes cluster either via the AWS web console or optionally use the <a href="https://eksctl.io/introduction/#installation" target="_blank">EKSCTL</a> utility, more details to follow below. 


### Create a Kubernetes cluster in AWS EKS service
Create a** public **Kubernetes cluster and create and attach the nodegroup to the cluster. Decide the nodegroup size and configuration as you find suitable. You can use either the 
1. AWS web console or 

2. [Optional] EKSCTL, a command-line utility to create an EKS cluster and the associated resources in a single command. 
```bash
# Feel free to use the same/different flags as you like
eksctl create cluster --name myCluster --region=us-east-1 --version=1.18 --nodes-min=2 --nodes-max=3
# Recommended: You can see many more flags using "eksctl create cluster --help" command.
# For example, you can set the node instance type using --node-type flag
```
The default command above will set the following for you:
  - An auto-generated name
  - Two m5.large worker nodes. Recall that the worker nodes are the virtual machines, and the m5.large type defines that each VM will have 2 vCPUs, 8 GiB memory, and up to 10 Gbps network bandwidth.
  - Use the Linux AMIs as the underlying machine image
  - An autoscaling group with [2-3] nodes
  - Importantly, it will write cluster credentials to the default config file locally. Meaning, EKSCTL will set up KUBECTL to communicate with your cluster. If you'd have created the cluster using the web console, you'll have to set up the *kubeconfig* manually. 

 ```bash
 # Once you get the success confirmation, run
 kubectl get nodes
 ```
> Known issue: Sometimes, the cluster creation may fail in the **us-east-1** region. In such a case, use `--region=us-east-2` flag.

 If you run into issues, either go to your CLoudFormation console or run:
```bash
eksctl utils describe-stacks --region=us-east-1 --cluster=myCluster
```
>**Known issue**: In `us-east-1` you are likely to get *UnsupportedAvailabilityZoneException*. Try another region in such a case. 


### Deployment

In this step, you will deploy the Docker containers for the frontend web application and backend API applications in their respective pods.

Recall that while splitting the monolithic app into microservices, you used the values saved in the environment variables, as well as AWS CLI was configured locally. Similar values are required while instantiating containers from the Dockerhub images. 

1. **ConfigMap:** Create *env-configmap.yaml*, and save all your configuration values (non-confidential environments variables) in that file. 


2. **Secret: **Do not store the PostgreSQL username and passwords in the *env-configmap.yaml* file. Instead, create *env-secret.yaml* file to store the confidential values, such as login credentials. 


3. **Secret: **Create *aws-secret.yaml* file to store your AWS login credentials. Replace `___INSERT_AWS_CREDENTIALS_FILE__BASE64____` with the Base64 encoded credentials (not the regular username/password). 
     * Mac/Linux users: If you've configured your AWS CLI locally, check the contents of *~/.aws/credentials* file using `cat ~/.aws/credentials` . It will display the *aws_access_key_id* and *aws_secret_access_key* for your AWS profile(s). Now, you need to select the applicable pair of *aws_access_key* from the output of the `cat` command above and convert that string into `base64` . You use commands, such as:
```bash
# Use a combination of head/tail command to identify lines you want to convert to base64
# You just need two correct lines: a right pair of aws_access_key_id and aws_secret_access_key
cat ~/.aws/credentials | tail -n 5 | head -n 2
# Convert 
cat ~/.aws/credentials | tail -n 5 | head -n 2 | base64
```
     * **Windows users:** Copy a pair of *aws_access_key* from the AWS credential file and paste it into the encoding field of this third-party website: https://www.base64encode.org/ (or any other). Encode and copy/paste the result back into the *aws-secret.yaml*  file.

<br data-md>


4. **Deployment configuration:** Create *deployment.yaml* file individually for each service. While defining container specs, make sure to specify the same images you've pushed to the Dockerhub earlier. Ultimately, the frontend web application and backend API applications should run in their respective pods.

5. **Service configuration: **Similarly, create the *service.yaml* file thereby defining the right services/ports mapping.


Once, all deployment and service files are ready, you can use commands like:
```bash
# Apply env variables and secrets
kubectl apply -f aws-secret.yaml
kubectl apply -f env-secret.yaml
kubectl apply -f env-configmap.yaml
# Deployments - Double check the Dockerhub image name and version in the deployment files
kubectl apply -f backend-feed-deployment.yaml
# Do the same for other three deployment files
# Service
kubectl apply -f backend-feed-service.yaml
# Do the same for other three service files
```
Make sure to check the image names in the deployment files above. 



## Connecting k8s services to access the application

If the deployment is successful, and services are created, there are two options to access the application:
1. If you deployed the services as CLUSTERIP, then you will have to [forward a local port to a port on the "frontend" Pod](https://kubernetes.io/docs/tasks/access-application-cluster/port-forward-access-application-cluster/#forward-a-local-port-to-a-port-on-the-pod). In this case, you don't need to change the URL variable locally. 


2. If you exposed the "frontend" deployment using a Load Balancer's External IP, then you'll have to update the URL environment variable locally, and re-deploy the images with updated env variables. 

Below, we have explained method #2, as mentioned above. 

### Expose External IP

Use this link to <a href="https://kubernetes.io/docs/tutorials/stateless-application/expose-external-ip-address/" target="_blank">expose an External IP</a> address to access your application in the EKS Cluster.

```bash
# Check the deployment names and their pod status
kubectl get deployments
# Create a Service object that exposes the frontend deployment:
kubectl expose deployment frontend --type=LoadBalancer --name=publicfrontend
kubectl get services publicfrontend
# Note down the External IP, such as 
# a5e34958a2ca14b91b020d8aeba87fbb-1366498583.us-east-1.elb.amazonaws.com
# Check name, ClusterIP, and External IP of all deployments
kubectl get services 
```


### Update the environment variables 

Once you have the External IP of your front end and reverseproxy deployment, Change the API endpoints in the following places locally:

* Environment variables - Replace the http://**localhost**:8100 string with the Cluster-IP of the *frontend* service.  After replacing run `source ~/.zshrc` and verify using `echo $URL`



*  *udagram-deployment/env-configmap.yaml* file - Replace http://localhost:8100 string with the Cluster IP of the *frontend*. 



* *udagram-frontend/src/environments/environment.ts* file - Replace 'http://localhost:8080/api/v0' string with either the Cluster IP of the *reverseproxy* deployment.  



*  *udagram-frontend/src/environments/environment.prod.ts* - Replace 'http://localhost:8080/api/v0' string. 



* Retag in the `.travis.yaml` (say use v3, v4, v5, ...) as well as deployment YAML files

Then, push your changes to the Github repo. Travis will automatically build and re-push images to your Dockerhub. 
Next, re-apply configmap and re-deploy to the k8s cluster.
```bash
kubectl apply -f env-configmap.yaml
# Rolling update "frontend" containers of "frontend" deployment, updating the image
kubectl set image deployment frontend frontend=sudkul/udagram-frontend:v3
# Do the same for other three deployments
```
Check your deployed application at the External IP of your *publicfrontend* service. 

>**Note**: There can be multiple ways of setting up the deployment in the k8s cluster. As long as your deployment is successful, and fulfills [Project Rubric](https://review.udacity.com/#!/rubrics/2804/view), you are good go ahead!

## Troubleshoot
1. Use this command to see the STATUS of your pods:
```bash
kubectl get pods
kubectl describe pod <pod-id>
# An example:
# kubectl logs backend-user-5667798847-knvqz
# Error from server (BadRequest): container "backend-user" in pod "backend-user-5667798847-knvqz" is waiting to start: trying and failing to pull image
```
In case of `ImagePullBackOff` or `ErrImagePull` or `CrashLoopBackOff`, review your deployment.yaml file(s) if they have the right image path. 


2. Look at what's there inside the running container. [Open a Shell to a running container](https://kubernetes.io/docs/tasks/debug-application-cluster/get-shell-running-container/) as:
```bash
kubectl get pods
# Assuming "backend-feed-68d5c9fdd6-dkg8c" is a pod
kubectl exec --stdin --tty backend-feed-68d5c9fdd6-dkg8c -- /bin/bash
# See what values are set for environment variables in the container
printenv | grep POST
# Or, you can try "curl <cluster-IP-of-backend>:8080/api/v0/feed " to check if services are running.
# This is helpful to see is backend is working by opening a bash into the frontend container
```


3. When you are sure that all pods are running successfully, then use developer tools in the browser to see the precise reason for the error. 
  - If your frontend is loading properly, and showing *Error: Uncaught (in promise): HttpErrorResponse: {"headers":{"normalizedNames":{},"lazyUpdate":null,"headers":{}},"status":0,"statusText":"Unknown Error"....*, it is possibly because the *udagram-frontend/src/environments/environment.ts* file has incorrectly defined the ‘apiHost’ to whom forward the requests. 
  - If your frontend is **not** not loading, and showing *Error: Uncaught (in promise): HttpErrorResponse: {"headers":{"normalizedNames":{},"lazyUpdate":null,"headers":{}},"status":0,"statusText":"Unknown Error", ....* , it is possibly because URL variable is not set correctly. 
  - In the case of *Failed to load resource: net::ERR_CONNECTION_REFUSED* error as well, it is possibly because the URL variable is not set correctly. 


4. Use the Postman tool to evaluate backend APIs. This is particularly useful when you get CORS-related errors. In the worst case, you can make `origin: "*"` in the */src/server.ts* files for */feed* and */user* services. Though, it's not a recommended practice in production. So, once it works with `origin: "*"`, you must figure out how to make it work for a specific frontend URL. 


## Screenshots

So that we can verify that your project is deployed, please include the screenshots of the following commands with your completed project. 
```bash
# Kubernetes pods are deployed properly
kubectl get pods 
# Kubernetes services are set up properly
kubectl describe services
# You have horizontal scaling set against CPU usage
kubectl describe hpa
```


## Clean up
1. Delete the EKS cluster. If you have used the EKSCTL utility, then use:
```bash
eksctl delete cluster --name=myCluster
```
2. Delete the S3 bucket and RDS PostgreSQL database. 








