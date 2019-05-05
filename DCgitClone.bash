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
  echo "Usage: DCgitClone.bash AssignmentID"
  echo "  AssignmentID : The name of the assignment to clone."
  exit -1
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

# Check if the current directory is the directory for the assignment...
if [[ $(pwd) == *"$ASSIGNMENT_ID" ]] ; then
  echo "You have already cloned "$ASSIGNMENT_ID" to this location."
  echo "Things to check:"
  echo "  Did you mean to use DCgitPull.bash instead?"
  exit -1
fi

# Check if the current directory contains the assignment...
if [[ -d $ASSIGNMENT_ID ]] ; then
  echo "You have already cloned "$ASSIGNMENT_ID" to this location."
  echo "Things to check:"
  echo "  Did you mean to cd "$ASSIGNMENT_ID" and then DCgitPull.bash?"
  exit -1
fi

# Check if the current directory is an assignment...
if [ -f .dcgit.bash ] ; then
  echo "One assignment cannot be cloned within another assignment."
  echo "Things to check:"
  echo "  Are you in the course directory?"
  exit -1
fi

# Check if the requested assignment exists in the student's GitHub...
if ! $(repoExistsOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD) ; then
  echo "The assignment "$ASSIGNMENT_ID" does not appear to have been begun."
  echo "Things to check:"
  echo "  Is the assignment name correct?"
  echo "  If a paired assignment, did you mean to use DCgitPartnerClone.bash?"
  echo "  If not, did you use DCgitBegin.bash before running DCGitClone.bash?"
  exit -1
fi

#
# Everything looks cool so...
#
echo "Cloning the assignment "$ASSIGNMENT_ID" to the local machine."

GIT_URL="https://"$STUDENT_GITHUB_ID":"$STUDENT_GITHUB_PASSWORD"@github.com/"$STUDENT_GITHUB_ID"/"$ASSIGNMENT_ID".git"
GIT_OUT=$(git clone $GIT_URL 2>&1)

echo "Done."
echo "The assignment "$ASSIGNMENT_ID" is now available on your local machine."
echo "  Complete the assignment using the files in the "$ASSIGNMENT_ID" directory."
echo "  Use DCgitPush.bash at the end of each session to copy your work to GitHub."
echo "  Use DCgitPull.bash at the start of each session to retrieve your most recent work."
