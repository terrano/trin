This setup contains 3 modules: 
  - For initial setup of terraform state file and lock
  - Deployment of N-Tier VPC
  - Security items (kms, secrets) deployment

Initial Setup is located in folder "terraform_aws_state".
In order to use it:
  - navigate to terraform_aws_state folder
  - edit file variables.tf for desired names
  - initialize your local terraform folder: terraform init
  - apply "terraform_aws_state" module: terraform apply
  - Once done, make sure that references to the state file in main.tf are correct. You must specify correct region in terraform-backend section.

Deployment of N-Tier VPC is located in folder "vpc".
When this module is called, then N-Tier VPC will be deployed with a default values: VPC CIDR: 172.31.0.0/16, region: us-east-1.
In case when this should be changed, pass to module new values using variables: vpc_cidr and region.

N-Tier deployment includes:
 - 2 Public subnets in both availability zones a and b associated with public routing table.
 - 2 Private subnets in both availability zones a and b associated with private routing table.
 - 2 Inner subnets in both availability zones a and b associated with inner routing table.
 - Public NAT Gateway which is a part of Public subnet.
 - Public_RT has default route to Internet Gateway.
 - Private_RT has default route to Public NAT Gateway.
 - each Subnet has Network ACL

Additionally, there are 5 Security Groups.
  - 2 pairs of security groups, works along. First permits port 5432 outbound and second permits port 5432 inbound.
  - Another Security Group permits SSH access.

Please, see file trinity.drawio.

Security module provides:
  - kms keys for Aurora DB encryption
  - kms keys for DB credentials encryption
  - Credentials for RDS Admin user "db_admin"

S3 module creates storage for knowledgebase source data with enabled versioning.

Aurora module creates AuroraDB Database using configured before KMS, Secrets, VPC.

Module bedrock creates:
  - Service Role which has 4 policies:
    - Foundation Model Policy
    - Aurora RDS access Policy
    - S3 Access Policy
    - Secrets Policy
  - Bedrock Knowledgbase with foundation model "amazon.titan-embed-text-v1" and referenced S3 storage, AuroraDB, Service Role and Secrets.