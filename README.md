## Pre-requisite
- Install [terraform v1.5.2](https://www.terraform.io/downloads.html)
- Setup the [aws cli credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with `default` profile name.

## Setup

1. Apply the `remote_state` terraform project. This will create s3 bucket and lock table for keeping remote state for the `infra` terraform project.
```bash
cd remote_state; terraform init; terraform apply
```
2. Apply the `infra` terraform project. 
```bash
cd infra; terraform init; terraform apply
```
This will create one docker swarm manager node along with two worker nodes.  

This will output
* ssh commands to access the swarm nodes.

3. Ssh into the docker swarm manager node and get the worker join-token comman:
```bash
docker swarm join-token worker
```
Copy the join token command.

5. Ssh into worker nodes and paste the copied join token command that we got from docker swarm manager node.