{{/*
Return the proper image name.
If image tag and digest are not defined, termination fallbacks to chart appVersion.
{{ include "vaultwarden.image" ( dict "img" .Values.path.to.the.image "ctx" $ ) }}
*/}}
{{- define "vaultwarden.image" -}}

{{- $img := .img -}}
{{- $ctx := .ctx -}}

{{- $registryName := default $img.registry ($ctx.Values.global.imageRegistry) -}}
{{- $repositoryName := $img.repository -}}
{{- $separator := ":" -}}
{{- $termination := $img.tag | toString -}}

{{- if $img.digest }}
    {{- $separator = "@" -}}
    {{- $termination = $img.digest | toString -}}
{{- end -}}

{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $repositoryName $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $repositoryName $separator $termination -}}
{{- end -}}
{{- end -}}

{{/*
Return the list of imagePullSecrets, formatted as objects:
imagePullSecrets: (this key has to be added)
  - name: sec-1
  - name: sec-2
  - name: sec-global
{{ include "vaultwarden.imagePullSecrets" ( 
   dict "imagePullSecrets" ( concat .Values.imagePullSecrets1, 
                                    .Values.imagePullSecrets2
                                    .Values.global.imagePullSecrets )) }}
*/}}
{{- define "vaultwarden.imagePullSecrets" -}}
  {{- $finalImagePullSecrets := list -}}
  {{- range .imagePullSecrets -}}
    {{- if kindIs "map" . -}}
      {{- $finalImagePullSecrets = append $finalImagePullSecrets .name -}}
    {{- else -}}
      {{- $finalImagePullSecrets = append $finalImagePullSecrets . -}}
    {{- end -}}
  {{- end -}}
  {{- if (not (empty $finalImagePullSecrets)) -}}
    {{- range $finalImagePullSecrets | uniq }}
- name: {{ . | quote }}
    {{- end -}}
  {{- end -}}
{{- end -}}


{{/*
Return the workload kind, e.g. Deployment, StatefulSet, DaemonSet, etc.
kind: {{ include "vaultwarden.workloadKind" ( dict "kind" .Values.workload.kind ) }}
*/}}
{{- define "vaultwarden.workloadKind" -}}
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