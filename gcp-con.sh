#!/usr/bin/env bash

set -euo pipefail

# --- Usage / Help ---
usage() {
  echo "Usage: $(basename "$0") [host_number]"
  echo
  echo "  No parameter:    shows interactive list of running GCP VMs"
  echo "  [host_number]:   connects directly to VM with given number"
  echo
  echo "Examples:"
  echo "  $(basename "$0")      # interactive selection"
  echo "  $(basename "$0") 0    # connects to first VM in the list"
  echo "  $(basename "$0") -h   # shows this help"
  exit 0
}

[[ "${1:-}" == "-h" || "${1:-}" == "--help" ]] && usage

# check if we have all needed commands
if ! command -v gcloud &>/dev/null; then
  echo "Error: command 'gcloud' not found." >&2
  exit 1
fi

GCLOUD_PROJECT="${GCLOUD_PROJECT:-$(gcloud config get-value project 2>/dev/null || true)}"
if [[ -z "${GCLOUD_PROJECT}" || "${GCLOUD_PROJECT}" == "(unset)" ]]; then
  echo "Error: GCP project not set. Use GCLOUD_PROJECT env var or 'gcloud config set project'." >&2
  exit 1
fi
echo "Using GCP project: ${GCLOUD_PROJECT}" >&2

# check if we have any running VM instances and get their names and zones
allHosts=()
allZones=()
while IFS=$'\t' read -r name zone; do
  allHosts+=("$name")
  allZones+=("$zone")
done < <(gcloud compute instances list \
  --project="${GCLOUD_PROJECT}" \
  --filter="STATUS=RUNNING" \
  --format="value(name,zone)")

totalHosts="${#allHosts[@]}"

if [[ ${totalHosts} -eq 0 ]]; then
  echo "There are no running VM instances." >&2
  exit 1
fi

# check if user launch the script with parameter
targetHost="${1:-}"
if [[ -z "${targetHost}" ]]; then
  echo "Found ${totalHosts} running VM instances:"
  for ((i = 0; i < totalHosts; i++)); do
    echo "${i}: ${allHosts[${i}]}"
  done

  printf 'Please, choose the host number: '
  read -r targetHost || {
    echo "Cancelled." >&2
    exit 1
  }
  echo

  if [[ -z "${targetHost}" ]]; then
    echo "No host selected." >&2
    exit 1
  fi
fi

# check if user choice is in range of totalHosts
if [[ ${targetHost} =~ ^[0-9]+$ ]] && ((0 <= targetHost)) && ((targetHost < totalHosts)); then
  MYHOST="${allHosts[${targetHost}]}"
  echo "VM  : $MYHOST" >&2
  MYZONE="${allZones[${targetHost}]}"
  echo "Zone: $MYZONE" >&2
  echo
  echo "We are connecting to $MYHOST ..." >&2
  echo
  gcloud --project="${GCLOUD_PROJECT}" compute ssh "${MYHOST}" \
    --zone="${MYZONE}" \
    --tunnel-through-iap
else
  echo "Sorry, host: >>> ${targetHost} <<< doesn't exist." >&2
  exit 1
fi

echo
echo "Bye, bye..." >&2
exit 0
