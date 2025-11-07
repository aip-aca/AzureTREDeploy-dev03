#Prerequisites:
# - GitHub CLI (gh) installed
# - GitHub CLI authenticated
# - Secrets definition file (secrets_and_variables.txt) in the current directory
#!/usr/bin/env bash

set -euo pipefail

REPO="aip-aca/AzureTREDeploy-dev03"
ENVIRONMENT="DEV"

SECRETS_FILE="secrets-variables.txt"

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

parse_file() {
  declare -gA secrets
  declare -gA variables

  local section="secrets"
  local line key value
  local brace_balance json_value json_line

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

    key="${line%%[[:space:]]*}"
    value="${line#${key}}"
    value="${value## }"

    if [[ "${section}" == "secrets" ]]; then
      if [[ "${key}" == "AZURE_CREDENTIALS" && -z "${value}" ]]; then
        json_value=""
        brace_balance=0
        while IFS= read -r json_line || [[ -n "$json_line" ]]; do
          json_line="${json_line%%$'\r'}"

          if [[ -z "${json_line}" ]]; then
            continue
          fi

          if [[ "${json_line}" =~ ^[[:space:]]*# ]]; then
            continue
          fi

          if [[ "${json_line}" == "===" ]]; then
            echo "[ERROR] Unexpected section separator while parsing AZURE_CREDENTIALS JSON." >&2
            exit 1
          fi

          json_value+="${json_line}"$'\n'

          open_braces="${json_line//[^\{]/}"
          close_braces="${json_line//[^\}]/}"
          brace_balance=$((brace_balance + ${#open_braces} - ${#close_braces}))

          if (( brace_balance == 0 )); then
            break
          fi
        done

        if (( brace_balance != 0 )); then
          echo "[ERROR] AZURE_CREDENTIALS JSON is not balanced. Ensure braces match." >&2
          exit 1
        fi

        secrets["${key}"]="${json_value%$'\n'}"
      else
        if [[ -z "${value}" ]]; then
          echo "[ERROR] Secret '${key}' is missing a value." >&2
          exit 1
        fi
        secrets["${key}"]="${value}"
      fi
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

for key in "${!secrets[@]}"; do
  echo "Setting environment secret '${key}'..."
  printf '%s' "${secrets["${key}"]}" | gh secret set "${key}" --env "${ENVIRONMENT}" --repo "${REPO}" --body - >/dev/null
  echo "Environment secret '${key}' set."
done

for key in "${!variables[@]}"; do
  echo "Setting environment variable '${key}'..."
  gh variable set "${key}" --env "${ENVIRONMENT}" --repo "${REPO}" --body "${variables["${key}"]}" >/dev/null
  echo "Environment variable '${key}' set."
done

echo "All done."

