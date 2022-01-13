#  _____ _                           ____             __  __       _     _   ____            _       _
# |_   _| |__   ___ _ __ ___   ___  / ___|  ___ __ _ / _|/ _| ___ | | __| | / ___|  ___ _ __(_)_ __ | |_
#   | | | '_ \ / _ \ '_ ` _ \ / _ \ \___ \ / __/ _` | |_| |_ / _ \| |/ _` | \___ \ / __| '__| | '_ \| __|
#   | | | | | |  __/ | | | | |  __/  ___) | (_| (_| |  _|  _| (_) | | (_| |  ___) | (__| |  | | |_) | |_
#   |_| |_| |_|\___|_| |_| |_|\___| |____/ \___\__,_|_| |_|  \___/|_|\__,_| |____/ \___|_|  |_| .__/ \__|
#                                                                                             |_|

# The paths in this script are relative to where the script is executed from
# although this script lives in `themeName/scripts` it is executed by
# composer.json, which lives in `themeName`
# This script assumes you have a folder within your active theme called "additional-plugins"
# that contains zipped versions of plugins that are not available to be pulled through wp-composer

# Export env vars
if [[ -f '.env' ]]; then
  export $(grep -v '^#' .env | xargs)
fi

# ################# #
# Plugin Extraction #
# ################# #

WORKING_DIR="../../plugins"

if [[ ! -z "$EXTERNAL_INSTALL_DIR" ]]; then
  WORKING_DIR=$(echo ${EXTERNAL_INSTALL_DIR}/wp-content/plugins | tr -d '\r')
elif [[ -z "$PLUGINS_DIR" ]]  && [[ ! -z "$EXTERNAL_INSTALL_DIR" ]]; then
  WORKING_DIR=$(echo "$PLUGINS_DIR" | tr -d '\r')
fi

echo $WORKING_DIR

if [ -e $WORKING_DIR ]; then
  echo "Extracting Additional Plugins.."
  dir="$( cd $WORKING_DIR >/dev/null 2>&1 && pwd )"
  for i in additional-plugins/*.zip; do
    unzip -o -qq "$i" -d "${dir}"
  done;

  rm -rf "${dir}/__MACOSX";
else
  echo "No plugins folder detected"
  exit
fi