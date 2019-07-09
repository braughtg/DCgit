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
  # NOTE: This function should always be called as RES=$(getGitHubPassword user)
  # otherwise output will appear twice.
  local GITHUB_ID=$1
  local PASSWORD_SET=false
  local GGITHUB_PASSWORD=""

  # Try to retrieve the password from the git credential helper.
  local GIT_CREDENTIAL_HELPER=$(git config --global credential.helper)
  if [ -n "$(echo -n $GIT_CREDENTIAL_HELPER)" ] ; then
    GITHUB_PASSWORD=$(echo -ne "username="$GITHUB_ID"\n" | git credential-$GIT_CREDENTIAL_HELPER get | grep "^password" | cut -f2 -d'=' | tail -n1)
  fi

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

      # Store the password in the git credential helper.
      if [ -n "$(echo -n $GIT_CREDENTIAL_HELPER)" ] ; then
        echo -ne "username="$GITHUB_ID"\npassword="$GITHUB_PASSWORD"\n" | git credential-$GIT_CREDENTIAL_HELPER store
      fi
    fi
  done

  echo $GITHUB_PASSWORD
}

function readGitHubAPIPagedResult {
  local GITHUB_URL=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3
  local API_PARAMS=$4

  local NEXT_PAGE_URL=$GITHUB_URL"?page=1&per_page=100"

  # Get the number of pages...
  local GITHUB_RESP=$(curl -I -s -S -X GET $NEXT_PAGE_URL -u $GITHUB_ID:$GITHUB_PASSWORD $API_PARAMS)
  local NUM_PAGES=$(echo $GITHUB_RESP | tr ',' '\n' | grep "<https://.*rel=\"last\"" | cut -d'=' -f2 | cut -d'&' -f1)
  # NOTE: NUM_PAGES is empty if only one page.

  # Get each of the pages...
  local PAGES=""
  RANGE=$(seq 1 $NUM_PAGES)  # NOTE: seq gives 1 if NUM_PAGES is empty.
  for i in $RANGE
  do
    # Get the page data...
    local PAGE=$(curl -s -S -X GET $NEXT_PAGE_URL -u $GITHUB_ID:$GITHUB_PASSWORD 2>&1)
    PAGES=$PAGES" "$PAGE

    # Get the next page URL...
    GITHUB_RESP=$(curl -I -s -S -X GET $NEXT_PAGE_URL -u $GITHUB_ID:$GITHUB_PASSWORD)
    NEXT_PAGE_URL=$(echo $GITHUB_RESP | tr ',' '\n' | grep "<https://.*rel=\"next\"" | cut -d'<' -f2 | cut -d'>' -f1)
  done

  echo $PAGES
}


function repoPublicOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2

  local GITHUB_URL="https://api.github.com/users/"$GITHUB_ID"/repos"
  local GITHUB_RESP=$(readGitHubAPIPagedResult $GITHUB_URL | tr '\"' '@')
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]]; then
    echo true
  else
    echo false
  fi
}

function repoAccessibleOnGitHub {
  # Includes all repos public and private that are accessible by GITHUB_ID.
  # This includes those on which GITHUB_ID is a collaborator.
  # NOTE: This does not guarantee push access but a collaborator would have
  #       had to manually disable push access for a partner to make that
  #       not true.  Unlikely, but possible...
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/user/repos"
  local GITHUB_RESP=$(readGitHubAPIPagedResult $GITHUB_URL $GITHUB_ID $GITHUB_PASSWORD | tr '\"' '@')
  if [[ $GITHUB_RESP == *"@name@: @$REPO_ID@"* ]] ; then
    echo true
  else
    echo false
  fi
}

