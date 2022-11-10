# Makefile for bootstrap and testing of local terraform setup.

# For a completely new service the entire plan can't be applied straight
# away, since the ECR repository and version parameters don't yet exist.
# First these have to selectively be created (via the bootstrap targets).

TF	= terraform
TFDIR	= .terraform
# CONFIG	= backends/$(ENV).backend
TFPLAN  = $(TF) plan -var-file=$(ENV).tfvars -compact-warnings -no-color
TFDESTROY =  $(TF) destroy -var-file=$(ENV).tfvars
TFAPPLY = $(TF) apply -no-color
ENV	= dev

# AWS resources requiring bootstrap.
BOOTSTRAP = aws_ecr_repository.proxy aws_ecr_repository.app aws_s3_bucket.terraform_state  aws_dynamodb_table.terraform_lock

BOOTSTRAP_OPTS = $(addprefix -target=,$(BOOTSTRAP))

CLEANFILES = .terraform.lock.hcl $(TFDIR) *.plan

all: init validate plan

init:
	@ test -d $(TFDIR) || $(TF) init 

# -backend-config=$(CONFIG)

validate:
	$(TF) validate

bootstrap: bootstrap-plan bootstrap-apply

bootstrap-plan:
	$(TFPLAN) $(BOOTSTRAP_OPTS) -out bootstrap.plan

bootstrap-apply:
	$(TFAPPLY) bootstrap.plan

update: plan apply

plan:
	$(TFPLAN) -out update.plan

apply:
	$(TFAPPLY) update.plan
destroy:
	$(TFDESTROY) 
clean:
	rm -rf $(CLEANFILES)
