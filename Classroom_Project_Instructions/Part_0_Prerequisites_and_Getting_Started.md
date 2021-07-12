# Overview - Udagram Image Filtering Microservice
The project application, **Udagram** - an Image Filtering application, allows users to register and log into a web client, post photos to the feed, and process photos using an image filtering microservice. It has two components:
1. Frontend - Angular web application built with Ionic framework
2. Backend RESTful API - Node-Express application

In this project you will:
- Refactor the monolith application to microservices
- Set up each microservice to be run in its own Docker container
- Set up a Travis CI pipeline to push images to Dockerhub
- Deploy the Dockerhub images to the Kubernetes cluster


# Prerequisites
You should have the following tools installed in your local machine:

* <a href="https://git-scm.com/downloads" target="_blank">Git</a> for Mac/Linux/Windows. 
>Windows users: Once you download and install Git for Windows, you can execute all the bash, ssh, git commands in the **Gitbash** terminal. Whereas Windows users using [Windows Subsystem for Linux](https://docs.microsoft.com/en-us/windows/wsl/about) (WSL) can follow all steps as if they are Linux users.


* The following will help you run your project locally as a monolithic application.
   1. PostgreSQL **client**, the `psql` command line utility, installed locally. 
We will set the PostgreSQL server up in the AWS cloud. The client will help you to connect with the server. Usually, the client comes along with the [PostgreSQL](https://www.postgresql.org/download/) server installation, but you can install only the client using:
```bash
# Mac OS
brew install libpq  
brew link --force libpq 
# Ubuntu
sudo apt-get install postgresql-client
# Windows, you need to install the complete server
```
Otherwise, see the complete (server and client) installation instructions for [Mac](https://www.postgresqltutorial.com/install-postgresql-macos/), [Linux](https://www.postgresqltutorial.com/install-postgresql-linux/), and [Windows](https://www.postgresqltutorial.com/install-postgresql/). 
   2. <a href="https://nodejs.org/en/download/" target="_blank">NodeJS</a> v12.14 or higher up to 13 - NodeJS installer will install both Node.js and npm on your system. Verify using the commands:
```bash
# v12.14 or higher up to 13
node -v 
# v7.19 or higher
npm -v
# You can upgrade to the latest version of npm using:
npm install -g npm@latest
```
   3. [Ionic command-line utility v6](https://ionicframework.com/docs/installation/cli) or higher framework to build and run the frontend application locally. Verify the installation as:
```bash
# v6.0 or higher
ionic --version
# Otherwise, install a fresh version using
npm install -g @ionic/cli
```

* <a href="https://docs.docker.com/desktop/#download-and-install" target="_blank">Docker Desktop</a> for running the project locally in a multi-container environment

* <a href="https://docs.aws.amazon.com/cli/latest/userguide/install-cliv2.html" target="_blank">AWS CLI v2</a> for interacting with AWS services via your terminal. After installing the AWS CLI, you will also have to configure the access profile locally. 
   * Create an IAM user with Admin privileges on the AWS web console. Copy its Access key. 
   * Configure the access profile locally using the Access key generated above:
   ```bash
   aws configure [--profile nd9990]
   ```
* <a href="https://kubernetes.io/docs/tasks/tools/#kubectl" target="_blank">Kubectl</a> command-line utility to create and communicate with Kubernetes clusters

In addition to the tools above, fork and then clone the project starter code from the <a href="https://github.com/udacity/nd9990-c3-microservices-exercises/tree/master/project" target="_blank">Udacity GitHub repository</a>.



# Getting started
To understand how you project will be assessed, see the <a href="https://review.udacity.com/#!/rubrics/2804/view" target="_blank">Project Rubric</a>

Let's begin with setting up the resources that you will need while running the application either locally or on the cloud. 

## Set up an S3 bucket to store pictures
The steps you need to follow are:

1. Create a public S3 bucket with default configuration, such as no versioning and disabled encryption. 
1. Once your bucket is created, go to the **Permissions** tab. Add bucket policy allowing other AWS services (Kubernetes) to access the bucket contents. You can use the <a href="https://awspolicygen.s3.amazonaws.com/policygen.html" target="_blank">policy generator</a> tool to generate such an IAM policy. See an example below (change the bucket name in your case).
```json
{
 "Version":"2012-10-17",
 "Statement":[
     {
         "Sid":"Stmt1625306057759",
         "Principal":"*",
         "Action":"s3:*",
         "Effect":"Allow",
         "Resource":"arn:aws:s3:::test-nd9990-dev-wc"
     }
 ]
}
```

1. Add the <a href="https://docs.aws.amazon.com/AmazonS3/latest/userguide/ManageCorsUsing.html#cors-example-1" target="_blank">CORS configuration</a> to allow the application running outside of AWS to interact with your bucket. You can use the following configuration:
```json
[
	{
		"AllowedHeaders":[
			"*"
		],
		"AllowedMethods":[
			"POST",
			"GET",
			"PUT",
			"DELETE",
			"HEAD"
		],
		"AllowedOrigins":[
			"*"
		],
		"ExposeHeaders":[
			
		]
	}
]
```


 Note: In the S3 console, the CORS configuration must be JSON format. Whereas, the CLI can use either JSON or XML format.

4. Once the policies above are set, you can disable public access to your bucket.

## Set up AWS RDS - PostgreSQL database to store user credentials
You will access this database from your application running either locally or on the cloud. 

Here are the steps to follow:
1. Navigate to the <a href="https://console.aws.amazon.com/rds/home" target="_blank">RDS dashboard</a> and create a PostgreSQL database with the following configuration, and leave the remaining fields as default.

<center>

|**Field**|**Value**|
|---|---|
|Database creation method|**Standard create**. <br>Easy create option creates <br>a private database by default. |
|Engine option|PostgreSQL 12 or higher|
| Templates |Free tier|
| DB instance identifier, <br>master username, and password|Your choice|
|DB instance class|Burstable classes with minimal size |
|VPC and subnet |Default|
|Public access|YES. Allow application running outside <br> of your AWS account discover the database.|
|VPC security group|Either choose default or <br>create a new one|
| Availability Zone|No preferencce|
|Database port|`5432` (default)|
</center>
2. Once the database is created successfully, copy and save the database endpoint, master username, and password to your local machine. It will help your application discover the database. 

3. Edit the security group's inbound rule to allow incoming connections from anywhere (`0.0.0.0/0`). It will allow your application running locally connecting to the database. 

4. Test the connection from your local PostgreSQL client.
```bash
# Assuming the endpoint is: mypostgres-database-1.c5szli4s4qq9.us-east-1.rds.amazonaws.com
psql -h mypostgres-database-1.c5szli4s4qq9.us-east-1.rds.amazonaws.com -U [your-username] postgres
# Provide the database password that you had set in the step above
# It will open the "postgres=>" prompt if the connection is successful
```
Later, when your application up and running, you can run commands like:
```bash
# List the databases
\list
# Go inside the "postgres" database and view relations
\c postgres
\dt
   ```

## Set up the Environment variables to store sensitive information

Steps to follow:
1. If not already, fork the project repository and clone it.
```bash
git clone https://github.com/[Github-Username]/nd9990-c3-microservices-exercises.git
cd nd9990-c3-microservices-exercises/project/
```

2. Your application will need to access the AWS PostgreSQL database and S3 bucket you created in the steps above. The connection details (confidential) of the database and S3 bucket should not be hard-coded into the application code. 

 For this reason, create and stores the above details into multiple environment variables locally. 
   - **Mac/Linux users** - Use the *set_env.sh* file present in the project directory to configure these variables on your local machine. Once you save your details in the *set_env.sh* file, run:
```bash
# Mac/Linux - Load the environment variables
source set_env.sh
echo $POSTGRES_USERNAME
echo $URL
``` 
Also, you would not want your credentials to be stored in the Git repository either. Run the following command before pushing your project to Github, to tell git to stop tracking the script in git but keep it stored locally.
```bash
git rm --cached set_env.sh
```
 In addition, add the *set_env.sh*  filename to your `.gitignore` file in the project repository. 
> <font color=RED>**Note**</font>: The method above will set the environment variables temporarily. Meaning, every time you open a new terminal, you will have to run `source set_env.sh` to reconfigure your environment variables
<br><br>

   - **Mac/Linux users** - To set the environment variables permanently, save all the variables above in your `~/.bashrc` / `~/.profile` / `~/.zshrc` file and use:
```bash
source ~/.profile
```

   - **Windows users** - Set all the environment variables as shown in the *set_env.sh* file either using the **Advanced System Settings** or run the following in the GitBash terminal (change the values, as applicable to you):
```bash
setx POSTGRES_USERNAME postgres
setx POSTGRES_PASSWORD abcd1234
setx POSTGRES_HOST mypostgres-database-1.c5szli4s4qq9.us-east-1.rds.amazonaws.com
setx POSTGRES_DB postgres
setx AWS_BUCKET test-nd9990-dev-wc
setx AWS_REGION us-east-1
setx AWS_PROFILE nd9990
setx JWT_SECRET hello
setx URL http://localhost:8100
```


