#!/usr/bin/env bash
set -euo pipefail

ENV="${1:?Environment is required (devel or stage)}"
PROJECT_NAME="${PROJECT_NAME:-rdicidr}"
VAR_FILE="${ENV}.tfvars"
RESOURCE_PREFIX="${PROJECT_NAME}-${ENV}"
SUBSCRIPTION_ID="${ARM_SUBSCRIPTION_ID:?ARM_SUBSCRIPTION_ID is required}"

BASE="/subscriptions/${SUBSCRIPTION_ID}"
RG="rg-${RESOURCE_PREFIX}"
STORAGE="$(echo "${PROJECT_NAME}${ENV}" | tr '[:upper:]' '[:lower:]' | tr -d '-')"
AFD_PROFILE="afd-profile-${RESOURCE_PREFIX}"
AFD_ENDPOINT="afd-endpoint-${RESOURCE_PREFIX}"

import_resource() {
  local resource_name="$1"
  local resource_id="$2"

  if terraform state show "$resource_name" >/dev/null 2>&1; then
    echo "${resource_name} already in state, skipping"
    return 0
  fi

  if ! az resource show --ids "$resource_id" >/dev/null 2>&1; then
    echo "${resource_name} not found in Azure, skipping import"
    return 0
  fi

  echo "Importing ${resource_name}..."
  terraform import -var-file="$VAR_FILE" "$resource_name" "$resource_id"
}

import_resource "azurerm_resource_group.main" \
  "${BASE}/resourceGroups/${RG}"

import_resource "azurerm_storage_account.web" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Storage/storageAccounts/${STORAGE}"

import_resource "azurerm_cdn_frontdoor_profile.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}"

import_resource "azurerm_cdn_frontdoor_endpoint.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}/afdEndpoints/${AFD_ENDPOINT}"

import_resource "azurerm_cdn_frontdoor_origin_group.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}/originGroups/default-origin-group"

import_resource "azurerm_cdn_frontdoor_origin.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}/originGroups/default-origin-group/origins/blob-origin"

import_resource "azurerm_cdn_frontdoor_route.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}/afdEndpoints/${AFD_ENDPOINT}/routes/default-route"

import_resource "azurerm_log_analytics_workspace.main" \
  "${BASE}/resourceGroups/${RG}/providers/Microsoft.OperationalInsights/workspaces/law-${RESOURCE_PREFIX}"

PROFILE_ID="${BASE}/resourceGroups/${RG}/providers/Microsoft.Cdn/profiles/${AFD_PROFILE}"

if terraform state show "azurerm_monitor_diagnostic_setting.cdn" >/dev/null 2>&1; then
  echo "azurerm_monitor_diagnostic_setting.cdn already in state, skipping"
elif az monitor diagnostic-settings show \
  --name "cdn-access-logs" \
  --resource "$PROFILE_ID" >/dev/null 2>&1; then
  echo "Importing azurerm_monitor_diagnostic_setting.cdn..."
  terraform import -var-file="$VAR_FILE" \
    "azurerm_monitor_diagnostic_setting.cdn" \
    "${PROFILE_ID}|cdn-access-logs"
else
  echo "azurerm_monitor_diagnostic_setting.cdn not found in Azure, skipping import"
fi
