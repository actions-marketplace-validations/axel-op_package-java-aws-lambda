# Package an AWS Lambda in Java

AWS Lambdas in Java [should be packaged as an Uber JAR](https://docs.aws.amazon.com/lambda/latest/dg/java-package.html#java-package-maven).

The [`maven-shade-plugin`](https://maven.apache.org/plugins/maven-shade-plugin) is used to build the Uber JAR. While configuring it in the `pom.xml` is the recommended way to use it, here we execute it from the command line so the `pom.xml` doesn't have to be edited.

## Inputs/Outputs

- The input `working-directory` is optional and indicates where is the root directory of your Lambda function.
- The output `deployment-file` is an absolute path to the JAR that should be deployed (see the example below).

## Example workflow

This GitHub Actions workflow shows how to deploy an AWS Lambda [using the `UpdateFunctionCode` API](https://docs.aws.amazon.com/lambda/latest/dg/API_UpdateFunctionCode.html) with the `aws` CLI:

```yml
name: Example workflow

on:
  push:
    branches:
      - main

jobs:
  deploy-aws-lambda:
    runs-on: ubuntu-latest
    permissions:
      # This is required for requesting the GitHub's OIDC Token
      # See https://github.com/aws-actions/configure-aws-credentials
      id-token: write
    env:
      REGION: eu-west-3
      FUNCTION_NAME: name-of-function
    steps:
      - uses: actions/checkout@v3
      - uses: axel-op/package-aws-lambda-java@main
        id: package
      - name: Configure AWS Credentials
        uses: aws-actions/configure-aws-credentials@v1
        with:
          role-to-assume: ${{ secrets.AWS_ROLE }}
          aws-region: ${{ env.REGION }}
      - name: Deploy on AWS
        env:
          JAR: ${{ steps.package.outputs.deployment-file }}
        run: aws lambda update-function-code --function-name $FUNCTION_NAME --zip-file "fileb://$JAR"
```

The [AWS documentation](https://docs.aws.amazon.com/lambda/latest/dg/lambda-java.html) describes all the possible ways to deploy your function.
