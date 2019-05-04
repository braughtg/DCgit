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

if [ "$#" -eq 1 ]; then
  ASSIGNMENT_ID=$1
else
  echo "Usage: DCgitBegin.bash AssignmentID"
  echo "  AssignmentID : The name of the assignment to begin."
  exit -1
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Make sure that the configuration has been done.
checkThatDCgitIsConfigured

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

# If the assignment does not exist in the course organization...
if ! $(publicRepoExistsOnGitHub $ASSIGNMENT_ID $GITHUB_COURSE_ORG) ; then
  echo $ASSIGNMENT_ID" was not found in the course "$GITHUB_COURSE_ORG"."
  echo "Check the assignment name and try again."
  exit -1
fi

# If the assignment already exists that the student's GitHub...
if $(repoExistsOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD) ; then
  echo "It appears that you have already begun "$ASSIGNMENT_ID"."
  echo "Did you mean to cd "$ASSIGNMENT_ID" and then DCgitPull.bash?"
  exit -1
fi

# If the current directory has a directory with the assginment name...
if [[ " $(ls) " == *" $ASSIGNMENT_ID "* ]] ; then
  echo "It appears that you have already begun "$ASSIGNMENT_ID"."
  echo "Did you mean to cd "$ASSIGNMENT_ID" and then DCgitPull.bash?"
  exit -1
fi

#
# Everything looks cool so...
#

# Copy the repo from the course into student GitHub as a private repo
# then clone it to the student's local machine.
echo "Beginning the assignment "$ASSIGNMENT_ID

# Create an empty repository to push to...
echo "  Creating the assignment on your GitHub..."
SUCCESS=$(createNewRepoOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD true)
if ! $SUCCESS ; then
  echo "  There was a problem creating the assignment repository on GitHub"
  exit -1
fi

# Add the instructor as a collaborator on the assignment...
echo "  Adding the instructor as a collaborator on the assignment..."
SUCCESS=$(addCollaboratorToRepoOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD $INSTRUCTOR_GITHUB_ID)
if ! $SUCCESS ; then
  echo "    There was a problem adding the instuctor as a collaborator"
  # Something went wrong so clean up...
  SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
  if ! $SUCCESS ; then
    echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub and try again."
  fi
  exit -1
fi

# Clone the repo from the course org to the local machine
echo "  Getting assignment content from the course GitHub..."
GIT_URL="https://github.com/"$GITHUB_COURSE_ORG"/"$ASSIGNMENT_ID".git"
GIT_OUT=$(git clone --bare $GIT_URL 2>&1)
if [[ GIT_OUT == *"remote: Repository not found."* ]] ; then
  echo "    There was a problem cloning "$ASSIGNMENT_ID" from "$GITHUB_COURSE_ORG"."
  # Something went wrong so clean up...
  rm -rf $ASSIGNMENT_ID.git 2>&1 > /dev/null
  SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
  if ! $SUCCESS ; then
    echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub and try again."
  fi
  exit -1
fi
cd $ASSIGNMENT_ID.git

# Push the repo from the local machine to the student's GitHub
echo "  Pushing the assignment content to your GitHub..."
GIT_URL="https://"$STUDENT_GITHUB_ID":"$STUDENT_GITHUB_PASSWORD"@github.com/"$STUDENT_GITHUB_ID"/"$ASSIGNMENT_ID".git"
GIT_OUT=$(git push --mirror $GIT_URL 2>&1)

# Get rid of the bare repo...
cd ..
rm -rf $ASSIGNMENT_ID.git 2>&1 > /dev/null

# Clone the student's repo from GitHub to the local machine.
echo "  Copying the assignment to your local machine..."
GIT_URL="https://"$STUDENT_GITHUB_ID":"$STUDENT_GITHUB_PASSWORD"@github.com/"$STUDENT_GITHUB_ID"/"$ASSIGNMENT_ID".git"
GIT_OUT=$(git clone $GIT_URL 2>&1)

echo "Done."
echo "Assignment "$ASSIGNMENT_ID" is now available to you."
echo "  Edit the files in the "$ASSIGNMENT_ID" directory to complete the assignment."
echo "  Use DCgitPush.bash at the end of each work session."
echo "  Use DCgitPull.bash at the start of each work session."
echo "  To add a partner, have the partner run DCgitPartnerBegin on their machine."
