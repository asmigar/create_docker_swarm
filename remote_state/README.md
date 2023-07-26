## Pre-requisite
- Install [terraform v1.5.2](https://www.terraform.io/downloads.html)
- Setup the [aws cli credentials](https://docs.aws.amazon.com/cli/latest/userguide/cli-chap-configure.html) with `default` profile name.

## Setup

1. Apply the `remote_state` terraform project. This will create s3 bucket and lock table for keeping remote state for other tf projects.
```bash
cd remote_state; terraform init; terraform apply

2. Apply the `ecs` terraform project.
```bash
cd infra; terraform init; terraform apply
```
This will output
* ssh commands to access the swarm nodes.
