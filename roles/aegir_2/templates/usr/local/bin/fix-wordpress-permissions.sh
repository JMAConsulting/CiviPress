#!/bin/bash

# {{ ansible_managed }}

# Help menu
print_help() {
cat <<-HELP
This script is used to fix the file permissions of a WordPress site. You need
to provide the following argument:

  --site-path: Path to the WordPress site's directory.

Usage: (sudo) ${0##*/} --site-path=PATH
Example: (sudo) ${0##*/} --site-path=/var/aegir/platforms/wordpress/sites/example.org
HELP
exit 0
}

site_path=${1%/}

# Parse Command Line Arguments
while [ "$#" -gt 0 ]; do
  case "$1" in
    --site-path=*)
        site_path="${1#*=}"
        ;;
    --help) print_help;;
    *)
      printf "Error: Invalid argument, run --help for valid arguments.\n"
      exit 1
  esac
  shift
done

if [ -z "${site_path}" ] || [ ! -d "${site_path}/wp-content" ] ; then
  printf "Error: Please provide a valid WordPress site directory.\n"
  exit 1
fi

if [ $(id -u) != 0 ]; then
  printf "Error: You must run this with sudo or root.\n"
  exit 1
fi

cd $site_path

# Relax permissions on wp-content, so that www-data can write in it
# For example, WordFence requires this in order to create wp-content/wflogs
chown aegir.www-data wp-content
chmod 0775 wp-content

# Ensure the basic directories exist
mkdir -p ./wp-content/languages
mkdir -p ./wp-content/plugins
mkdir -p ./wp-content/upgrade
mkdir -p ./wp-content/uploads
mkdir -p ./wp-content/themes

# Set the permissions
# - owner by aegir.www-data (so that Aegir can backup/delete files)
# - www-data can write
# - all directories are setgid to inherit group ownership
chown -R aegir.www-data ./wp-content/{languages,plugins,upgrade,uploads,themes}
chmod -R g+w ./wp-content/{languages,plugins,upgrade,uploads,themes}
find ./wp-content/{languages,plugins,upgrade,uploads,themes}/ -type d -exec chmod g+s {} \;

# Yootheme exception
if [ -d ./wp-content/themes/yootheme ]; then
  mkdir -p ./wp-content/themes/yootheme/cache
  chown -R aegir.www-data ./wp-content/themes/yootheme/cache
  chmod -R g+w ./wp-content/themes/yootheme/cache
  find ./wp-content/themes/yootheme/cache -type d -exec chmod g+s {} \;
fi

# Legacy CiviCRM directory
if [ -d ./wp-content/plugins/files/civicrm ]; then
  chown -R aegir.www-data ./wp-content/plugins/files/civicrm/
  chmod -R g+s ./wp-content/plugins/files/civicrm/
  find ./wp-content/plugins/files/civicrm/ -type d -exec chmod g+s {} \;
fi