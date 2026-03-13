#!/usr/bin/env bash
set -euo pipefail

#
# This script is a helper for setting up local linux kernel development environment
# It checks that you have needed software
#

echo "Checking installations and versions..."
echo

try_cmd_version() {
  local name="$1"
  if command -v "$name" >/dev/null 2>&1; then
    local path
    path=$(command -v "$name")
    local ver
    for opt in --version -V -v -version -h; do
      ver=$("$name" $opt 2>&1 | head -n1) || true
      if [[ -n "${ver// }" ]]; then
        printf "%s: found (%s) — %s\n" "$name" "$path" "$ver"
        return 0
      fi
    done
    printf "%s: found (%s) — version output not standard\n" "$name" "$path"
    return 0
  else
    printf "%s: NOT FOUND\n" "$name"
    return 1
  fi
}

try_pkgconfig() {
  local pcname="$1"
  if command -v pkg-config >/dev/null 2>&1; then
    if pkg-config --exists "$pcname" >/dev/null 2>&1; then
      local ver
      ver=$(pkg-config --modversion "$pcname" 2>/dev/null || true)
      if [[ -n "$ver" ]]; then
        printf "%s (pkg-config): %s\n" "$pcname" "$ver"
        return 0
      fi
    fi
  fi
  return 1
}

try_ldconfig_lib() {
  local libname="$1"
  if command -v ldconfig >/dev/null 2>&1; then
    if ldconfig -p 2>/dev/null | grep -i -- "$libname" >/dev/null 2>&1; then
      ldconfig -p 2>/dev/null | grep -i -- "$libname" | head -n1 | awk '{print $1, $NF}' | sed 's/ => / (/; s/$/)/'
      return 0
    fi
  fi
  return 1
}

check_command_list() {
  local -n arr=$1
  for name in "${arr[@]}"; do
    try_cmd_version "$name" || true
  done
}

check_lib_list() {
  local -n arr=$1
  for lib in "${arr[@]}"; do
    if try_pkgconfig "$lib"; then
      continue
    fi
    if [[ "$lib" == "libssl" ]] && command -v openssl >/dev/null 2>&1; then
      printf "openssl: %s\n" "$(openssl version 2>&1 | head -n1)"
      continue
    fi
    if try_ldconfig_lib "$lib"; then
      continue
    fi
    printf "%s: NOT FOUND (tried pkg-config and ldconfig)\n" "$lib"
  done
}

commands=(vim gcc make git bison flex bc cpio python3 perl gitk esmtp mutt "git-email")
libs=(ncurses libssl libelf)

echo "-- Commands/tools --"
check_command_list commands

echo
echo "-- Libraries / dev-libs --"
check_lib_list libs

echo
echo "Done."
