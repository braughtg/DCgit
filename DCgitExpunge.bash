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
  echo "Usage: DCgitExpunge.bash AssignmentID"
  echo "  AssignmentID : The name of the assignment to begin."
  exit -1
fi

# Check that we are within the assignment directory...
if [[ ! $(pwd) == *"$ASSIGNMENT_ID" ]] ; then
  echo "To expunge "$ASSIGNMENT_ID" DCgitExpunge.bash must be run from within the "$ASSIGNMENT_ID" directory."
  exit -1
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/.DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Get confirmation that the assignment is to be expunged...
echo -n "Type the assignment name to confirm expunge: "
read NAME_CHECK
if [ ! $NAME_CHECK == $ASSIGNMENT_ID ] ; then
  echo "The assignment name entered ("$NAME_CHECK") does not match this assignment ("$ASSIGNMENT_ID")."
  echo "Expunge canceled."
  exit -1
fi

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

#
# Everything looks cool so...
#
echo "Expunging the assignment "$ASSIGNMENT_ID

# Delete the repository from the student's GitHub...
echo "  Deleting the assignment from your GitHub..."
SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
if ! $SUCCESS ; then
  echo "    There was a problem removing the "$ASSIGNMENT_ID" repository from your GitHub."
  echo "    Things to try:"
  echo "      Try removing the GitHub repository and deleting the local repository manually."
  exit -1
fi

# Remove the repository from the student's local machine...
echo "  Deleting the assignment from your local machine..."
cd ..
rm -rf $ASSIGNMENT_ID 2>&1 > /dev/null

echo "Done."
echo "Use cd .. to return to the parent directory."
