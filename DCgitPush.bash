#!/bin/bash
#
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

FORCE_LOCAL=false
if [[ "$#" -eq 1 && "$1" == true ]] ; then
  FORCE_LOCAL=true
elif [ "$#" -gt 1 ] ;  then
  echo "Usage: DCgitPush.bash [ForceLocal]"
  echo "  ForceLocal : [optional] true to resolved conflicts and make the GitHub"
  echo "               version look like the local version."
  echo "               To make the local version look like the GitHub version or to"
  echo "               combine version use DCgitPull.bash with ForceRemote or ForceMerge."
  exit -1
fi

# Get the name of the current directory and confirm that it is an assignment...
ASSIGNMENT_ID=$(basename $(pwd))
if [ ! -f .dcgit.bash ] ; then
  echo "DCgitPush.bash must be run from within an assignment directory."
  echo "Use cd to change into an assignment directory and try again."
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Make sure that the configuration has been done.
checkThatDCgitIsConfigured

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

# Make sure that the target repository exits in the student's GitHub...
if ! $(repoExistsOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD) ; then
  echo "Assignment "$ASSIGNMENT_ID" does not exist on your GitHub."
  echo "See your instructor for assistance in resolving this issue."
  exit -1

  # Could just create the empty remote repository and just push to it...
  # But this gives a chance to discuss it with the students...
  # And to get insight into how they got the assignment without DGgitBegin...
fi

#
# Everything looks cool so...
#

echo "Pushing "$ASSIGNMENT_ID" to git hub..."

GIT_FORCE_PARAM=""
if $FORCE_LOCAL ; then
  echo "  Request to force local version..."
  echo "    This will overwrite any changes to the assignemnt already on GitHub with your local version."
  echo "    Work done on another machine or by a partner may be lost."
  echo -n "    Type ForceLocal to confirm: "
  read CONFIRM
  if [ $CONFIRM == "ForceLocal" ] ; then
    GIT_FORCE_PARAM="--force"
  else
    echo "  ForceLocal was not entered, canceling DCgitPush.bash ForceLocal."
    exit -1
  fi
fi

echo " Committing local changes..."
COMMIT_MESSAGE=$(whoami)" used DCgitPush.bash "$GIT_FORCE_PARAM" "$(date)"."
GIT_OUT=$(git commit -m $COMMIT_MESSAGE 2>&1)

if [[ GIT_OUT == *"nothing to commit"* ]] ; then
  echo "    No changes to be commited or pushed."
  exit -1
  
fi


echo " Pushing changes to GitHub..."
GIT_URL="https://"$STUDENT_GITHUB_ID":"$STUDENT_GITHUB_PASSWORD"@github.com/"$STUDENT_GITHUB_ID"/"$ASSIGNMENT_ID".git"


echo "Done."
