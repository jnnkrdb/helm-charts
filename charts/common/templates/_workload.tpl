
{{/*
Return the workload kind, e.g. Deployment, StatefulSet, DaemonSet, etc.
kind: {{ include "common.workloadKind" ( dict "kind" .Values.workload.kind ) }}
*/}}
{{- define "common.workloadKind" -}}
{{- $kind := .kind | lower -}}
{{- if eq $kind "deployment" -}}
Deployment
{{- else if eq $kind "statefulset" -}}
StatefulSet
{{- else if eq $kind "daemonset" -}}
DaemonSet
{{- else if eq $kind "replicaset" -}}
ReplicaSet
{{- else if eq $kind "job" -}}
Job
{{- else if eq $kind "cronjob" -}}
CronJob
{{- else if eq $kind "pod" -}}
Pod
{{- else -}}
{{- fail (printf "Unsupported workload kind: %s" .kind) -}}
{{- end -}}
{{- end -}}