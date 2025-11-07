#!/usr/bin/env bash

# Script to read config.yaml and generate secrets_and_variables.txt
# This script maps values from config.yaml to GitHub secrets and variables format

set -euo pipefail

CONFIG_FILE="config.yaml"
SECRETS_FILE="secrets-variables.txt"

# Check if config file exists
if [[ ! -f "${CONFIG_FILE}" ]]; then
  echo "[ERROR] Config file '${CONFIG_FILE}' not found." >&2
  exit 1
fi

# Function to get value from config.yaml using grep and sed
get_config_value() {
  local key_path="$1"
  local file="$CONFIG_FILE"
  
  # Convert dot notation to actual YAML path search
  case "$key_path" in
    "tre_id")
      grep "^tre_id:" "$file" | sed 's/tre_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "location") 
      grep "^location:" "$file" | sed 's/location:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.mgmt_resource_group_name")
      grep -A 20 "^management:" "$file" | grep "mgmt_resource_group_name:" | sed 's/.*mgmt_resource_group_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.mgmt_storage_account_name")
      grep -A 20 "^management:" "$file" | grep "mgmt_storage_account_name:" | sed 's/.*mgmt_storage_account_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.terraform_state_container_name")
      grep -A 20 "^management:" "$file" | grep "terraform_state_container_name:" | sed 's/.*terraform_state_container_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.acr_name")
      grep -A 20 "^management:" "$file" | grep "acr_name:" | sed 's/.*acr_name:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.arm_subscription_id")
      grep -A 20 "^management:" "$file" | grep "arm_subscription_id:" | sed 's/.*arm_subscription_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "management.disable_acr_public_access")
      grep -A 20 "^management:" "$file" | grep "disable_acr_public_access:" | sed 's/.*disable_acr_public_access:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.aad_tenant_id")
      grep -A 30 "^authentication:" "$file" | grep "aad_tenant_id:" | sed 's/.*aad_tenant_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.api_client_id")
      grep -A 30 "^authentication:" "$file" | grep "api_client_id:" | sed 's/.*api_client_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.api_client_secret")
      grep -A 30 "^authentication:" "$file" | grep "api_client_secret:" | sed 's/.*api_client_secret:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.application_admin_client_id")
      grep -A 30 "^authentication:" "$file" | grep "application_admin_client_id:" | sed 's/.*application_admin_client_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.application_admin_client_secret")
      grep -A 30 "^authentication:" "$file" | grep "application_admin_client_secret:" | sed 's/.*application_admin_client_secret:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.test_account_client_id")
      grep -A 30 "^authentication:" "$file" | grep "test_account_client_id:" | sed 's/.*test_account_client_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.test_account_client_secret")
      grep -A 30 "^authentication:" "$file" | grep "test_account_client_secret:" | sed 's/.*test_account_client_secret:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.swagger_ui_client_id")
      grep -A 30 "^authentication:" "$file" | grep "swagger_ui_client_id:" | sed 's/.*swagger_ui_client_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.workspace_api_client_id")
      grep -A 30 "^authentication:" "$file" | grep "workspace_api_client_id:" | sed 's/.*workspace_api_client_id:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.workspace_api_client_secret")
      grep -A 30 "^authentication:" "$file" | grep "workspace_api_client_secret:" | sed 's/.*workspace_api_client_secret:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.auto_workspace_app_registration")
      grep -A 30 "^authentication:" "$file" | grep "auto_workspace_app_registration:" | sed 's/.*auto_workspace_app_registration:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "authentication.auto_workspace_group_creation")
      grep -A 30 "^authentication:" "$file" | grep "auto_workspace_group_creation:" | sed 's/.*auto_workspace_group_creation:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.core_address_space")
      grep -A 50 "^tre:" "$file" | grep "core_address_space:" | sed 's/.*core_address_space:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.tre_address_space")
      grep -A 50 "^tre:" "$file" | grep "tre_address_space:" | sed 's/.*tre_address_space:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.core_app_service_plan_sku")
      grep -A 50 "^tre:" "$file" | grep "core_app_service_plan_sku:" | sed 's/.*core_app_service_plan_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.resource_processor_vmss_sku")
      grep -A 50 "^tre:" "$file" | grep "resource_processor_vmss_sku:" | sed 's/.*resource_processor_vmss_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.enable_swagger")
      grep -A 50 "^tre:" "$file" | grep "enable_swagger:" | sed 's/.*enable_swagger:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.enable_airlock_malware_scanning")
      grep -A 50 "^tre:" "$file" | grep "enable_airlock_malware_scanning:" | sed 's/.*enable_airlock_malware_scanning:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.workspace_app_service_plan_sku")
      grep -A 50 "^tre:" "$file" | grep "workspace_app_service_plan_sku:" | sed 's/.*workspace_app_service_plan_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.firewall_sku")
      grep -A 50 "^tre:" "$file" | grep "firewall_sku:" | sed 's/.*firewall_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.app_gateway_sku")
      grep -A 50 "^tre:" "$file" | grep "app_gateway_sku:" | sed 's/.*app_gateway_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.deploy_bastion")
      grep -A 50 "^tre:" "$file" | grep "deploy_bastion:" | sed 's/.*deploy_bastion:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.bastion_sku")
      grep -A 50 "^tre:" "$file" | grep "bastion_sku:" | sed 's/.*bastion_sku:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "tre.user_management_enabled")
      grep -A 50 "^tre:" "$file" | grep "user_management_enabled:" | sed 's/.*user_management_enabled:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "resource_processor.resource_processor_number_processes_per_instance")
      grep -A 10 "^resource_processor:" "$file" | grep "resource_processor_number_processes_per_instance:" | sed 's/.*resource_processor_number_processes_per_instance:[[:space:]]*//' | sed 's/[[:space:]]*$//' | head -1
      ;;
    "ui_config.ui_site_name")
      grep -A 10 "^ui_config:" "$file" | grep "ui_site_name:" | sed 's/.*ui_site_name:[[:space:]]*"//' | sed 's/".*$//' | head -1
      ;;
    "ui_config.ui_footer_text")
      grep -A 10 "^ui_config:" "$file" | grep "ui_footer_text:" | sed 's/.*ui_footer_text:[[:space:]]*"//' | sed 's/".*$//' | head -1
      ;;
    *)
      echo ""
      ;;
  esac
}

