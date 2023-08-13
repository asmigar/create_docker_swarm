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

3. Ssh into the docker swarm manager node(ssh command details available in terraform apply output from step 2) 
4. [**Run on Manager Node**] Get the join-token for workers:
```bash
docker swarm join-token worker
```
This should output something like below:
```bash
docker swarm join --token <join_token> <manager_private_ip>:2377
```
5. Copy the join token command.

6. Ssh into worker nodes(_ssh command details available in terraform apply output from step 2_) 
7. [**Run on all workers nodes**]Paste the copied join token command(_step 4_).It should be something like this:
```bash
docker swarm join --token <worker_join_token> <manager_node_private_ip>:2377
```