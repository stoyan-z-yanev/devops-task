{{/* Format the name of the chart. */}}
{{- define "common.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Expand the name of the chart. */}}
{{- define "common.name" -}}
{{- if eq .Values.environment "pr" -}}
{{- printf "%s-%s%d" .Chart.Name .Values.environment .Values.PRNumber -}}
{{- else -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Create a default fully qualified app name. */}}
{{- define "common.fullname" -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/* Create a default namespace name. */}}
{{- define "common.namespace" -}}
{{- if eq .Values.namespace "default" -}}
{{- .Values.namespace -}}
{{- else -}}
{{- printf "%s-%s" .Values.namespace .Values.environment | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}

{{/* Create a default lb hostname. */}}
{{- define "common.lbhostname" -}}
{{ .Values.tags.serviceName }}.{{ .Values.clusterHostname }}
{{- end -}}

{{/* Create a default hostname based on environment. */}}
{{- define "common.hostname" -}}
{{- if eq .Values.environment "pr" -}}
{{- printf "%s%d-%s" .Values.environment .Values.PRNumber .Values.ingress.domain -}}
{{- else -}}
{{ .Values.tags.serviceName }}.{{ .Values.ingress.domain }}
{{- end -}}
{{- end -}}

{{/* Create tags for the application. */}}
{{- define "common.tags" -}}
{{- $serviceCatalogueId := printf "ServiceCatalogueId=%d" (int64 .Values.tags.serviceCatalogueId) -}}
{{- $serviceName := printf "ServiceName=%s" .Values.tags.serviceName -}}
{{- $environment := printf "Environment=%s" .Values.environment -}}
{{- printf "%s,%s,%s" $serviceCatalogueId $serviceName $environment | quote -}}
{{- end -}}

{{/* Create labels for the application. */}}
{{- define "common.labels" -}}
labels:
  app.kubernetes.io/name: {{ include "common.name" . }}
  app.kubernetes.io/instance: {{ .Release.Name }}
  app.kubernetes.io/managed-by: {{ .Release.Service }}
  helm.sh/chart: {{ include "common.chart" . }}
  helm.sh/release: {{ .Values.RELEASE }}
  news.co.uk/service-catalogue-id: {{ .Values.tags.serviceCatalogueId | quote }}
  news.co.uk/service-name: {{ .Values.tags.serviceName }}
  news.co.uk/environment: {{ .Values.environment }}
{{- end -}}

{{/* Create internal metadata. */}}
{{- define "common.imetadata" -}}
namespace: {{ include "common.namespace" . }}
{{ include "common.labels" . }}
{{- end -}}

{{/* Create metadata. */}}
{{- define "common.metadata" -}}
metadata:
  name: {{ include "common.name" . }}
{{ include "common.imetadata" . | indent 2 }}
{{- end -}}

{{/* Load secrets. */}}
{{- define "common.secretenvs" -}}
{{- if .Values.hasSecret }}
{{- $localSecrets := .Values.secretName -}}
{{- range $secret, $items := .Values.secrets }}
{{- $secretName := regexFind "\\w+" $secret -}}
{{- $realSecretName := $secret -}}
{{- if has $secretName $localSecrets -}}
{{- range $key, $value :=  $items }}
{{- if or (and (ne $.Values.environment "pr") (ne $.Values.environment "local")) (ne $secretName "apollo") }}
- name: {{ $key }}
  valueFrom:
    secretKeyRef:
      name: {{ $realSecretName }}
      key: {{ $key }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
