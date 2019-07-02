# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <https://www.gnu.org/licenses/>.
#
# Copyright 2019 Grant Braught

function getGitHubPassword {
  # NOTE: This function should always be called as RES=$(getGitHubPassword user pass)
  # otherwise output will appear twice.
  local GITHUB_ID=$1
  local GITHUB_PASSWORD=$2
  local PASSWORD_SET=false

  # Only attempt the inital login if GITHUB_PASSWORD has been set
  # This reduces number of incorrect login attempts and helps avoid rate limiting.
  if [ -n "$GITHUB_PASSWORD" ] ; then
    local GITHUB_URL="https://api.github.com"
    local GITHUB_RESP=$(curl -s -S $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD 2>&1)
    if [[ $GITHUB_RESP == *"Bad credentials"* ]] ;  then
      PASSWORD_SET=false
    else
      PASSWORD_SET=true
    fi
  fi

  while ! $PASSWORD_SET ; do
    # NOTE: Using > /dev/tty prevents prompts from appearing in echoed return value.
    echo -n "Enter GitHub password for "$GITHUB_ID": " > /dev/tty
    read -s GITHUB_PASSWORD
    echo "" > /dev/tty

    local GITHUB_URL="https://api.github.com"
    local GITHUB_RESP=$(curl -s -S $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD 2>&1)
    if [[ $GITHUB_RESP == *"Bad credentials"* ]] ;  then
      PASSWORD_SET=false
      echo "Incorrect password for "$GITHUB_ID" please try again." > /dev/tty
    else
      PASSWORD_SET=true
    fi
  done

  echo $GITHUB_PASSWORD
}

function repoPublicOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2

  local GITHUB_URL="https://api.github.com/users/"$GITHUB_ID"/repos"
  local GITHUB_RESP=$(curl -s -S $GITHUB_URL | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]]; then
    echo true
  else
    echo false
  fi
}

function repoAccessibleOnGitHub {
  # Includes all repos public and private that are accessible by GITHUB_ID.
  # NOTE: This does not guarantee push access but a collaborator would have
  #       had to manually disable push access for a partner to make that
  #       not true.  Unlikely, but possible...
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/user/repos"
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]] ; then
    echo true
  else
    echo false
  fi
}

function repoOwnedOnGitHub {
  # Includes all repos public and private that are owned by GITHUB_ID.
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/user/repos"
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD -G -d affiliation=owner | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]] ; then
    echo true
  else
    echo false
  fi
}

function createNewRepoOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3
  local PRIVATE=$4

  local GITHUB_URL="https://api.github.com/user/repos"
  local GITHUB_RESP=$(curl -g -s -S $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD -d '{"name": "'$ASSIGNMENT_ID'", "private": '$PRIVATE'}' | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]]; then
    echo true
  else
    echo false
  fi
}

function deleteRepoFromGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/repos/"$GITHUB_ID/$REPO_ID
  local GITHUB_RESP=$(curl -s -S $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD -X DELETE 2>&1)
  if [[ $GITHUB_RESP == "" ]]; then
    echo true
  else
    echo false
  fi
}

function checkIfUserExistsOnGitHub {
    local GITHUB_USER_ID=$1

    local GITHUB_URL="https://api.github.com/users/"$GITHUB_USER_ID
    local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL | tr '\"' "@" 2>&1)
    if ! [[ $GITHUB_RESP == *"@Not Found@"* ]]; then
      echo true
    else
      echo false
    fi
}

function checkIfCollaboratorOnRepoOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3
  local COLLABORATOR_ID=$4

  local GITHUB_URL="https://api.github.com/repos/"$GITHUB_ID"/"$REPO_ID"/collaborators/"$COLLABORATOR_ID
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" | tr '\"' "@" 2>&1)
  if ! [[ $GITHUB_RESP == *"@Not Found@"* ]]; then
    echo true
  else
    echo false
  fi
}

function removeCollaboratorFromRepoOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3
  local COLLABORATOR_ID=$4

  local GITHUB_URL="https://api.github.com/repos/"$GITHUB_ID"/"$REPO_ID"/collaborators/"$COLLABORATOR_ID
  local GITHUB_RESP=$(curl -s -S -X DELETE $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" 2>&1)
  if [[ "$GITHUB_RESP" == "" ]]; then
    echo true
  else
    echo false
  fi
}

function addCollaboratorToRepoOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3
  local COLLABORATOR_ID=$4

  local GITHUB_URL="https://api.github.com/repos/"$GITHUB_ID"/"$REPO_ID"/collaborators/"$COLLABORATOR_ID
  local GITHUB_RESP=$(curl -s -S -X PUT $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" -d '' | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@login@: @$COLLABORATOR_ID@"* ]]; then
    echo true
  else
    echo false
  fi
}

function acceptCollborationInviteOnGitHub {
  local REPO_ID=$1
  local COLLABORATOR_ID=$2
  local GITHUB_ID=$3
  local GITHUB_PASSWORD=$4

  # Get the invitation id from GitHub...
  local GITHUB_URL="https://api.github.com/user/repository_invitations"
  local GITHUB_RESP=$(curl -s -S $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" 2>&1)
  INVITATION_ID=$(echo $GITHUB_RESP | python getInvites.py $REPO_ID $GITHUB_ID $COLLABORATOR_ID)
  if [[ "$INVITATION_ID" == "" ]] ; then
    echo false
  else
    # Accept the invitation...
    local GITHUB_URL="https://api.github.com/user/repository_invitations/$INVITATION_ID"
    local GITHUB_RESP=$(curl -s -S -X PATCH $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" 2>&1)
    if [[ "$GITHUB_RESP" == "" ]]; then
      echo true
    else
      echo false
    fi
  fi
}