# Function to write to secrets_and_variables.txt
write_secrets_and_variables() {
  echo "Reading config from '${CONFIG_FILE}' and updating '${SECRETS_FILE}'..."
  
  cat > "${SECRETS_FILE}" << 'EOF'
### SECRETS ###
###############
EOF

  # Process secrets mappings
  declare -A secret_mappings=(
    ["TRE_ID"]="tre_id"
    ["AAD_TENANT_ID"]="authentication.aad_tenant_id"
    ["ARM_SUBSCRIPTION_ID"]="management.arm_subscription_id"
    ["ACR_NAME"]="management.acr_name"
    ["MGMT_RESOURCE_GROUP_NAME"]="management.mgmt_resource_group_name"
    ["MGMT_STORAGE_ACCOUNT_NAME"]="management.mgmt_storage_account_name"
    ["API_CLIENT_ID"]="authentication.api_client_id"
    ["API_CLIENT_SECRET"]="authentication.api_client_secret"
    ["APPLICATION_ADMIN_CLIENT_ID"]="authentication.application_admin_client_id"
    ["APPLICATION_ADMIN_CLIENT_SECRET"]="authentication.application_admin_client_secret"
    ["TEST_ACCOUNT_CLIENT_ID"]="authentication.test_account_client_id"
    ["TEST_ACCOUNT_CLIENT_SECRET"]="authentication.test_account_client_secret"
    ["TEST_WORKSPACE_APP_ID"]="authentication.workspace_api_client_id"
    ["TEST_WORKSPACE_APP_SECRET"]="authentication.workspace_api_client_secret"
    ["SWAGGER_UI_CLIENT_ID"]="authentication.swagger_ui_client_id"
    ["TEST_APP_ID"]="authentication.test_account_client_id"
  )

  # Write secrets in the order specified
  secrets_order=(
    "TRE_ID"
    "AAD_TENANT_ID"
    "ARM_SUBSCRIPTION_ID"
    "ACR_NAME"
    "MGMT_RESOURCE_GROUP_NAME"
    "MGMT_STORAGE_ACCOUNT_NAME"
    "API_CLIENT_ID"
    "API_CLIENT_SECRET"
    "APPLICATION_ADMIN_CLIENT_ID"
    "APPLICATION_ADMIN_CLIENT_SECRET"
    "TEST_ACCOUNT_CLIENT_ID"
    "TEST_ACCOUNT_CLIENT_SECRET"
    "TEST_WORKSPACE_APP_ID"
    "TEST_WORKSPACE_APP_SECRET"
    "SWAGGER_UI_CLIENT_ID"
    "TEST_APP_ID"
  )

  for github_var in "${secrets_order[@]}"; do
    config_path="${secret_mappings[$github_var]}"
    value=$(get_config_value "${config_path}")
    
    if [[ -z "$value" ]]; then
      echo "#${github_var}" >> "${SECRETS_FILE}"
    else
      echo "${github_var} ${value}" >> "${SECRETS_FILE}"
    fi
  done

  # Add special cases for AZURE_CREDENTIALS (exception - manually maintained)
  echo "AZURE_CREDENTIALS" >> "${SECRETS_FILE}"
  echo "{" >> "${SECRETS_FILE}"

  subscription_id=$(get_config_value "management.arm_subscription_id")
  tenant_id=$(get_config_value "authentication.aad_tenant_id")
  
  echo "  \"clientId\": \"<Add_Created_SP_Client_ID_With_Owner_Role>\"," >> "${SECRETS_FILE}"
  echo "  \"clientSecret\": \"<Add_Created_SP_Client_Secret_With_Owner_Role>\"," >> "${SECRETS_FILE}"
  
  if [[ -n "$subscription_id" ]]; then
    echo "  \"subscriptionId\": \"${subscription_id}\"," >> "${SECRETS_FILE}"
  else
    echo "  #\"subscriptionId\": \"\"," >> "${SECRETS_FILE}"
  fi
  
  if [[ -n "$tenant_id" ]]; then
    echo "  \"tenantId\": \"${tenant_id}\"" >> "${SECRETS_FILE}"
  else
    echo "  #\"tenantId\": \"\"" >> "${SECRETS_FILE}"
  fi
  
  echo "}" >> "${SECRETS_FILE}"
  echo "===" >> "${SECRETS_FILE}"
  
  # Variables section
  cat >> "${SECRETS_FILE}" << 'EOF'
### VARIABLES ###
#################
EOF

  # Process variables mappings
  declare -A variable_mappings=(
    ["APP_GATEWAY_SKU"]="tre.app_gateway_sku"
    ["CORE_ADDRESS_SPACE"]="tre.core_address_space"
    ["CORE_APP_SERVICE_PLAN_SKU"]="tre.core_app_service_plan_sku"
    ["ENABLE_SWAGGER"]="tre.enable_swagger"
    ["FIREWALL_SKU"]="tre.firewall_sku"
    ["LOCATION"]="location"
    ["RESOURCE_PROCESSOR_NUMBER_PROCESSES_PER_INSTANCE"]="resource_processor.resource_processor_number_processes_per_instance"
    ["TERRAFORM_STATE_CONTAINER_NAME"]="management.terraform_state_container_name"
    ["TRE_ADDRESS_SPACE"]="tre.tre_address_space"
    ["WORKSPACE_APP_SERVICE_PLAN_SKU"]="tre.workspace_app_service_plan_sku"
    ["DISABLE_ACR_PUBLIC_ACCESS"]="management.disable_acr_public_access"
    ["RESOURCE_PROCESSOR_VMSS_SKU"]="tre.resource_processor_vmss_sku"
    ["ENABLE_AIRLOCK_MALWARE_SCANNING"]="tre.enable_airlock_malware_scanning"
    ["DEPLOY_BASTION"]="tre.deploy_bastion"
    ["BASTION_SKU"]="tre.bastion_sku"
    ["USER_MANAGEMENT_ENABLED"]="tre.user_management_enabled"
    ["AUTO_WORKSPACE_APP_REGISTRATION"]="authentication.auto_workspace_app_registration"
    ["AUTO_WORKSPACE_GROUP_CREATION"]="authentication.auto_workspace_group_creation"
    ["UI_SITE_NAME"]="ui_config.ui_site_name"
    ["UI_FOOTER_TEXT"]="ui_config.ui_footer_text"
  )

  # Write variables in the order specified
  variables_order=(
    "APP_GATEWAY_SKU"
    "CORE_ADDRESS_SPACE"
    "CORE_APP_SERVICE_PLAN_SKU"
    "ENABLE_SWAGGER"
    "FIREWALL_SKU"
    "LOCATION"
    "RESOURCE_PROCESSOR_NUMBER_PROCESSES_PER_INSTANCE"
    "TERRAFORM_STATE_CONTAINER_NAME"
    "TRE_ADDRESS_SPACE"
    "WORKSPACE_APP_SERVICE_PLAN_SKU"
    "DISABLE_ACR_PUBLIC_ACCESS"
    "RESOURCE_PROCESSOR_VMSS_SKU"
    "ENABLE_AIRLOCK_MALWARE_SCANNING"
    "DEPLOY_BASTION"
    "BASTION_SKU"
    "USER_MANAGEMENT_ENABLED"
    "AUTO_WORKSPACE_APP_REGISTRATION"
    "AUTO_WORKSPACE_GROUP_CREATION"
    "UI_SITE_NAME"
    "UI_FOOTER_TEXT"
  )

  for github_var in "${variables_order[@]}"; do
    config_path="${variable_mappings[$github_var]}"
    value=$(get_config_value "${config_path}")
    
    if [[ -z "$value" ]]; then
      echo "#${github_var}" >> "${SECRETS_FILE}"
    else
      echo "${github_var} ${value}" >> "${SECRETS_FILE}"
    fi
  done

  # Add AZURE_ENVIRONMENT (exception - hardcoded)
  echo "AZURE_ENVIRONMENT AzureCloud" >> "${SECRETS_FILE}"
  
  echo "Updated '${SECRETS_FILE}' with values from '${CONFIG_FILE}'"
}

# Generate the secrets and variables file
write_secrets_and_variables

echo "Script completed successfully. Check '${SECRETS_FILE}' for the generated content."
