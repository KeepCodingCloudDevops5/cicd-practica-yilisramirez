all: clean init plan format apply

clean:
	@echo clean step
	cd infra rm -rf .terraform

init:
	@echo init step
	cd infra && terraform init -backend-config='key=stage_dev/terraform.tfstate'

plan:
	@echo plan step
	cd infra && terraform plan

format:
	@echo format step
	cd infra && terraform fmt

apply:
	@echo apply step
	cd infra && terraform apply -auto-approve