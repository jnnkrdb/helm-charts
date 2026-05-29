{{/*
Pod Spec
*/}}
{{- define "argocd.reposrv.pod" -}}
{{- $v := .Values -}}
{{- $global := $v.global -}}
{{- $main := $v.reposrv -}}

{{- $wl := $main.workload -}}
{{- $pod := $main.pod -}}
{{- $svc := $main.service -}}

{{- $ctrs := $main.containers -}}
{{- $imgs := $v.images -}}

{{- include "common.podSpec" ( dict "podSpec" $pod ) }}
serviceAccountName: sa-{{ include "common.fullname" . }}-reposrv
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
  - emptyDir: {}
    name: helm-working-dir
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
  - emptyDir: {}
    name: var-files
  - emptyDir: {}
    name: plugins
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
      - mountPath: /var/run/argocd
        name: var-files
containers:
  {{- with (concat $pod.sidecarContainers) }}
  {{- . | toYaml | nindent 2 }}
  {{- end }}
  - name: reposrv
    image: {{ include "common.image" ( dict "img" $imgs.argocd "ctx" $ ) }}
    imagePullPolicy: {{ include "common.firstOf" (
                        dict "items" ( list $global.imagePullPolicy 
                                            $imgs.argocd.imagePullPolicy )) }}
    {{- with $ctrs.reposrv.command }}
    command: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.reposrv.args }}
    args: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.reposrv.securityContext }}
    securityContext: 
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.reposrv.workingDir }}
    workingDir: {{ . | quote }}
    {{- end }}
    {{- with $ctrs.reposrv.resources }}
    resources:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    env:
      {{- with ( concat $ctrs.reposrv.extraEnvs 
                        $pod.extraEnvs) }}
      {{- . | toYaml | nindent 6 }}
      {{- end }}
      - name: NAMESPACE
        valueFrom:
          fieldRef:
            fieldPath: metadata.namespace
      - name: ARGOCD_RECONCILIATION_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: timeout.reconciliation
            name: argocd-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_LOGFORMAT
        valueFrom:
          configMapKeyRef:
            key: reposerver.log.format
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_LOGLEVEL
        valueFrom:
          configMapKeyRef:
            key: reposerver.log.level
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_LOG_FORMAT_TIMESTAMP
        valueFrom:
          configMapKeyRef:
            key: log.format.timestamp
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_PARALLELISM_LIMIT
        valueFrom:
          configMapKeyRef:
            key: reposerver.parallelism.limit
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_LISTEN_ADDRESS
        valueFrom:
          configMapKeyRef:
            key: reposerver.listen.address
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_LISTEN_METRICS_ADDRESS
        valueFrom:
          configMapKeyRef:
            key: reposerver.metrics.listen.address
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_DISABLE_TLS
        valueFrom:
          configMapKeyRef:
            key: reposerver.disable.tls
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_TLS_MIN_VERSION
        valueFrom:
          configMapKeyRef:
            key: reposerver.tls.minversion
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_TLS_MAX_VERSION
        valueFrom:
          configMapKeyRef:
            key: reposerver.tls.maxversion
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_TLS_CIPHERS
        valueFrom:
          configMapKeyRef:
            key: reposerver.tls.ciphers
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_CACHE_EXPIRATION
        valueFrom:
          configMapKeyRef:
            key: reposerver.repo.cache.expiration
            name: argocd-cmd-params-cm
            optional: true
      - name: REDIS_SERVER
        valueFrom:
          configMapKeyRef:
            key: redis.server
            name: argocd-cmd-params-cm
            optional: true
      - name: REDIS_COMPRESSION
        valueFrom:
          configMapKeyRef:
            key: redis.compression
            name: argocd-cmd-params-cm
            optional: true
      - name: REDISDB
        valueFrom:
          configMapKeyRef:
            key: redis.db
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_DEFAULT_CACHE_EXPIRATION
        valueFrom:
          configMapKeyRef:
            key: reposerver.default.cache.expiration
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OTLP_ADDRESS
        valueFrom:
          configMapKeyRef:
            key: otlp.address
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OTLP_INSECURE
        valueFrom:
          configMapKeyRef:
            key: otlp.insecure
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OTLP_HEADERS
        valueFrom:
          configMapKeyRef:
            key: otlp.headers
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OTLP_ATTRS
        valueFrom:
          configMapKeyRef:
            key: otlp.attrs
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_MAX_COMBINED_DIRECTORY_MANIFESTS_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.max.combined.directory.manifests.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_PLUGIN_TAR_EXCLUSIONS
        valueFrom:
          configMapKeyRef:
            key: reposerver.plugin.tar.exclusions
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_PLUGIN_USE_MANIFEST_GENERATE_PATHS
        valueFrom:
          configMapKeyRef:
            key: reposerver.plugin.use.manifest.generate.paths
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_ALLOW_OUT_OF_BOUNDS_SYMLINKS
        valueFrom:
          configMapKeyRef:
            key: reposerver.allow.oob.symlinks
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_STREAMED_MANIFEST_MAX_TAR_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.streamed.manifest.max.tar.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_STREAMED_MANIFEST_MAX_EXTRACTED_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.streamed.manifest.max.extracted.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_HELM_MANIFEST_MAX_EXTRACTED_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.helm.manifest.max.extracted.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_DISABLE_HELM_MANIFEST_MAX_EXTRACTED_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.disable.helm.manifest.max.extracted.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OCI_MANIFEST_MAX_EXTRACTED_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.oci.manifest.max.extracted.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_DISABLE_OCI_MANIFEST_MAX_EXTRACTED_SIZE
        valueFrom:
          configMapKeyRef:
            key: reposerver.disable.oci.manifest.max.extracted.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_OCI_LAYER_MEDIA_TYPES
        valueFrom:
          configMapKeyRef:
            key: reposerver.oci.layer.media.types
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REVISION_CACHE_LOCK_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: reposerver.revision.cache.lock.timeout
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_GIT_MODULES_ENABLED
        valueFrom:
          configMapKeyRef:
            key: reposerver.enable.git.submodule
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_GIT_LS_REMOTE_PARALLELISM_LIMIT
        valueFrom:
          configMapKeyRef:
            key: reposerver.git.lsremote.parallelism.limit
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_GIT_REQUEST_TIMEOUT
        valueFrom:
          configMapKeyRef:
            key: reposerver.git.request.timeout
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_ENABLE_BUILTIN_GIT_CONFIG
        valueFrom:
          configMapKeyRef:
            key: reposerver.enable.builtin.git.config
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_GRPC_MAX_SIZE_MB
        valueFrom:
          configMapKeyRef:
            key: reposerver.grpc.max.size
            name: argocd-cmd-params-cm
            optional: true
      - name: ARGOCD_REPO_SERVER_INCLUDE_HIDDEN_DIRECTORIES
        valueFrom:
          configMapKeyRef:
            key: reposerver.include.hidden.directories
            name: argocd-cmd-params-cm
            optional: true
      - name: HELM_CACHE_HOME
        value: /helm-working-dir
      - name: HELM_CONFIG_HOME
        value: /helm-working-dir
      - name: HELM_DATA_HOME
        value: /helm-working-dir
    envFrom:
      {{- with ( concat $ctrs.reposrv.extraEnvFrom 
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
      {{- with ( concat $ctrs.reposrv.extraVolumeMounts 
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
      - mountPath: /app/config/reposerver/tls
        name: argocd-repo-server-tls
      - mountPath: /tmp
        name: tmp
      - mountPath: /helm-working-dir
        name: helm-working-dir
      - mountPath: /home/argocd/cmp-server/plugins
        name: plugins 
    {{- with $ctrs.reposrv.startupProbe }}
    startupProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.reposrv.livenessProbe }}
    livenessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
    {{- with $ctrs.reposrv.readinessProbe }}
    readinessProbe:
      {{- . | toYaml | nindent 6 }}
    {{- end }}
{{- end }}