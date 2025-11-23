{{- define "furniture.safeTag" -}}
{{- $tag := .Values.frontend.tag }}
{{- if .Values.tagOverride }}
{{- $tag = .Values.tagOverride }}
{{- end }}
{{- /* replace dots with dashes to make a DNS-safe fragment */ -}}
{{- replace $tag "." "-" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "furniture.host" -}}
{{- $base := .Values.baseDomain -}}
{{- printf "%s%s.%s" .Release.Name (include "furniture.safeTag" .) $base -}}
{{- end -}}{{- define "furniture.fullname" -}}
{{- printf "%s" .Release.Name -}}
{{- end -}}