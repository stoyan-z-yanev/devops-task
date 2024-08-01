{{/* Define template logic. */}}
{{- define "common.def" -}}
{{- $global := dict "Values" .Values.global -}}
{{- $common := dict "Values" (omit .Values.common "global") -}}
{{- $noCommon := omit .Values "common" -}}
{{- $overrides := dict "Values" (omit $noCommon "global") -}}
{{- $noValues := omit . "Values" -}}
{{ $templateName := printf "common.internal.%s" .template }}
{{- with merge $noValues $global $overrides $common -}}
{{- include $templateName . }}
{{- end -}}
{{- end -}}

{{/* Define Deployment template. */}}
{{- define "common.deployment" -}}
{{- include "common.def" (merge (dict "template" "deployment") .) -}}
{{- end -}}

{{/* Define Job template. */}}
{{- define "common.job" -}}
{{- include "common.def" (merge (dict "template" "job") .) -}}
{{- end -}}

{{/* Define HorizontalPodAutoscaler template. */}}
{{- define "common.horizontalpodautoscaler" -}}
{{- include "common.def" (merge (dict "template" "horizontalpodautoscaler") .) -}}
{{- end -}}

{{/* Define Service template. */}}
{{- define "common.service" -}}
{{- include "common.def" (merge (dict "template" "service") .) -}}
{{- end -}}

{{/* Define Ingress template. */}}
{{- define "common.ingress" -}}
{{- include "common.def" (merge (dict "template" "ingress") .) -}}
{{- end -}}

{{/* Define NetworkPolicy template. */}}
{{- define "common.networkpolicy" -}}
{{- include "common.def" (merge (dict "template" "networkpolicy") .) -}}
{{- end -}}

{{/* Define Secret template. */}}
{{- define "common.secret" -}}
{{- include "common.def" (merge (dict "template" "secret") .) -}}
{{- end -}}
