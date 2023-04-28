#!/bin/sh

# Use: ./create_user.sh [username] [user UID] [user GID]

set -e

USERNAME=${1:-"devuser"}
USER_UID=${2:-"1000"}
USER_GID=${3:-"1000"}



GROUP_NAME="${USERNAME}"
if id -u ${USERNAME} > /dev/null 2>&1; then

    if [ "$USER_GID" != "$(id -g $USERNAME)" ]; then 
	GROUP_NAME="$(id -gn $USERNAME)"
	groupmod --gid $USER_GID ${GROUP_NAME}
	usermod --gid $USER_GID $USERNAME
    fi
else

    groupadd --gid $USER_GID $USERNAME
    useradd -s /bin/bash --uid $USER_UID --gid $USERNAME -m $USERNAME

fi

# Add add sudo support for non-root user
if [ "${EXISTING_NON_ROOT_USER}" != "${USERNAME}" ]; then
    echo $USERNAME ALL=\(root\) NOPASSWD:ALL > /etc/sudoers.d/$USERNAME
    chmod 0440 /etc/sudoers.d/$USERNAME
    EXISTING_NON_ROOT_USER="${USERNAME}"
fi
