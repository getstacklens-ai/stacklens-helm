{{- define "stacklens-platform.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stacklens-platform.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{- define "stacklens-platform.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "stacklens-platform.labels" -}}
helm.sh/chart: {{ include "stacklens-platform.chart" . }}
{{ include "stacklens-platform.selectorLabels" . }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end -}}

{{- define "stacklens-platform.selectorLabels" -}}
app.kubernetes.io/name: {{ include "stacklens-platform.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{- define "stacklens-platform.identity.name" -}}
{{- printf "%s-identity" (include "stacklens-platform.fullname" .) -}}
{{- end -}}

{{- define "stacklens-platform.flowops.name" -}}
{{- printf "%s-flowops" (include "stacklens-platform.fullname" .) -}}
{{- end -}}

{{- define "stacklens-platform.gateway.name" -}}
{{- printf "%s-gateway" (include "stacklens-platform.fullname" .) -}}
{{- end -}}

{{- define "stacklens-platform.ui.name" -}}
{{- printf "%s-ui" (include "stacklens-platform.fullname" .) -}}
{{- end -}}

{{- define "stacklens-platform.secretName" -}}
{{- if .Values.secrets.existingSecret -}}
{{- .Values.secrets.existingSecret -}}
{{- else -}}
{{- printf "%s-credentials" (include "stacklens-platform.fullname" .) -}}
{{- end -}}
{{- end -}}

{{/* Bitnami PostgreSQL primary Service (standalone). */}}
{{- define "stacklens-platform.postgresql.primaryHost" -}}
{{- if .Values.postgresql.primaryHostOverride -}}
{{- .Values.postgresql.primaryHostOverride -}}
{{- else if .Values.global.postgresql.fullnameOverride -}}
{{- .Values.global.postgresql.fullnameOverride -}}
{{- else if .Values.postgresql.fullnameOverride -}}
{{- .Values.postgresql.fullnameOverride -}}
{{- else -}}
{{- printf "%s-postgresql" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Bitnami Redis master Service (standalone). */}}
{{- define "stacklens-platform.redis.masterHost" -}}
{{- if .Values.redis.masterHostOverride -}}
{{- .Values.redis.masterHostOverride -}}
{{- else -}}
{{- printf "%s-redis-master" .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* StackLens application image tag (defaults to chart appVersion). */}}
{{- define "stacklens-platform.images.tag" -}}
{{- default .Chart.AppVersion .Values.images.tag -}}
{{- end -}}
