{{/*
Pod Spec
*/}}
{{- define "argocd.redis.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.redis -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-redis
imagePullSecrets:
  {{- include "common.imagePullSecrets" ( 
      dict "imagePullSecrets" (concat $global.imagePullSecrets
                                      $pod.imagePullSecrets
                                      $imgs.redis.imagePullSecrets
                                      $imgs.argocd.imagePullSecrets )) | nindent 2 }}
{{- with (concat $global.extraVolumes 
                 $pod.extraVolumes) }}
volumes:
  {{- . | toYaml | nindent 2 }} 
{{- end }}
initContainers:
  {{- with (concat $pod.initContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: secretinit
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.secretinit.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.secretinit.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.secretinit.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.secretinit.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.secretinit.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.secretinit.extraEnvs 
                      $pod.extraEnvs) }}
    env:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.secretinit.extraEnvFrom 
                      $pod.extraEnvFrom) }}
    envFrom:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.secretinit.extraVolumeMounts 
                      $pod.extraVolumeMounts
                      $global.extraVolumeMounts) }}
    volumeMounts:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: redis
    image: {{ include "common.image" ( dict "img" $imgs.redis "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.redis.imagePullPolicy )) }}
    {{- with $ctrs.redis.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.redis.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.redis.extraEnvs 
                      $pod.extraEnvs) }}
    env:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    envFrom:
      {{- with ( concat $ctrs.redis.extraEnvFrom 
                        $pod.extraEnvFrom) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - secretRef:
          name: {{ include "common.fullname" . }}-redis-auth
    ports:
      {{- range $portName, $portSpecs := $svc.ports }}
      - name: {{ $portName | quote }}
        containerPort: {{ $portSpecs.port }}
        protocol: {{ $portSpecs.protocol }}
        {{- with $portSpecs.hostPort }}
        hostPort: {{ . }}
        {{- end }}
      {{- end }}
    {{- with ( concat $ctrs.redis.extraVolumeMounts 
                      $pod.extraVolumeMounts
                      $global.extraVolumeMounts) }}
    volumeMounts:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.redis.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}