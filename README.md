# Hive Utility

Container image to help destroy cloud resources

## Usage

Usage:
  make <target>
  build             Build the Container Image
  push              Push the image to quay
  aws-deprovision   make aws-deprovision CLUSTER=test REGION=us-west2

|---|---|
|target|purpose|
|build| Build the image |
|push| Push image to quay or whatever registry |
|aws-deprovision|Use CLUSTER= and REGION= to deprovision cloud resources|
