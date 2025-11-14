#Prerequisites:
# - GitHub CLI (gh) installed
# - GitHub CLI authenticated
# - Secrets definition file (secrets_and_variables.txt) in the current directory
#!/usr/bin/env bash

set -euo pipefail

REPO="aip-aca/AzureTREDeploy-dev03"
# Set to empty string to use repository-level secrets (accessible to all environments)
# Or set to specific environment name like "CICD", "DEV", etc.
ENVIRONMENT="${GITHUB_ENVIRONMENT:-Dev}"
# Set to "repo" to set repository-level secrets, or "env" to set environment-level secrets
SECRET_SCOPE="${GITHUB_SECRET_SCOPE:-env}"
SECRETS_FILE="secrets-variables.env"
AZURE_CREDS_FILE="AZURE_CREDENTIALS.env"

command -v gh >/dev/null 2>&1 || {
  echo "[ERROR] GitHub CLI (gh) not found in PATH. Install it from https://cli.github.com/ and ensure it is authenticated." >&2
  exit 1
}

if ! gh auth status >/dev/null 2>&1; then
  echo "[ERROR] GitHub CLI is not authenticated. Run 'gh auth login' with a token that has 'repo' and 'secrets' scopes." >&2
  exit 1
fi

if [[ ! -f "${SECRETS_FILE}" ]]; then
  echo "[ERROR] Secrets definition file '${SECRETS_FILE}' not found." >&2
  exit 1
fi

# Only ensure environment exists if we're setting environment-level secrets
if [[ "${SECRET_SCOPE}" == "env" && -n "${ENVIRONMENT}" ]]; then
  echo "Ensuring environment '${ENVIRONMENT}' exists in ${REPO}..."
  if gh api \
    --method GET \
    --silent \
    "repos/${REPO}/environments/${ENVIRONMENT}" >/dev/null 2>&1; then
    echo "Environment '${ENVIRONMENT}' already exists."
  else
    gh api \
      --method PUT \
      "repos/${REPO}/environments/${ENVIRONMENT}" \
      --silent \
      >/dev/null
    echo "Environment '${ENVIRONMENT}' created."
  fi
fi

parse_file() {
  declare -gA secrets
  declare -gA variables

  local section="secrets"
  local line key value

  while IFS= read -r line || [[ -n "$line" ]]; do
    line="${line%%$'\r'}"

    if [[ -z "${line}" ]]; then
      continue
    fi

    if [[ "${line}" == "===" ]]; then
      section="variables"
      continue
    fi

    if [[ "${line}" =~ ^[[:space:]]*# ]]; then
      continue
    fi

    # Extract key (everything before first whitespace)
    key="${line%%[[:space:]]*}"
    # Extract value (everything after the key, trimmed)
    value="${line#${key}}"
    # Trim all leading and trailing whitespace (spaces, tabs, newlines)
    value="${value#"${value%%[![:space:]]*}"}"  # Remove leading whitespace
    value="${value%"${value##*[![:space:]]}"}"  # Remove trailing whitespace

    if [[ "${section}" == "secrets" ]]; then
      if [[ -z "${value}" ]]; then
        echo "[ERROR] Secret '${key}' is missing a value." >&2
        exit 1
      fi
      secrets["${key}"]="${value}"
    else
      if [[ -z "${value}" ]]; then
        echo "[ERROR] Variable '${key}' is missing a value." >&2
        exit 1
      fi
      variables["${key}"]="${value}"
    fi
  done < "${SECRETS_FILE}"

  if [[ ${#secrets[@]} -eq 0 ]]; then
    echo "[WARNING] No secrets defined in '${SECRETS_FILE}'."
  fi

  if [[ ${#variables[@]} -eq 0 ]]; then
    echo "[WARNING] No variables defined in '${SECRETS_FILE}'."
  fi
}

parse_file

# Set secrets
for key in "${!secrets[@]}"; do
  if [[ "${SECRET_SCOPE}" == "env" && -n "${ENVIRONMENT}" ]]; then
    echo "Setting environment secret '${key}' in environment '${ENVIRONMENT}'..."
    printf '%s' "${secrets["${key}"]}" | gh secret set "${key}" --env "${ENVIRONMENT}" --repo "${REPO}" --body - >/dev/null
    echo "Environment secret '${key}' set."
  else
    echo "Setting repository secret '${key}'..."
    printf '%s' "${secrets["${key}"]}" | gh secret set "${key}" --repo "${REPO}" --body - >/dev/null
    echo "Repository secret '${key}' set."
  fi
done

# Set variables (always environment-level if environment is specified, otherwise repository-level)
for key in "${!variables[@]}"; do
  if [[ -n "${ENVIRONMENT}" ]]; then
    echo "Setting environment variable '${key}' in environment '${ENVIRONMENT}'..."
    gh variable set "${key}" --env "${ENVIRONMENT}" --repo "${REPO}" --body "${variables["${key}"]}" >/dev/null
    echo "Environment variable '${key}' set."
  else
    echo "Setting repository variable '${key}'..."
    gh variable set "${key}" --repo "${REPO}" --body "${variables["${key}"]}" >/dev/null
    echo "Repository variable '${key}' set."
  fi
done

# Handle AZURE_CREDENTIALS separately from AZURE_CREDENTIALS.env file
if [[ -f "${AZURE_CREDS_FILE}" ]]; then
  if [[ "${SECRET_SCOPE}" == "env" && -n "${ENVIRONMENT}" ]]; then
    echo "Setting AZURE_CREDENTIALS secret from '${AZURE_CREDS_FILE}' in environment '${ENVIRONMENT}'..."
    # Read file content exactly as-is, preserving all formatting and spaces
    gh secret set AZURE_CREDENTIALS --env "${ENVIRONMENT}" --repo "${REPO}" --body "$(cat "${AZURE_CREDS_FILE}")" >/dev/null
    echo "AZURE_CREDENTIALS secret set."
  else
    echo "Setting AZURE_CREDENTIALS secret from '${AZURE_CREDS_FILE}' at repository level..."
    gh secret set AZURE_CREDENTIALS --repo "${REPO}" --body "$(cat "${AZURE_CREDS_FILE}")" >/dev/null
    echo "AZURE_CREDENTIALS secret set."
  fi
else
  echo "[WARNING] AZURE_CREDENTIALS.env file not found. AZURE_CREDENTIALS secret not set."
fi

echo "All done."

