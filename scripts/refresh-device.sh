#!/usr/bin/env bash
set -euo pipefail

# Rebuilds and reinstalls the app on a paired iOS device to refresh a free
# Xcode Personal Team provisioning profile before its 7-day expiry.
#
# Usage:
#   ./scripts/refresh-device.sh
#   DEVICE_NAME=fnt ./scripts/refresh-device.sh
#   DEVICE_ID=7D35A72C-5F59-5FB1-9D5E-CC1CC4D098EB ./scripts/refresh-device.sh
#   LAUNCH=0 ./scripts/refresh-device.sh
#
# Useful knobs:
#   SCHEME=Reader
#   CONFIGURATION=Debug
#   DERIVED_DATA_PATH=/tmp/ReaderDeviceRefresh
#   BUNDLE_ID=com.sigius.reader
#   DRY_RUN=1

SCHEME="${SCHEME:-Reader}"
CONFIGURATION="${CONFIGURATION:-Debug}"
DERIVED_DATA_PATH="${DERIVED_DATA_PATH:-/tmp/ReaderDeviceRefresh}"
DESTINATION_TIMEOUT="${DESTINATION_TIMEOUT:-60}"
LAUNCH="${LAUNCH:-1}"
DRY_RUN="${DRY_RUN:-0}"

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$repo_root"

log() {
  printf '==> %s\n' "$*" >&2
}

die() {
  printf 'error: %s\n' "$*" >&2
  exit 1
}

print_command() {
  printf '+'
  local arg
  for arg in "$@"; do
    printf ' %q' "$arg"
  done
  printf '\n'
}

run() {
  print_command "$@"
  if [[ "$DRY_RUN" != "1" ]]; then
    "$@"
  fi
}

require_tool() {
  command -v "$1" >/dev/null 2>&1 || die "Required tool not found: $1"
}

plutil_raw() {
  /usr/bin/plutil -extract "$1" raw -o - "$devices_json" 2>/dev/null | tr -d '\r\n'
}

escape_predicate_string() {
  printf '%s' "$1" | sed "s/'/\\\\'/g"
}

detect_device() {
  if [[ -n "${DEVICE_ID:-}" ]]; then
    device_id="$DEVICE_ID"
    device_name="$DEVICE_ID"
    return
  fi

  local filter="hardwareProperties.platform == 'iOS' AND State BEGINSWITH 'available'"
  if [[ -n "${DEVICE_NAME:-}" ]]; then
    local escaped_name
    escaped_name="$(escape_predicate_string "$DEVICE_NAME")"
    filter="$filter AND deviceProperties.name == '$escaped_name'"
  fi

  log "Finding an available paired iOS device"
  xcrun devicectl list devices --filter "$filter" --json-output "$devices_json" >/dev/null

  device_id="$(plutil_raw result.devices.0.identifier)"
  device_name="$(plutil_raw result.devices.0.deviceProperties.name)"
  device_model="$(plutil_raw result.devices.0.hardwareProperties.marketingName)"

  [[ -n "$device_id" ]] || die "No available paired iOS device found. Connect and unlock the device, enable Developer Mode, or set DEVICE_ID."
}

read_build_setting() {
  local key="$1"
  printf '%s\n' "$build_settings" | awk -F' = ' -v key="$key" '
    $1 ~ "^[[:space:]]*" key "$" {
      print $2
      exit
    }
  ' | tr -d '\r'
}

require_tool xcrun
require_tool xcodebuild
[[ -x /usr/bin/plutil ]] || die "Required tool not found: /usr/bin/plutil"

tmp_dir="$(mktemp -d "${TMPDIR:-/tmp}/reader-refresh.XXXXXX")"
trap 'rm -rf "$tmp_dir"' EXIT
devices_json="$tmp_dir/devices.json"

device_id=""
device_name=""
device_model=""
detect_device

log "Device: ${device_name:-unknown} (${device_model:-unknown}) [$device_id]"

xcode_args=(
  -scheme "$SCHEME"
  -configuration "$CONFIGURATION"
  -destination "platform=iOS,id=$device_id"
  -destination-timeout "$DESTINATION_TIMEOUT"
  -derivedDataPath "$DERIVED_DATA_PATH"
  -allowProvisioningUpdates
  -allowProvisioningDeviceRegistration
)

log "Reading build settings"
build_settings="$(xcodebuild "${xcode_args[@]}" -showBuildSettings)"

target_build_dir="$(read_build_setting TARGET_BUILD_DIR)"
full_product_name="$(read_build_setting FULL_PRODUCT_NAME)"
bundle_id="${BUNDLE_ID:-$(read_build_setting PRODUCT_BUNDLE_IDENTIFIER)}"
development_team="$(read_build_setting DEVELOPMENT_TEAM)"

[[ -n "$target_build_dir" ]] || die "Could not read TARGET_BUILD_DIR from xcodebuild."
[[ -n "$full_product_name" ]] || die "Could not read FULL_PRODUCT_NAME from xcodebuild."
[[ -n "$bundle_id" ]] || die "Could not read PRODUCT_BUNDLE_IDENTIFIER from xcodebuild."

app_path="$target_build_dir/$full_product_name"

log "Scheme: $SCHEME ($CONFIGURATION)"
log "Bundle ID: $bundle_id"
[[ -n "$development_team" ]] && log "Development Team: $development_team"

if [[ "$DRY_RUN" == "1" ]]; then
  log "Dry run: build/install/launch commands will be printed but not executed"
fi

run xcodebuild "${xcode_args[@]}" build

if [[ "$DRY_RUN" != "1" && ! -d "$app_path" ]]; then
  die "Built app bundle not found: $app_path"
fi

run xcrun devicectl device install app --device "$device_id" "$app_path"

if [[ "$LAUNCH" == "1" ]]; then
  run xcrun devicectl device process launch --device "$device_id" --terminate-existing "$bundle_id"
else
  log "Launch skipped because LAUNCH=0"
fi

log "Done"
