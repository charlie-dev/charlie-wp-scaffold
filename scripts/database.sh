#  ____        _        _                      ____             __  __       _     _ _
# |  _ \  __ _| |_ __ _| |__   __ _ ___  ___  / ___|  ___ __ _ / _|/ _| ___ | | __| (_)_ __   __ _
# | | | |/ _` | __/ _` | '_ \ / _` / __|/ _ \ \___ \ / __/ _` | |_| |_ / _ \| |/ _` | | '_ \ / _` |
# | |_| | (_| | || (_| | |_) | (_| \__ \  __/  ___) | (_| (_| |  _|  _| (_) | | (_| | | | | | (_| |
# |____/ \__,_|\__\__,_|_.__/ \__,_|___/\___| |____/ \___\__,_|_| |_|  \___/|_|\__,_|_|_| |_|\__, |
#                                                                                            |___/

# Confirm user wants to run database scaffold commands
COMMAND_RUN=""
echo -e "\033[34mDo you want to run the database scaffolding? This will activate your theme, activate standard plugins, create homepage post, set base permalink structure. (y/n):\e[0m"
read COMMAND_RUN
COMMAND_RUN=`echo "$COMMAND_RUN" | tr '[:upper:]' '[:lower:]'`

if [[ $COMMAND_RUN == 'y' ]]; then
  # Export env vars
  if [[ -f '.env' ]]; then
    export $(grep -v '^#' .env | xargs)
  fi

  installPath='../../../'

  if [[ ! -z "$EXTERNAL_INSTALL_DIR" ]]; then
    installPath=$EXTERNAL_INSTALL_DIR
  fi

  cd $installPath

  wpCliExists=`command -v wp > /dev/null && echo 'true' ||  echo 'false'`

  if [[ $wpCliExists == 'true' ]]; then

    # Set Theme Name
    set_theme () {
      hasThemeSet=`wp option get template 2>&1`

      if [[ "$hasThemeSet" == *"twentytwenty"* ]] && [[ -z "$THEME_NAME" ]]; then
        themeStylesheetSet=`wp option update stylesheet "${THEME_NAME//[[:space:]]/}" 2>&1`
        sleep 2
        themeSet=`wp option update template "${THEME_NAME//[[:space:]]/}" 2>&1`

        if [[ "$themeSet" == *"Success:"* && "$themeStylesheetSet" == *"Success:"* ]]; then
          echo -e "\033[32mTheme Set Successfully\e[0m"
        fi
      fi
    }

    # Set the homepage
    create_homepage () {
      currentHomepageID=`wp db query "SELECT option_value from wp_options WHERE option_name = 'page_on_front'" --silent --skip-column-names 2>&1`

      if [[ "$currentHomepageID" == "0" ]]; then
        homepageCreated=`wp post create --post_type=page --post_status=publish --post_title=Homepage --page_template='template-home.php' --post_author=1 2>&1`

        if [[ "$homepageCreated" == *"Success:"* ]]; then
          homepageID=`wp db query "SELECT ID from wp_posts WHERE post_title = 'Homepage' ORDER BY post_date DESC LIMIT 1" --silent --skip-column-names 2>&1`

          echo -e "\033[32mHomepage ID ${homepageID}\e[0m"

          # Set WP Options for show_on_front to be a page, and set front page ID to new homepage created
          homepageTypeSet=`wp option update show_on_front page 2>&1`
          homepageIdSet=`wp option update page_on_front "$homepageID" 2>&1`

          # If both commands were ran successfully, output accordingly
          if [[ "$homepageIdSet" == *"Success:"* && "$homepageTypeSet" == *"Success:"* ]]; then
            echo -e "\033[32mHomepage Set Successfully\e[0m"
          fi

        fi
      else
        echo -e "\033[31mHomepage Already Set!\e[0m"
      fi
    }

    # Set base permalink structure
    set_permalinks () {
      hasPermalinksSet=`wp option get permalink_structure 2>&1`

      if [[ -z "$hasPermalinksSet" ]]; then
        permalinksSet=`wp option update permalink_structure "/%postname%/" 2>&1`

        # If both commands were ran successfully, output accordingly
        if [[ "$permalinksSet" == *"Success:"* ]]; then
          echo -e "\033[32mPermalinks Set Successfully\e[0m"
        fi
      else
        echo -e "\033[31mPermalinks Already Set!\e[0m"
      fi
    }

    # Activate default plugins required
    activate_plugins () {
      pluginsSetSuccessfully=`wp plugin activate advanced-custom-fields-pro classic-editor duplicate-page gravityforms safe-svg gravityformscli 2>&1`

      if [[ "$pluginsSetSuccessfully" == *'Success:'* ]]; then
        echo -e "\033[32mPlugins Activated Successfully\e[0m"
      fi
    }

    databaseAccessible=$( wp db size 2>&1)

    # has database connection
    if [[ "$databaseAccessible" != *"Error:"* ]]; then
      echo -e "\033[32mHas database connection!\e[0m"

      set_theme
      create_homepage
      set_permalinks
      activate_plugins

    else # does not have a proper database connection in WP-Config
      echo -e "\033[32mDatabase connection error! Configure your wp-config.php file then run composer install again.\e[0m"
    fi

  else
    echo -e "\033[31mYou do not have the Wordpress CLI Tool installed (check out https://wp-cli.org/#installing)\e[0m"
  fi
fi