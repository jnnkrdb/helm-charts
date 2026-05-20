
{{/*
Return the first non-empty value from a list.
The list is ordered by priority: the first non-empty item wins.

Usage:
spec: 
  storageClassName: {{ include "common.firstOf" (
                       dict "items" ( list .Values.global.storageClassName
                                           .Values.persistence.pvc.storageClassName )) }}
*/}}
{{- define "common.firstOf" -}}
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
  {{- include "common.keyValues" ( 
      dict "kvs" (list .Values.global.labels 
                          .Values.labels
                          .Values.pod.labels ) ) }}  
*/}}
{{- define "common.keyValues" -}}
{{- $kvs := .kvs -}}
{{- range $kvs -}}
{{- if . -}}
{{- . | toYaml | nindent 0 -}}
{{- end -}}
{{- end -}}
{{- end -}}