#!/bin/sh
# Color variables.
red=`tput setaf 1`
green=`tput setaf 2`
reset=`tput sgr0`

# Check bootstrap exist.
if [[ -d $PWD/themes/contrib/bootstrap ]]
then
  echo "${green}Base theme (bootstrap) exist!${reset}"
else
  drush dl bootstrap --destination=themes/contrib
  echo "${green}Downloaded bootstrap theme!${reset}"
fi

# Set variables.
echo -n "Subtheme name [ENTER]: "
read THEME_NAME

# Check exiting theme.
if [[ -d $PWD/themes/custom/$THEME_NAME ]]
then
  echo "${red}Theme exist!${reset}"
  exit
fi

echo -n "Subtheme title [ENTER]: "
read THEME_TITLE

PS3="Subtheme type [CHOOSE]: "
options=("sass" "less" "cdn" "exit")
select opt in "${options[@]}"
do
  case $opt in
    "sass")
      THEME_TYPE="sass"
      GUMP_FILE_REMOTE='https://raw.githubusercontent.com/mmd001/install_bootstrap_for_drupal/master/sass/Gulpfile.js'
    break
    ;;
    "less")
      #THEME_TYPE="less"
      echo "${red}Need to improvement.${reset}"
      exit
    break
    ;;
    "cdn")
      #THEME_TYPE="cdn"
      echo "${red}Need to improvement.${reset}"
      exit
    break
    ;;
    "exit")
      exit
    break
    ;;
    *) echo "${red}Invalid value.${reset}";;
  esac
done

THEME_BASE_PATH=$PWD/themes/custom
THEME_PATH=$THEME_BASE_PATH/$THEME_NAME
BS_BASE_PATH=$THEME_PATH/bootstrap

# Set bootstrap data.
if [[ $THEME_TYPE == 'sass' ]]
then
  BS_NPM_PATH=$THEME_PATH/node_modules/bootstrap-sass
  NPM_ITEMS_DEV=( gulp gulp-sass gulp-watch gulp-autoprefixer bootstrap-sass );
elif [[ $THEME_TYPE  == 'less' ]]
then
  BS_NPM_PATH=$THEME_PATH/node_modules/bootstrap
  BS_TYPE=bootstrap
else
  echo 'Soryy'
fi

#1 Copy starterkit.
if [[ -d $PWD/themes/custom ]]
then
  cp -r $PWD/themes/contrib/bootstrap/starterkits/$THEME_TYPE $PWD/themes/custom/$THEME_NAME
else
  mkdir $PWD/themes/custom
  cp -r $PWD/themes/contrib/bootstrap/starterkits/$THEME_TYPE $PWD/themes/custom/$THEME_NAME
fi
echo "${green}#1 Crated sub-theme!${reset}"

#2 Rename Sub-theme root files.
for FILE in `ls -d $THEME_PATH/THEMENAME*`
do
  sed -i "s/THEMETITLE/${THEME_TITLE}/g" $FILE
  sed -i "s/THEMENAME/${THEME_NAME}/g" $FILE
  mv $FILE "${FILE/THEMENAME/$THEME_NAME}"
done

#2.1 Rename *.info.yml
mv $THEME_PATH/$THEME_NAME.starterkit.yml $THEME_PATH/$THEME_NAME.info.yml

#2.2 Rename install files.
for FILE in `ls -d $THEME_PATH/config/install/THEMENAME*`
do
  sed -i "s/THEMETITLE/${THEME_TITLE}/g" $FILE
  sed -i "s/THEMENAME/${THEME_NAME}/g" $FILE
  mv $FILE "${FILE/THEMENAME/$THEME_NAME}"
done

#2.3 Rename schema files.
for FILE in `ls -d $THEME_PATH/config/schema/THEMENAME*`
do
  sed -i "s/THEMETITLE/${THEME_TITLE}/g" $FILE
  sed -i "s/THEMENAME/${THEME_NAME}/g" $FILE
  mv $FILE "${FILE/THEMENAME/$THEME_NAME}"
done
echo "${green}#2 Renamed file and file content.${reset}"

#3 NPM settings.
cd $THEME_PATH && npm init -y
sed -i "s/index.js/Gulpfile.js/g" $THEME_PATH/package.json

for NPM_ITEM in ${NPM_ITEMS_DEV[@]}
do
  echo "${green}Install ${NPM_ITEM} >${reset}"
  cd $THEME_PATH && npm install $NPM_ITEM -D
done
echo "${green}#3 Installed npm components.${reset}"

#5 Move bootstrap framework.
mv $BS_NPM_PATH $BS_BASE_PATH
echo "${green}#4 Moved bootstrap framework in ${THEME_TITLE} root.${reset}"

#6 Download config file.
wget $THEME_PATH $GUMP_FILE_REMOTE
echo "${green}#5 Downloaded gulp configs.${reset}"

#7 Compile project.
cd $THEME_PATH && gulp sass
echo "${green}#6 Build theme success's.${reset}"
