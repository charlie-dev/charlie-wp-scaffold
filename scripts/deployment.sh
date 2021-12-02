#   ____          _           _     _         ____             _                                  _     ____            _       _
#  / ___|___   __| | ___  ___| |__ (_)_ __   |  _ \  ___ _ __ | | ___  _   _ _ __ ___   ___ _ __ | |_  / ___|  ___ _ __(_)_ __ | |_
# | |   / _ \ / _` |/ _ \/ __| '_ \| | '_ \  | | | |/ _ \ '_ \| |/ _ \| | | | '_ ` _ \ / _ \ '_ \| __| \___ \ / __| '__| | '_ \| __|
# | |__| (_) | (_| |  __/\__ \ | | | | |_) | | |_| |  __/ |_) | | (_) | |_| | | | | | |  __/ | | | |_   ___) | (__| |  | | |_) | |_
#  \____\___/ \__,_|\___||___/_| |_|_| .__/  |____/ \___| .__/|_|\___/ \__, |_| |_| |_|\___|_| |_|\__| |____/ \___|_|  |_| .__/ \__|
#                                    |_|                |_|            |___/                                             |_|

# This script can be run by passing 3 required flags
# -s : SSH server location
# -d : Root path to your Wordpress install on the destination server
# -t : Wordpress theme folder name
# example command : bash production.sh -s 'charliedevs@charliedevs.ssh.wpengine.net' -d '/sites/charliedevs' -t 'charlie-wp-theme'

while getopts s:d:t: flag
do
    case "${flag}" in
        s) server=${OPTARG};;
        d) destination=${OPTARG};;
        t) themeName=${OPTARG};;
    esac
done

if [ -z "$server" ] || [ -z "$destination" ] || [ -z "$themeName" ]; then
  error=""

  if [ !$server ]
    then
    error="$error Server parameter missing please add using -s 'user@serveraddress.com' \n"
  fi

  if [ !$destination ]
    then
    error="$error Destination parameter missing please add using -d '/path/to/project/root' \n"
  fi

  if [ !$themeName ]
    then
    error="$error Theme Name parameter missing please add using -t 'theme-name' \n"
  fi

  echo "$error"
  exit
fi

projectFolderExists=`ssh "$server" "[ -d $destination ] && echo 'true' || echo 'false'"`
if [ "$projectFolderExists" == "false" ]; then
  echo "******************************"
  echo "Creating Destination Folder..."
  echo "******************************"

  ssh "$server" "mkdir $destination"
  echo "Done..."
fi

sleep 5

projectFilesExist=`ssh "$server" "[ 'ls -A $destination' ] && echo 'Not Empty' || echo 'Empty'"`
wpCliExists=`ssh "$server" "command -v wp > /dev/null && echo 'true' ||  echo 'false'"`

if [ "$projectFilesExist" == "Empty" ]; then
  echo "*********************"
  echo "Installing WP Core..."
  echo "*********************"

  if [ "$wpCliExists" == "false" ]; then
    ssh "$server" "cd $destination &&
      curl -O https://raw.githubusercontent.com/wp-cli/builds/gh-pages/phar/wp-cli.phar
      php wp-cli.phar core download
      rm -r wp-cli.phar
    "
  else
    ssh "$server" "cd $destination && wp core download"
  fi

  echo "Done..."
fi

sleep 5

pluginsFolderExists=`ssh "$server" "[ -d $destination/wp-content/plugins ] && echo 'true' || echo 'false'"`
if [ "$pluginsFolderExists" == "false" ]; then
  echo "******************************"
  echo "Creating Plugins Folder..."
  echo "******************************"

  ssh "$server" "mkdir $destination/wp-content/plugins"
  echo "Done..."
fi

#change to theme framework folder
cd ~/clone/wp-content/themes/$themeName

#Install npm dependicies with YARN & gulp script for yarn prod and copy to themes folder
echo "****************************"
echo "Compiling Assets via Yarn..."
echo "****************************"

yarn build
echo "Done..."

echo "*****************************"
echo "Zipping Themes and Plugins..."
echo "*****************************"

# Zip up theme
cd ~/clone/wp-content/themes/$themeName/build
zip -q -r ../../../theme.zip ./

# Zip up plugins
cd ~/clone/wp-content/plugins
zip -q -r ../plugins.zip ./ -x "index.php"
echo "Done..."

echo "**************************************************"
echo "Copying Theme and Plugin Zips To Server via SCP..."
echo "**************************************************"

# Copy theme and plugin zips to server
scp -rp ~/clone/wp-content/theme.zip "$server:$destination/wp-content/themes"
sleep 10
scp -rp ~/clone/wp-content/plugins.zip "$server:$destination/wp-content/"
echo "Done..."

# Create theme folder on destination server if it doesn't exist
themeFolderExists=`ssh "$server" "[ -d $destination/wp-content/themes/$themeName ] && echo 'true' || echo 'false'"`
if [ "$themeFolderExists" == "false" ]; then
  echo "************************"
  echo "Creating Theme Folder..."
  echo "************************"

  ssh "$server" "mkdir $destination/wp-content/themes/$themeName"
  echo "Done..."
fi

# Unzip theme and plugins zip files and cleanup
echo "*****************************************"
echo "Unzipping Themes and Plugins To Server..."
echo "*****************************************"

ssh "$server" "
  cd $destination/wp-content/themes/ && unzip -qq -o theme.zip -d ./$themeName &&
  cd $destination/wp-content/ && unzip -qq -o plugins.zip -d ./plugins &&
  cd $destination/wp-content/themes/ && rm theme.zip &&
  cd $destination/wp-content/ && rm plugins.zip &&
  exit
"
echo "Done..."