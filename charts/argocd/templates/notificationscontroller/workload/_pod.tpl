{{/*
Pod Spec
*/}}
{{- define "argocd.notificationscontroller.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.notificationscontroller -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-notificationscontroller
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
  - name: tls-certs
    configMap:
      name: argocd-tls-certs-cm
  - name: repo-server-tls
    secret:
      secretName: argocd-repo-server-tls
      items:
        - key: tls.crt
          path: tls.crt
        - key: tls.key
          path: tls.key
        - key: ca.crt
          path: ca.crt
      optional: true
{{- with (concat $pod.initContainers) }}
initContainers:
  {{- . | toYaml | nindent 2 }}
{{- end }}
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: notificationscontroller
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.notificationscontroller.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    env:
      {{- with ( concat $ctrs.notificationscontroller.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: ARGOCD_NOTIFICATIONS_CONTROLLER_LOGFORMAT
        valueFrom:
          configMapKeyRef:
            key: notificationscontroller.log.format
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_NOTIFICATIONS_CONTROLLER_LOGLEVEL
        valueFrom:
          configMapKeyRef:
            key: notificationscontroller.log.level
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_LOG_FORMAT_TIMESTAMP
        valueFrom:
          configMapKeyRef:
            key: log.format.timestamp
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATION_NAMESPACES
        valueFrom:
          configMapKeyRef:
            key: application.namespaces
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_NOTIFICATION_CONTROLLER_SELF_SERVICE_NOTIFICATION_ENABLED
        valueFrom:
          configMapKeyRef:
            key: notificationscontroller.selfservice.enabled
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_NOTIFICATION_CONTROLLER_REPO_SERVER_PLAINTEXT
        valueFrom:
          configMapKeyRef:
            key: notificationscontroller.repo.server.plaintext
            name: argocd-cmd-params-cm
            optional: true
    envFrom:
      {{- with ( concat $ctrs.notificationscontroller.extraEnvFrom 
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
      {{- with ( concat $ctrs.notificationscontroller.extraVolumeMounts 
                        $pod.extraVolumeMounts
                        $global.extraVolumeMounts) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: tls-certs
        mountPath: /app/config/tls
      - name: repo-server-tls
        mountPath: /app/config/reposerver/tls
    {{- with $ctrs.notificationscontroller.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.notificationscontroller.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}