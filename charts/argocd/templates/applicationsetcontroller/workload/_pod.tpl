{{/*
Pod Spec
*/}}
{{- define "argocd.applicationsetcontroller.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.applicationsetcontroller -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-applicationsetcontroller
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
  - configMap:
      name: argocd-ssh-known-hosts-cm
    name: ssh-known-hosts
  - configMap:
      name: argocd-tls-certs-cm
    name: tls-certs
  - configMap:
      name: argocd-gpg-keys-cm
    name: gpg-keys
  - emptyDir: {}
    name: gpg-keyring
  - emptyDir: {}
    name: tmp
  - name: argocd-repo-server-tls
    secret:
      items:
      - key: tls.crt
        path: tls.crt
      - key: tls.key
        path: tls.key
      - key: ca.crt
        path: ca.crt
      optional: true
      secretName: argocd-repo-server-tls
  - configMap:
      items:
      - key: applicationsetcontroller.profile.enabled
        path: profiler.enabled
      name: argocd-cmd-params-cm
      optional: true
    name: argocd-cmd-params-cm
{{- with (concat $pod.initContainers) }}
initContainers:
  {{- . | toYaml | nindent 2 }}
{{- end }}
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: applicationsetcontroller
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.applicationsetcontroller.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    env:
      {{- with ( concat $ctrs.applicationsetcontroller.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: GRPC_ENABLE_TXT_SERVICE_CONFIG
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.grpc.enable.txt.service.config
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_GLOBAL_PRESERVED_ANNOTATIONS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.global.preserved.annotations
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_GLOBAL_PRESERVED_LABELS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.global.preserved.labels
            name: argocd-cmd-params-cm
            optional: true
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_LEADER_ELECTION
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.leader.election
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_REPO_SERVER
        valueFrom:
          configMapKeyRef:
            key: repo.server
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_POLICY
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.policy
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_POLICY_OVERRIDE
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.policy.override
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_DEBUG
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.debug
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_LOGFORMAT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.log.format
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_LOGLEVEL
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.log.level
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_LOG_FORMAT_TIMESTAMP
        valueFrom:
          configMapKeyRef:
            key: log.format.timestamp
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_CLIENT_QPS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.client.qps
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_CLIENT_BURST
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.client.burst
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_CLIENT_MAX_IDLE_CONNECTIONS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.client.max.idle.connections
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_TCP_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.tcp.timeout
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_TCP_KEEPALIVE
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.tcp.keepalive
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_TLS_HANDSHAKE_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.tls.handshake.timeout
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_K8S_TCP_IDLE_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.k8s.tcp.idle.timeout
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_DRY_RUN
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.dryrun
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_GIT_MODULES_ENABLED
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.git.submodule
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_PROGRESSIVE_SYNCS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.progressive.syncs
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_TOKENREF_STRICT_MODE
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.tokenref.strict.mode
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_NEW_GIT_FILE_GLOBBING
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.new.git.file.globbing
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_REPO_SERVER_PLAINTEXT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.repo.server.plaintext
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_REPO_SERVER_STRICT_TLS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.repo.server.strict.tls
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_REPO_SERVER_TIMEOUT_SECONDS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.repo.server.timeout.seconds
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_CONCURRENT_RECONCILIATIONS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.concurrent.reconciliations.max
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_NAMESPACES
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.namespaces
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_SCM_ROOT_CA_PATH
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.scm.root.ca.path
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ALLOWED_SCM_PROVIDERS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.allowed.scm.providers
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_SCM_PROVIDERS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.scm.providers
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_ENABLE_GITHUB_API_METRICS
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.enable.github.api.metrics
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_WEBHOOK_PARALLELISM_LIMIT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.webhook.parallelism.limit
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_REQUEUE_AFTER
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.requeue.after
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_APPLICATIONSET_CONTROLLER_MAX_RESOURCES_STATUS_COUNT
        valueFrom:
          configMapKeyRef:
            key: applicationsetcontroller.status.max.resources.count
            name: argocd-cmd-params-cm
            optional: true
    {{- with ( concat $ctrs.applicationsetcontroller.extraEnvFrom 
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
      {{- with ( concat $ctrs.applicationsetcontroller.extraVolumeMounts 
                        $pod.extraVolumeMounts
                        $global.extraVolumeMounts) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - mountPath: /app/config/ssh
        name: ssh-known-hosts
      - mountPath: /app/config/tls
        name: tls-certs
      - mountPath: /app/config/gpg/source
        name: gpg-keys
      - mountPath: /app/config/gpg/keys
        name: gpg-keyring
      - mountPath: /tmp
        name: tmp
      - mountPath: /app/config/reposerver/tls
        name: argocd-repo-server-tls
      - mountPath: /home/argocd/params
        name: argocd-cmd-params-cm
    {{- with $ctrs.applicationsetcontroller.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.applicationsetcontroller.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}