{{/*
Pod Spec
*/}}
{{- define "argocd.commitserver.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.commitserver -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-commitserver
imagePullSecrets:
  {{- include "common.imagePullSecrets" ( 
      dict "imagePullSecrets" (concat $global.imagePullSecrets
                                      $pod.imagePullSecrets
                                      $imgs.argocd.imagePullSecrets )) | nindent 2 }}
volumes:
  {{- with (concat $global.extraVolumes 
                  $pod.extraVolumes) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: ssh-known-hosts
    configMap:
      name: argocd-ssh-known-hosts-cm
  - name: tls-certs
    configMap:
      name: argocd-tls-certs-cm
  - name: gpg-keys
    configMap:
      name: argocd-gpg-keys-cm
  - name: gpg-keyring
    emptyDir: {}
  - name: tmp
    emptyDir: {}
  - name: argocd-commit-server-tls
    secret:
      secretName: argocd-commit-server-tls
      optional: true
      items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
      - key: ca.crt
        path: ca.crt
{{- with (concat $pod.initContainers) }}
initContainers:
  {{- . | toYaml | nindent 2 }}
{{- end }}
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: commitserver
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.commitserver.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.commitserver.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.commitserver.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.commitserver.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.commitserver.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    env:
      {{- with ( concat $ctrs.commitserver.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: ARGOCD_COMMIT_SERVER_LISTEN_ADDRESS
        valueFrom:
          configMapKeyRef:
            name: argocd-cmd-params-cm
            key: commitserver.listen.address
            optional: true
      - name: ARGOCD_COMMIT_SERVER_METRICS_LISTEN_ADDRESS
        valueFrom:
          configMapKeyRef:
            name: argocd-cmd-params-cm
            key: commitserver.metrics.listen.address
            optional: true
      - name: ARGOCD_COMMIT_SERVER_LOGFORMAT
        valueFrom:
          configMapKeyRef:
            name: argocd-cmd-params-cm
            key: commitserver.log.format
            optional: true
      - name: ARGOCD_COMMIT_SERVER_LOGLEVEL
        valueFrom:
          configMapKeyRef:
            name: argocd-cmd-params-cm
            key: commitserver.log.level
            optional: true
      - name: ARGOCD_LOG_FORMAT_TIMESTAMP
        valueFrom:
          configMapKeyRef:
            name: argocd-cmd-params-cm
            key: log.format.timestamp
            optional: true
    envFrom:
      {{- with ( concat $ctrs.commitserver.extraEnvFrom 
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
    volumeMounts:
      {{- with ( concat $ctrs.commitserver.extraVolumeMounts 
                        $pod.extraVolumeMounts
                        $global.extraVolumeMounts) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: ssh-known-hosts
        mountPath: /app/config/ssh
      - name: tls-certs
        mountPath: /app/config/tls
      - name: gpg-keys
        mountPath: /app/config/gpg/source
      - name: gpg-keyring
        mountPath: /app/config/gpg/keys
      # We need a writeable temp directory for the askpass socket file.
      - name: tmp
        mountPath: /tmp
    {{- with $ctrs.commitserver.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.commitserver.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.commitserver.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}