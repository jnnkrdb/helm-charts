CONFIG_FILE ?= .github/k3d/config.yaml


.PHONY: check-k3d
check-k3d: ## Check if k3d is installed
	@command -v k3d >/dev/null 2>&1 || { \
		echo "k3d is not installed. Please install k3d manually."; \
		exit 1; \
	}

.PHONY: k3d
k3d: check-k3d ## Create a local registry for k3d cluster from config file
	k3d cluster create --config ${CONFIG_FILE}

.PHONY: k3d-cleanup
k3d-cleanup: check-k3d ## Remove a local registry and k3d from config file
	k3d cluster delete --config ${CONFIG_FILE}

## ------------------------------------------------------------------------------------- support funcs
.PHONY: cleanup
cleanup: k3d-cleanup


## ------------------------------------------------------------------------------------- chart funcs
CHART =

.PHONY: check-helm
check-helm: ## Check if helm is installed
	@command -v helm >/dev/null 2>&1 || { \
		echo "helm is not installed. Please install helm manually."; \
		exit 1; \
	}

.PHONY: lint
lint: check-helm ## Lint helm chart
	helm dep update charts/${CHART}
	helm lint charts/${CHART} --debug

.PHONY: template
template: check-helm ## Template helm chart
	helm dep update charts/${CHART}
	helm template charts/${CHART} --debug -f charts/${CHART}/values.yaml

.PHONY: upgrade
upgrade: check-helm ## Upgrade helm chart
	helm dep update charts/${CHART}
	helm upgrade ${CHART} charts/${CHART} -n test-$(CHART) --create-namespace --install --debug -f charts/${CHART}/values.yaml

.PHONY: uninstall
uninstall: check-helm ## Uninstall helm chart
	helm uninstall ${CHART} -n test-$(CHART) --debug