function getAccessibleRepoFullName {
  # NOTE: Will return multiple repo names if more than one repo with the
  #       requested name is accessible to GIT_HUB_ID (e.g. thorugh mulitple
  #       collaborations.)
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/user/repos"
  local GITHUB_RESP=$(readGitHubAPIPagedResult $GITHUB_URL $GITHUB_ID $GITHUB_PASSWORD | tr '\"' '@')

  echo $GITHUB_RESP | tr ',' '\n' | grep "^ @full_name@:.*"$REPO_ID".*@$" | cut -f4 -d'@'
}

function repoOwnedOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local GITHUB_URL="https://api.github.com/repos/"$GITHUB_ID"/"$REPO_ID
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD | tr '\"' "@" 2>&1)

  if [[ $GITHUB_RESP == *"@full_name@: @$GITHUB_ID/$REPO_ID@"* ]] ; then
    echo true
  else
    echo false
  fi
}

function isRepoOwnerOnGitHub {
  local REPO_ID=$1
  local OWNER_GITHUB_ID=$2
  local CHECKER_GITHUB_ID=$3
  local CHECKER_GITHUB_PASSWORD=$4

  local GITHUB_URL="https://api.github.com/repos/"$OWNER_GITHUB_ID"/"$REPO_ID
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u $CHECKER_GITHUB_ID:$CHECKER_GITHUB_PASSWORD | tr '\"' "@" 2>&1)
  if [[ $GITHUB_RESP == *"@full_name@: @$OWNER_GITHUB_ID/$REPO_ID@"* ]] ; then
    echo true
  else
    echo false
  fi
}

function repoWritableOnGitHub {
  local REPO_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  local FULL_REPO_NAME=$(getAccessibleRepoFullName $REPO_ID $GITHUB_ID $GITHUB_PASSWORD)
  local GITHUB_URL="https://api.github.com/repos/"$FULL_REPO_NAME"/collaborators/"$GITHUB_ID"/permission"
  local GITHUB_RESP=$(curl -s -S -X GET $GITHUB_URL -u $GITHUB_ID:$GITHUB_PASSWORD | tr '\"' "@" 2>&1)
  local PERM=$( echo $GITHUB_RESP | tr ',' '\n' | grep "@permission@.*@" | cut -f4 -d'@')

  if [[ $PERM == "admin" || $PERM == "write" ]] ; then
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

function getCollaboratorsOnGitHub {
  local REPO_ID=$1
  local OWNER_GITHUB_ID=$2
  local CHECKER_GITHUB_ID=$3
  local CHECKER_GITHUB_PASSWORD=$4

  local GITHUB_URL="https://api.github.com/repos/"$OWNER_GITHUB_ID"/"$REPO_ID"/collaborators"
  local GITHUB_RESP=$(readGitHubAPIPagedResult $GITHUB_URL $CHECKER_GITHUB_ID $CHECKER_GITHUB_PASSWORD | tr '\"' '@')

  local COLLABORATORS=$(echo $GITHUB_RESP | tr '/"' '@' | tr ',' '\n' | grep "@login@:" | cut -d '@' -f4)
  echo $COLLABORATORS
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

function getCollaborationInvitationsOnGitHub {
  local GITHUB_ID=$1
  local GITHUB_PASSWORD=$2

  local GITHUB_URL="https://api.github.com/user/repository_invitations"
  local GITHUB_RESP=$(readGitHubAPIPagedResult $GITHUB_URL $GITHUB_ID $GITHUB_PASSWORD)

  echo $GITHUB_RESP
}

function acceptCollborationInviteOnGitHub {
  local INVITATION_ID=$1
  local GITHUB_ID=$2
  local GITHUB_PASSWORD=$3

  # Accept the invitation...
  local GITHUB_URL="https://api.github.com/user/repository_invitations/$INVITATION_ID"
  local GITHUB_RESP=$(curl -s -S -X PATCH $GITHUB_URL -u "$GITHUB_ID:$GITHUB_PASSWORD" 2>&1)
  if [[ "$GITHUB_RESP" == "" ]]; then
    echo true
  else
    echo false
  fi
}
