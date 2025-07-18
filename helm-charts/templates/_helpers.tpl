{{/*
Expand the name of the chart.
*/}}
{{- define "eks-app.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
*/}}
{{- define "eks-app.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "eks-app.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "eks-app.labels" -}}
helm.sh/chart: {{ include "eks-app.chart" . }}
{{ include "eks-app.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "eks-app.selectorLabels" -}}
app.kubernetes.io/name: {{ include "eks-app.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Frontend labels
*/}}
{{- define "eks-app.frontend.labels" -}}
{{ include "eks-app.labels" . }}
app.kubernetes.io/component: frontend
{{- end }}

{{/*
Backend labels
*/}}
{{- define "eks-app.backend.labels" -}}
{{ include "eks-app.labels" . }}
app.kubernetes.io/component: backend
{{- end }}