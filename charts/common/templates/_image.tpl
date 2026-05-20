{{/*
Return the proper image name.
If image tag and digest are not defined, termination fallbacks to chart appVersion.

The image config has to consist of the following keys:

image:
  registry: <optional, e.g. docker.io>
  repository: <required, e.g. jnnkrdb/cert-manager>
  tag: <optional, e.g. v1.10.1>
  digest: <optional, e.g. sha256:abc123>

Usage:
  image: {{ include "common.image" ( 
            dict "img" .Values.path.to.the.image 
                 "ctx" $ ) }}
*/}}
{{- define "common.image" -}}

{{- $img := .img -}}
{{- $ctx := .ctx -}}

{{- $registryName := default $img.registry ($ctx.Values.global.imageRegistry) -}}
{{- $separator := ":" -}}
{{- $termination := $img.tag | toString -}}

{{- if $img.digest }}
    {{- $separator = "@" -}}
    {{- $termination = $img.digest | toString -}}
{{- end -}}

{{- if $registryName }}
    {{- printf "%s/%s%s%s" $registryName $img.repository $separator $termination -}}
{{- else -}}
    {{- printf "%s%s%s"  $img.repository $separator $termination -}}
{{- end -}}
{{- end -}}


{{/*
Return the list of imagePullSecrets, formatted as objects:
imagePullSecrets: (this key has to be added)
  - name: sec-1
  - name: sec-2
  - name: sec-global
{{ include "common.imagePullSecrets" ( 
   dict "imagePullSecrets" ( concat .Values.imagePullSecrets1, 
                                    .Values.imagePullSecrets2
                                    .Values.global.imagePullSecrets )) }}
*/}}
{{- define "common.imagePullSecrets" -}}
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

