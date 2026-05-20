{{/*
Special Pod Spec
Usage:
  {{- include "common.podSpec" ( dict "podSpec" $pod.configs ) }}  
*/}}
{{- define "common.podSpec" }}
{{- $ps := .podSpec -}}
{{/* ------------------------------------------------ Scheduling constraints */}}
{{- with $ps.affinity }}
affinity:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with $ps.nodeSelector }}
nodeSelector:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with $ps.tolerations }}
tolerations:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{/* ------------------------------------------------ Scheduling & identity */}}
{{- with $ps.nodeName }}
nodeName: {{ . | quote }}
{{- end }}
{{- with $ps.hostname }}
hostname: {{ . | quote }}
{{- end }}
{{- with $ps.subdomain }}
subdomain: {{ . | quote }}
{{- end }}
{{- with $ps.automountServiceAccountToken }}
automountServiceAccountToken: {{ . }}
{{- end }}
{{/* ------------------------------------------------ Network */}}
{{- with $ps.hostNetwork }}
hostNetwork: {{ . }}
{{- end }}
{{- with $ps.dnsPolicy }}
dnsPolicy: {{ . | quote }}
{{- end }}
{{- with $ps.dnsConfig }}
dnsConfig:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- with $ps.hostAliases }}
hostAliases:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{/* ------------------------------------------------ Pod-level security context */}}
{{- with $ps.securityContext }}
securityContext:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{/* ------------------------------------------------ Runtime, priority, scheduler */}}
{{- with $ps.runtimeClassName }}
runtimeClassName: {{ . | quote }}
{{- end }}
{{- with $ps.priorityClassName }}
priorityClassName: {{ . | quote }}
{{- end }}
{{- with $ps.priority }}
priority: {{ . }}
{{- end }}
{{- with $ps.schedulerName }}
schedulerName: {{ . | quote }}
{{- end }}
{{/* ------------------------------------------------ Process & service-related settings */}}
{{- with $ps.shareProcessNamespace }}
shareProcessNamespace: {{ . }}
{{- end }}
{{- with $ps.enableServiceLinks }}
enableServiceLinks: {{ . }}
{{- end }}
{{- with $ps.terminationGracePeriodSeconds }}
terminationGracePeriodSeconds: {{ . }}
{{- end }}
{{- with $ps.activeDeadlineSeconds }}
activeDeadlineSeconds: {{ . }}
{{- end }}
{{/* ------------------------------------------------ Pod readiness gates: additional conditions required for Pod to be "Ready" */}}
{{- with $ps.readinessGates }}
readinessGates:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{/* ------------------------------------------------ scheduling constraints for topology spreading */}}
{{- with $ps.topologySpreadConstraints }}
topologySpreadConstraints:
  {{- . | toYaml | nindent 2 }}
{{- end }}
{{- end }}