{{/*
Chart name (optionally overridden by .Values.nameOverride).
*/}}
{{- define "sample-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels applied to every object. app.kubernetes.io/* are the Kubernetes
recommended labels; `app` and `arc-blueprint` are kept for the selectors and
tooling the blueprint's pipeline already relies on.
*/}}
{{- define "sample-app.labels" -}}
app: {{ include "sample-app.name" . }}
app.kubernetes.io/name: {{ include "sample-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/version: {{ .Values.appVersion | quote }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
app.kubernetes.io/part-of: microservices-eks-blueprint
helm.sh/chart: {{ printf "%s-%s" .Chart.Name .Chart.Version }}
arc-blueprint: microservices-eks
{{- end -}}

{{/*
Selector labels — the stable subset used by the Deployment selector and the
Service. MUST NOT include version/instance (they change across releases and
would break the immutable Deployment selector).
*/}}
{{- define "sample-app.selectorLabels" -}}
app: {{ include "sample-app.name" . }}
{{- end -}}
