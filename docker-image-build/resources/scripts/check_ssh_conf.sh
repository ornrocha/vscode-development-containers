#!/bin/sh

GIT_USERNAME="default"
GIT_EMAIL="default"
HOME_USER=/home/devuser
KEYS_PATH=$HOME_USER/.ssh
PRIVATE_KEY=$KEYS_PATH/id_rsa
PUBLIC_KEY=${PRIVATE_KEY}.pub
CURRENT_KEYS_OWNER_FILE=$KEYS_PATH/keys_owner.txt


set_key_permissions()
{
    chmod 700 $KEYS_PATH
    chmod 644 $PUBLIC_KEY
    chmod 600 $PRIVATE_KEY

}

do_remain_setup()
{
  git config --global user.name "$GIT_USERNAME"
  git config --global user.email "$GIT_EMAIL"
  echo 'CURRENT_OWNER='"$GIT_USERNAME"'\nOWNER_EMAIL='"$GIT_EMAIL" > $CURRENT_KEYS_OWNER_FILE
  set_key_permissions
}

config_ssh()
{

  if [ ! -d $KEYS_PATH ];then
	 mkdir -p $KEYS_PATH
  fi


  if [ "$GIT_USERNAME" != "default" ] && [ "$GIT_EMAIL" != "default" ];then
      
      if [ ! -f "$PRIVATE_KEY" ]; then
          echo "No ssh key found, proceeding to ssh key configuration."
          /usr/bin/ssh-keygen -q -t rsa -b 4096 -N '' -f $PRIVATE_KEY -C "$GIT_EMAIL"
          do_remain_setup
      elif [ ! -f "$CURRENT_KEYS_OWNER_FILE" ];then
          echo "No ssh key owner file found, proceeding to ssh key configuration."
          if [ -f "$PRIVATE_KEY" ]; then
              rm $PRIVATE_KEY
              rm $PUBLIC_KEY
          fi
          /usr/bin/ssh-keygen -q -t rsa -b 4096 -N '' -f $PRIVATE_KEY -C "$GIT_EMAIL"
          do_remain_setup
      else
         if [ -f "$CURRENT_KEYS_OWNER_FILE" ];then
           . $CURRENT_KEYS_OWNER_FILE

           if [ "$OWNER_EMAIL" != "$GIT_EMAIL" ];then
              echo "Changes were detected in the email associated with the ssh key, proceeding to ssh key configuration."
              rm $PRIVATE_KEY
              rm $PUBLIC_KEY
              /usr/bin/ssh-keygen -q -t rsa -b 4096 -N '' -f $PRIVATE_KEY -C "$GIT_EMAIL"
              do_remain_setup
           elif [ "$CURRENT_OWNER" != "$GIT_USERNAME" ];then
              echo "Changes were detected in the user name associated with git, proceeding git user.name configuration."
              git config --global user.name "$GIT_USERNAME"
              echo 'CURRENT_OWNER='"$GIT_USERNAME"'\nOWNER_EMAIL='"$GIT_EMAIL" > $CURRENT_KEYS_OWNER_FILE
           else
              echo "No changes were detected in ssh keys."
                echo "========= PUBLIC KEY ============"
  				cat $PUBLIC_KEY
  				echo "======= END PUBLIC KEY ========="
        
           fi

         fi
          
      fi

  elif [ "$GIT_USERNAME" != "default" ] && [ "$GIT_EMAIL" = "default" ] && [ -f "$PRIVATE_KEY" ] && [ -f "$CURRENT_KEYS_OWNER_FILE" ];then
       . $CURRENT_KEYS_OWNER_FILE
       if [ "$CURRENT_OWNER" != "$GIT_USERNAME" ];then
          echo "Changes were detected in the user name associated with git, proceeding git user.name configuration."
          git config --global user.name "$GIT_USERNAME"
          echo 'CURRENT_OWNER='"$GIT_USERNAME"'\nOWNER_EMAIL='"$GIT_EMAIL" > $CURRENT_KEYS_OWNER_FILE
       else
         echo "ssh keys can be configured by running the following cmd: check_ssh_conf -u username -e email"
       fi
  else
     echo "The necessary elements for the creation of the ssh keys were not provided.\nHowever, these can be configured later by running the check_ssh_conf script with the parameters -u username -e email"

  fi

}



help()
{
   echo ""
   echo "Usage: $0 -u user -e email"
   echo -e "\t-u user name"
   echo -e "\t-e user email"
   exit 0 # Exit script after printing help
}

while getopts "u:e:" param
do
   case "$param" in
      u ) GIT_USERNAME="$OPTARG" ;;
      e ) GIT_EMAIL="$OPTARG" ;;
      ? ) help ;; # Print helpFunction in case parameter is non-existent
   esac
done


config_ssh

