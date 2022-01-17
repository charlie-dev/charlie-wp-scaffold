#  ____        _        _                      ____                      _       ____            _
# |  _ \  __ _| |_ __ _| |__   __ _ ___  ___  / ___|  ___  __ _ _ __ ___| |__   |  _ \ ___ _ __ | | __ _  ___ ___
# | | | |/ _` | __/ _` | '_ \ / _` / __|/ _ \ \___ \ / _ \/ _` | '__/ __| '_ \  | |_) / _ \ '_ \| |/ _` |/ __/ _ \
# | |_| | (_| | || (_| | |_) | (_| \__ \  __/  ___) |  __/ (_| | | | (__| | | | |  _ <  __/ |_) | | (_| | (_|  __/
# |____/ \__,_|\__\__,_|_.__/ \__,_|___/\___| |____/ \___|\__,_|_|  \___|_| |_| |_| \_\___| .__/|_|\__,_|\___\___|
#                                                                                         |_|

installPath='../../../'
questionOptions=('Y', 'y', 'N', 'n')

if [[ ! -z "$EXTERNAL_INSTALL_DIR" ]]; then
  installPath=$EXTERNAL_INSTALL_DIR
fi

cd $installPath

wpCliExists=`command -v wp > /dev/null && echo 'true' ||  echo 'false'`

if [[ $wpCliExists == 'true' ]]; then

  confirm_dry_run () {
    DRY_RUN=

    while [[ $DRY_RUN = "" ]] || [[ ! ${questionOptions[@]} =~ $DRY_RUN ]]; do
      echo $DRY_RUN
      echo -e "\033[34mRun as dry run? No changes will be saved (Y/N):\e[0m"
      read DRY_RUN
      DRY_RUN=`echo "$DRY_RUN" | tr '[:upper:]' '[:lower:]'`
    done

  }

  echo -e "\033[34mWhat is the value you want to search for:\e[0m"
  read
  SEARCH="$REPLY"

  echo -e "\033[34mWhat is the value you want to replace it with:\e[0m"
  read
  REPLACE="$REPLY"

  confirm_dry_run

  if [[ "$DRY_RUN" == 'y' ]]; then
    echo 'Running Dry Run'
    replaceResults=`wp search-replace $SEARCH $REPLACE --report-changed-only --dry-run | grep 'Success:' 2>&1`
  else
    CONFIRM_DRY_RUN=
    while [[ $CONFIRM_DRY_RUN = "" ]]; do
      echo -e "\e[31mAre You Sure? Please ensure you have a backup just incase (Y/N):\e[0m"
      read CONFIRM_DRY_RUN
    done
    CONFIRM_DRY_RUN=`echo "$CONFIRM_DRY_RUN" | tr '[:upper:]' '[:lower:]'`

    if [[ "$CONFIRM_DRY_RUN" == 'y' ]]; then
      replaceResults=`wp search-replace $SEARCH $REPLACE --report-changed-only | grep 'Success:' 2>&1`
    else
      replaceResults="Skipped"
    fi
  fi


  if [[ "$replaceResults" == *"Success:"* ]]; then
    echo -e "\033[32m${replaceResults}\e[0m"
  else
    echo -e "\033[31m${replaceResults}\e[0m"
  fi

else
  echo -e "\033[31mYou do not have the Wordpress CLI Tool installed (check out https://wp-cli.org/#installing)\e[0m"
fi

