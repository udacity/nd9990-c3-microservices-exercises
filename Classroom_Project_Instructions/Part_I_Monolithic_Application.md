# Part 1 - Run the project locally as a Monolithic application

Now that you have set up the AWS PostgreSQL database and S3 bucket, and saved the environment variables, let's run the application locally.  It's recommended that you start the backend application first before starting the frontend application that depends on the backend API.

### Backend App

1. Download all the package dependencies by running the following command from the */project/udagram-api/* directory:
```bash
npm update --save
# Update dependencies in ./package.json 
npm audit fix
# Install dependencies and generate ./package-lock.json
npm install .
```
1. Run the application locally, in a development environment (so that you can test your edits quickly without restarting the server):
```bash
npm run dev
```
If the command above runs successfully, visit the *http://localhost:8080/api/v0/feed* in your web browser to verify that the application is running. You should see a JSON payload. 


### Frontend App

3. To download all the package dependencies, run the command from the */project/udagram-frontend/* directory: 
```bash
npm update --save
npm audit fix
npm install .
```

4. Prepare your application by compiling them into static files. 
```bash
# You should have the Ionic command-line utility installed before you run the command below. 
# Otherwise visit https://ionicframework.com/docs/intro/cli
ionic build
```
5. Run the application locally using files created from the `ionic build` command above.
```bash
ionic serve
```
6. Visit *http://localhost:8100* in your web browser to verify that the application is running. You should see a web interface.

### Optional

7. It's useful to "lint" your code so that changes in the codebase adhere to a coding standard. This helps alleviate issues when developers use different styles of coding. `eslint` has been set up for TypeScript in the codebase for you. To lint your code, run the following:
```bash
npx eslint --ext .js,.ts src/
```
To have your code fixed automatically, run
```bash
npx eslint --ext .js,.ts src/ --fix
```
7. Over time, our code will become outdated and inevitably run into security vulnerabilities. To address them, you can run:
```bash
npm audit fix
```

