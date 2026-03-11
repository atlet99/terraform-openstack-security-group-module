.PHONY: fmt validate docs lint changelog release tag clean help check-deps check-all

SHELL := /bin/bash

# Current version from the latest git tag (strip leading 'v')
CURRENT_VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null | sed 's/^v//' || echo "0.0.0")
DATE := $(shell date +%Y-%m-%d)

# Repository URL
REPO_URL := https://github.com/atlet99/terraform-openstack-security-group-module

# Required binaries
REQUIRED_BINS := terraform tflint terraform-docs git git-cliff tfenv

# Use tfenv if available, otherwise fallback to standard terraform
TERRAFORM := $(shell if command -v tfenv >/dev/null 2>&1; then echo "tfenv exec"; else echo "terraform"; fi)

###############################################################################
# Helpers
###############################################################################

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | \
		awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-15s\033[0m %s\n", $$1, $$2}'

check-deps: ## Check that all required tools are installed
	@for bin in $(REQUIRED_BINS); do \
		if ! command -v $$bin &>/dev/null; then \
			echo "ERROR: '$$bin' is not installed."; \
			case $$bin in \
				terraform)      echo "  Install: https://developer.hashicorp.com/terraform/install" ;; \
				tflint)         echo "  Install: brew install tflint" ;; \
				terraform-docs) echo "  Install: brew install terraform-docs" ;; \
				git)            echo "  Install: brew install git" ;; \
			esac; \
			exit 1; \
		fi; \
	done
	@echo "All dependencies are available."

###############################################################################
# Terraform
###############################################################################

fmt: check-deps ## Run terraform fmt recursively
	$(TERRAFORM) fmt -recursive

validate: check-deps ## Run terraform init + validate
	$(TERRAFORM) init -backend=false -input=false
	$(TERRAFORM) validate

###############################################################################
# Linting & Docs
###############################################################################

lint: check-deps ## Run tflint
	tflint --init
	tflint

docs: check-deps ## Generate documentation with terraform-docs
	terraform-docs .

check-all: fmt validate lint docs ## Run all checks: fmt, validate, lint, docs

###############################################################################
# Changelog & Release
###############################################################################

changelog: check-deps ## Generate CHANGELOG.md from git commits
	@echo "Generating CHANGELOG.md with git-cliff..."
	@git cliff -o CHANGELOG.md
	@echo "Done. Review CHANGELOG.md and commit."

# Next version automatically determined by git-cliff
NEXT_VERSION := $(shell git cliff --bumped-version 2>/dev/null || echo "v1.0.1")

changelog-preview: check-deps ## Preview the next version and unreleased changes
	@echo "Next version: $(NEXT_VERSION)"
	@echo "Unreleased changes:"
	@git cliff --unreleased --strip all

release: check-deps ## Create a release: make release [VERSION=x.y.z]
	@version="$(VERSION)"; \
	if [ -z "$$version" ]; then \
		version="$(NEXT_VERSION)"; \
	fi; \
	version=$${version#v}; \
	echo "Releasing v$$version (current: v$(CURRENT_VERSION))..."; \
	sed -i.bak -e "s/version = \".*\"/version = \"$$version\"/g" README.md; \
	rm -f README.md.bak; \
	git cliff --bump --tag "v$$version" -o CHANGELOG.md; \
	git add CHANGELOG.md README.md; \
	git commit -m "chore: release v$$version"; \
	git tag -a "v$$version" -m "Release v$$version"; \
	echo "Done. Run 'git push && git push --tags' to publish."

tag: check-deps ## Create a tag with CHANGELOG update: make tag [VERSION=x.y.z]
	@version="$(VERSION)"; \
	if [ -z "$$version" ]; then \
		version="$(NEXT_VERSION)"; \
	fi; \
	version=$${version#v}; \
	echo "Creating tag v$$version (current: v$(CURRENT_VERSION))..."; \
	sed -i.bak -e "s/version = \".*\"/version = \"$$version\"/g" README.md; \
	rm -f README.md.bak; \
	git cliff --bump --tag "v$$version" -o CHANGELOG.md; \
	git add CHANGELOG.md README.md; \
	git commit -m "chore: release v$$version"; \
	git tag -a "v$$version" -m "Release v$$version"; \
	echo "Tag v$$version created. Run 'git push && git push --tags' to publish."

###############################################################################
# Cleanup
###############################################################################

clean: ## Remove terraform init artifacts
	rm -rf .terraform .terraform.lock.hcl
