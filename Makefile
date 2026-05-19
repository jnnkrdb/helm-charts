CONFIG_FILE ?= .github/k3d/config.yaml

.PHONY: k3d
k3d: ## Create a local registry for k3d cluster from config file
	@command -v k3d >/dev/null 2>&1 || { \
		echo "k3d is not installed. Please install k3d manually."; \
		exit 1; \
	}
	k3d cluster create --config ${CONFIG_FILE}

.PHONY: k3d-cleanup
k3d-cleanup: ## Remove a local registry and k3d from config file
	@command -v k3d >/dev/null 2>&1 || { \
		echo "k3d is not installed. Please install k3d manually."; \
		exit 1; \
	}
	k3d cluster delete --config ${CONFIG_FILE}

## ------------------------------------------------------------------------------------- support funcs
.PHONY: cleanup
cleanup: k3d-cleanup