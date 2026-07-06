{{/*
Special Pod Meta
Usage:
  {{- include "argocd.configs.checksums" . }}  
*/}}
{{- define "argocd.configs.checksums" -}}
checksum/argocd-cm: "/config/configmap.argocd-cm.yaml"
checksum/argocd-cmd-params-cm: "/config/configmap.argocd-cmd-params-cm.yaml"
checksum/argocd-gpg-keys-cm: "/config/configmap.argocd-gpg-keys-cm.yaml"
checksum/argocd-rbac-cm: "/config/configmap.argocd-rbac-cm.yaml"
checksum/argocd-secret: "/config/secret.argocd-secret.yaml"
checksum/argocd-ssh-known-hosts-cm: "/config/configmap.argocd-ssh-known-hosts-cm.yaml"
checksum/argocd-tls-certs-cm: "/config/configmap.argocd-tls-certs-cm.yaml"
checksum/argocd-redis-auth: {{ include (print $.Template.BasePath "/redis/secret.yaml") . | sha256sum }}
{{- end }}
