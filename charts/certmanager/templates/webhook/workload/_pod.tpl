{{/*
Pod Spec
*/}}
{{- define "webhook.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.webhook -}}
{{- $img := $v.images.webhook -}}
{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}
{{- $ctr := $main.containers.webhook -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-webhook
imagePullSecrets:
  {{- include "common.imagePullSecrets" ( 
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
  - name: cert-manager-webhook
    image: {{ include "common.image" ( dict "img" $img "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
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
    env:
      {{- with ( concat $ctr.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: CERT_MANAGER_HELM_FULLNAME
        value: {{ include "common.fullname" . | quote }}
      - name: CERT_MANAGER_SECURE_PORT
        value: {{ $svc.ports.https.port | quote }}
      - name: POD_NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
    {{- with ( concat $ctr.extraEnvFrom 
                      $pod.extraEnvFrom) }}
    envFrom:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    ports:
      {{- range $portName, $portSpecs := $svc.ports }}
      - name: {{ $portName | quote }}
        containerPort: {{ $portSpecs.port }}
        protocol: {{ $portSpecs.protocol }}
        {{- with $portSpecs.hostPort }}
        hostPort: {{ . }}
        {{- end }}
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