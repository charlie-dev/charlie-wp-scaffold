#  ____       _       _____ _   ___     __   ____              _            _   _       _
# / ___|  ___| |_    | ____| \ | \ \   / /  / ___|_ __ ___  __| | ___ _ __ | |_(_) __ _| |___
# \___ \ / _ \ __|   |  _| |  \| |\ \ / /  | |   | '__/ _ \/ _` |/ _ \ '_ \| __| |/ _` | / __|
#  ___) |  __/ |_   _| |___| |\  | \ V /   | |___| | |  __/ (_| |  __/ | | | |_| | (_| | \__ \
# |____/ \___|\__| (_)_____|_| \_|  \_/     \____|_|  \___|\__,_|\___|_| |_|\__|_|\__,_|_|___/

# # Export env vars
if [[ -s .env ]]; then
  export $(grep -v '^#' .env | xargs)
fi

if [[ -z "$THEME_NAME" ]]; then
  echo -e "\033[34mWhat is your theme folder name:\e[0m"
  read
  echo -e "\nTHEME_NAME='$REPLY'" >> .env
fi

if [[ -z "$PLUGINS_DIR" && -z "$EXTERNAL_INSTALL_DIR" ]]; then
  echo -e "\033[34mIs your theme (enter 1 or 2):\e[0m"
  echo -e "\033[34m(1) located within the wordpress install\e[0m"
  echo -e "\033[34m(2) in a seperate location:\e[0m"
  read

  if [[ "$REPLY" == 1 ]] && [[ -z "$PLUGINS_DIR" ]]; then
    echo -e "PLUGINS_DIR='../../plugins'" >> .env
    echo -e "EXTERNAL_INSTALL_DIR=''" >> .env
  elif [[ "$REPLY" == 2 ]] && [[ -z "$EXTERNAL_INSTALL_DIR" ]]; then
    echo -e "\033[34mProvide the path to where your wordpress install is:\e[0m"
    read

    echo -e "PLUGINS_DIR=''" >> .env
    echo -e "EXTERNAL_INSTALL_DIR='$REPLY'" >> .env
  fi
fi
