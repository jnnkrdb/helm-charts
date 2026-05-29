{{/*
Pod Spec
*/}}
{{- define "argocd.dexidp.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.dexidp -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-dexidp
imagePullSecrets:
  {{- include "common.imagePullSecrets" ( 
      dict "imagePullSecrets" (concat $global.imagePullSecrets
                                      $pod.imagePullSecrets
                                      $imgs.dexidp.imagePullSecrets
                                      $imgs.argocd.imagePullSecrets )) | nindent 2 }}
volumes:
  {{- with (concat $global.extraVolumes 
                  $pod.extraVolumes) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - emptyDir: {}
    name: static-files
  - emptyDir: {}
    name: dexconfig
  - name: argocd-dex-server-tls
    secret:
      items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
      - key: ca.crt
        path: ca.crt
      optional: true
      secretName: argocd-dex-server-tls
initContainers:
  {{- with (concat $pod.initContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: copyutil
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.copyutil.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.copyutil.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.copyutil.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.copyutil.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.copyutil.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.copyutil.extraEnvs 
                      $pod.extraEnvs) }}
    env:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with ( concat $ctrs.copyutil.extraEnvFrom 
                      $pod.extraEnvFrom) }}
    envFrom:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    volumeMounts:
      {{- with ( concat $ctrs.copyutil.extraVolumeMounts 
                        $pod.extraVolumeMounts
                        $global.extraVolumeMounts) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - mountPath: /shared
        name: static-files
      - mountPath: /tmp
        name: dexconfig
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: dexidp
    image: {{ include "common.image" ( dict "img" $imgs.dexidp "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.dexidp.imagePullPolicy )) }}
    {{- with $ctrs.dexidp.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.dexidp.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.dexidp.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.dexidp.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.dexidp.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    env:
      {{- with ( concat $ctrs.dexidp.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: ARGOCD_DEX_SERVER_LOGFORMAT
        valueFrom:
          configMapKeyRef:
            key: dexserver.log.format
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_DEX_SERVER_LOGLEVEL
        valueFrom:
          configMapKeyRef:
            key: dexserver.log.level
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_LOG_FORMAT_TIMESTAMP
        valueFrom:
          configMapKeyRef:
            key: log.format.timestamp
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_DEX_SERVER_DISABLE_TLS
        valueFrom:
          configMapKeyRef:
            key: dexserver.disable.tls
            name: argocd-cmd-params-cm
            optional: true
    {{- with ( concat $ctrs.dexidp.extraEnvFrom 
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
    volumeMounts:
      {{- with ( concat $ctrs.dexidp.extraVolumeMounts 
                        $pod.extraVolumeMounts
                        $global.extraVolumeMounts) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - mountPath: /shared
        name: static-files
      - mountPath: /tmp
        name: dexconfig
      - mountPath: /tls
        name: argocd-dex-server-tls
    {{- with $ctrs.dexidp.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.dexidp.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.dexidp.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}