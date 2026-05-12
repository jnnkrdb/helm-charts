{{/*
Expand the name of the chart.
*/}}
{{- define "vaultwarden.name" -}}
{{- .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "vaultwarden.fullname" -}}
{{- printf "%s-%s" .Release.Name .Chart.Name | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "vaultwarden.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "vaultwarden.defaultLabels" -}}
helm.sh/chart: {{ include "vaultwarden.chart" . }}
{{ include "vaultwarden.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "vaultwarden.selectorLabels" -}}
app.kubernetes.io/name: {{ include "vaultwarden.fullname" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Return the first non-empty value from a list.
The list is ordered by priority: the first non-empty item wins.

Usage:
spec: 
  storageClassName: {{ include "vaultwarden.firstOf" (
                       dict "items" ( list .Values.global.storageClassName
                                           .Values.persistence.pvc.storageClassName )) }}
*/}}
{{- define "vaultwarden.firstOf" -}}
{{- $result := "" -}}
{{- range .items -}}
  {{- if and (not $result) . -}}
    {{- $result = . -}}
  {{- end -}}
{{- end -}}
{{- if $result -}}
{{ $result | quote }}
{{- end -}}
{{- end -}}

{{/*
Append all received labels from the listed items.
Usage:
  {{- include "vaultwarden.keyValues" ( 
      dict "kvs" (list .Values.global.labels 
                          .Values.labels
                          .Values.pod.labels ) ) }}  
*/}}
{{- define "vaultwarden.keyValues" -}}
{{- $kvs := .kvs -}}
{{- range $kvs -}}
{{- if . -}}
{{- . | toYaml -}}
{{- end -}}
{{- end -}}
{{- end -}}