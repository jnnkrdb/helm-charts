{{/*
Pod Spec
*/}}
{{- define "cainjector.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.cainjector -}}
{{- $img := $v.images.cainjector -}}
{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $ctr := $main.containers.cainjector -}}

{{- include "certmanager.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "certmanager.fullname" . }}-cainjector
imagePullSecrets:
  {{- include "certmanager.imagePullSecrets" ( 
      dict "imagePullSecrets" (concat $global.imagePullSecrets
                                      $pod.imagePullSecrets
                                      $img.imagePullSecrets )) | nindent 2 }}
{{- with (concat $pod.initContainers) }}
initContainers:
  {{- . | toYaml | nindent 2 }} 
{{- end }}
{{- with ( concat $global.extraVolumes
                  $pod.extraVolumes) }}
volumes:
  {{- . | toYaml | nindent 2 }}
{{- end }}
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: cert-manager-cainjector
    image: {{ include "certmanager.image" ( dict "img" $img "ctx" $ ) }}
    imagePullPolicy: {{ include "certmanager.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $img.imagePullPolicy )) }}
    {{- with $ctr.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctr.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctr.extraEnvs 
                      $pod.extraEnvs) }}
    env:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctr.extraEnvFrom 
                      $pod.extraEnvFrom) }}
    envFrom:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctr.extraVolumeMounts 
                      $pod.extraVolumeMounts
                      $global.extraVolumeMounts) }}
    volumeMounts:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctr.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}