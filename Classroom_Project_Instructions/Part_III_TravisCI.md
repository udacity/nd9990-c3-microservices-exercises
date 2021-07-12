# Part 3 - Set up Travis continuous integration pipeline

Before you move on to the next step, deploying the multi-container application to the Kubernetes cluster, you need to set up a CI pipeline to build and push the images to the Dockerhub automatically (on commit to Github). 

<br data-md>

### Create Dockerhub repositories

Log in to https://hub.docker.com/ and create four public repositories - each repository corresponding to your local Docker images. The names of the repositories must be exactly the same as the **image name** specified in the *docker-compose-build.yaml* file:

* reverseproxy
* udagram-api-user
* udagram-api-feed
* udagram-frontend

### Set up Travis CI Pipeline

Use Travis CI pipeline to build and push images to your DockerHub registry. 

1. Sign in to https://travis-ci.com/ (not https://travis-ci.org/) using your Github account (preferred).


2. Integrate Github with Travis: Activate your GitHub repository with whom you want to set up the CI pipeline. 


3. Set up your Dockerhub username and password in the Travis repository's settings, so that they can be used inside of `.travis.yml` file while pushing images to the Dockerhub. 


4. Add a `.travis.yml` configuration file to the project directory (locally). In addition to the mandatory sections, your Travis file should automatically read the Dockerfiles, build images, and push images to DockerHub. For build and push, you can use either `docker-compose` or individual `docker build` commands as shown below. 
```bash
# Assuming the .travis.yml file is in the project directory, and there is a separate sub-directory for each service
# Use either `docker-compose` or individual `docker build` commands
# Build
  - docker build -t udagram-api-feed ./udagram-api-feed
# Do similar for other three images
```
```bash
# Tagging
  - docker tag udagram-api-feed sudkul/udagram-api-feed:v1
# Do similar for other three images```
```bash
# Push
# Assuming DOCKER_PASSWORD and DOCKER_USERNAME are set in the Travis repository settings
  - echo "$DOCKER_PASSWORD" | docker login -u "$DOCKER_USERNAME" --password-stdin
  - docker push sudkul/udagram-api-feed:v1
# Do similar for other three images
```
> **Tip**: Use different tags each time you push images to the Dockerhub.   


5. Trigger your build by pushing your changes to the Github repository. All of these steps mentioned in the `.travis.yml` file will be executed on the Travis worker node. It may take upto 15-20 minutes to build and push all four images.


6. Verify if the newly pushed images are now available in your Dockerhub account.


### Screenshots
So that we can verify your project’s pipeline is set up properly, please include the screenshots of the following:

- DockerHub showing images that you have pushed
- Travis CI showing a successful build job


### Troubleshoot

If you are not able to get through the Travis pipeline, and still want to push your local images to the Dockerhub (only for testing purposes), you can attempt the manual method. However, this is only for the troubleshooting purposes, such as **verifying the deployment to the Kubernetes cluster. **

* Log in to the Docker from your CLI, and tag the images with the name of your registry name (Dockerhub account username). 
```bash
# See the list of current images
docker images
# Use the following syntax
# In the remote registry (Dockerhub), we can have multiple versions of an image using "tags". 
# docker tag <local-image-name:current-tag> <registry-name>/<repository-name>:<new-tag>
docker tag <local-image:tag> <dockerhub-username>/<repository>:<tag>
```
* Push the images to the Dockerhub. 
```bash
docker login --username=<your-username>
# Use the "docker push" command for each image, or 
# Use "docker-compose -f docker-compose-build.yaml push" if the names in the compose file are as same as the Dockerhub repositories. 
```


