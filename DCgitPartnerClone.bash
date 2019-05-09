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

if [ "$#" -eq 2 ]; then
  ASSIGNMENT_ID=$1
  PARTNER_GITHUB_ID=$2
else
  echo "Usage: DCgitPartnerClone.bash AssignmentID PartnerGitHubID"
  echo "  AssignmentID : The name of the assignment to clone."
  echo "  PartnerGitHubID : The GitHub ID of the partner that began the assignment with DCgitBegin.bash."
  exit -1
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/.DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

# Obtain and validate the partner's GitHub password
PARTNER_GITHUB_PASSWORD=$(getGitHubPassword $PARTNER_GITHUB_ID "")

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

# Check if the student's GitHub has the requested assignment...
if $(repoOwnedOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD) ; then
  echo "You already have the assignment "$ASSIGNMENT_ID" in your GitHub."
  echo "Things to check:"
  echo "  Did you mean to use DCgitPull.bash?"
  echo "  Did you begin the assignemnt and your partner should run DCGitPartnerClone.bash?"
  echo "  Did you both use DCgitBegin? If so one of you should use DCgitExpunge.bash and then use DCgitPartnerClone.bash?"
  exit -1
fi

# Check if the partner's GitHub has the requested assignment...
if ! $(repoOwnedOnGitHub $ASSIGNMENT_ID $PARTNER_GITHUB_ID $PARTNER_GITHUB_PASSWORD) ; then
  echo "The partner "$PARTNER_GITHUB_ID" does not have the assignment "$ASSIGNMENT_ID"."
  echo "Things to check:"
  echo "  Is the partner's GitHub ID correct?"
  echo "  Has your partner begun the assignment using DCGitBegin.bash?"
  echo "  If you used DCgitBegin.bash, then your partner should use DCgitPartnerClone.bash."
  exit -1
fi

#
# Everything looks cool so...
#
echo "Partner cloning the assignment "$ASSIGNMENT_ID" to the local machine."

# Create an empty repository to push to...
echo "  Creating the assignment on your GitHub..."
SUCCESS=$(createNewRepoOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD true)
if ! $SUCCESS ; then
  echo "  There was a problem creating the assignment repository on GitHub."
  echo "  Try again and if the problem persists check with your instructor for assistance."
  exit -1
fi

# Add the instructor as a collaborator on the assignment...
echo "  Adding the instructor as a collaborator on the assignment..."
SUCCESS=$(addCollaboratorToRepoOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD $INSTRUCTOR_GITHUB_ID)
if ! $SUCCESS ; then
  echo "    There was a problem adding the instuctor as a collaborator."
  echo "    Try again and if the problem persists check with your instructor for assistance."
  # Something went wrong so clean up...
  SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
  if ! $SUCCESS ; then
    echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub and try again."
    echo "    Then try again. If the problem persists check with your instructor for assistance."
  fi
  exit -1
fi

# If already a collaborator (possilbe with earlier mess ups)...
echo "  Checking if you are a collaborator..."
SUCCESS=$(checkIfCollaboratorOnRepoOnGitHub $ASSIGNMENT_ID $PARTNER_GITHUB_ID $PARTNER_GITHUB_PASSWORD $STUDENT_GITHUB_ID)
if $SUCCESS ; then
  echo "    Removing you as a collaborator..."
  SUCCESSS=$(removeCollaboratorFromRepoOnGitHub $ASSIGNMENT_ID $PARTNER_GITHUB_ID $PARTNER_GITHUB_PASSWORD $STUDENT_GITHUB_ID)
  if ! $SUCCESS ; then
    echo "    Failed to remove you as a collaborator."
    echo "    Try again and if the problem persists check with your instructor for assistance."
    # Something went wrong so clean up...
    SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
    if ! $SUCCESS ; then
      echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub and try again."
      echo "    Then try again. If the problem persists check with your instructor for assistance."
    fi
    exit -1
  fi
fi

# Add the student as a collaborator on the partner's assignment...
echo "  Generating inviation to collaborate on your partner's assignment..."
SUCCESS=$(addCollaboratorToRepoOnGitHub $ASSIGNMENT_ID $PARTNER_GITHUB_ID $PARTNER_GITHUB_PASSWORD $STUDENT_GITHUB_ID)
if ! $SUCCESS ; then
  echo "    There was a problem adding you as a collaborator to your partner's assignment."
  echo "    Try again and if the problem persists check with your instructor for assistance."
  # Something went wrong so clean up...
  SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
  if ! $SUCCESS ; then
    echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub."
    echo "    Then try again. If the problem persists check with your instructor for assistance."
  fi
  exit -1
fi

# Accept the invitation from the partner to collaborate...
echo "  Accepting your partner's invitation to collaborate..."
SUCCESS=$(acceptCollborationInviteOnGitHub $ASSIGNMENT_ID $PARTNER_GITHUB_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
if ! $SUCCESS ; then
  echo "    Unable to accept the invitation from "$PARTNER_GITHUB_ID" for the assignment "$ASSIGNMENT_ID"."
  echo "    Try again and if the problem persists check with your instructor for assistance."
  # Something went wrong so clean up...
  SUCCESS=$(deleteRepoFromGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)
  if ! $SUCCESS ; then
    echo "    Try manually removing the "$ASSIGNMENT_ID" repository from your GitHub."
    echo "    Then try again. If the problem persists check with your instructor for assistance."
  fi
  exit -1
fi

# Clone the partner's repository to the local machine...
echo "  Cloning the partner's assignment "$ASSIGNMENT_ID" to the local machine..."
GIT_URL="https://"$STUDENT_GITHUB_ID":"$STUDENT_GITHUB_PASSWORD"@github.com/"$PARTNER_GITHUB_ID"/"$ASSIGNMENT_ID".git"
GIT_OUT=$(git clone $GIT_URL 2>&1)

echo "Done."
echo "The assignment "$ASSIGNMENT_ID" is now available on your local machine."
echo "  Complete the assignment using the files in the "$ASSIGNMENT_ID" directory."
echo "  Use DCgitPush.bash at the end of each session to copy your work to GitHub."
echo "  Use DCgitPull.bash at the start of each session to retrieve your most recent work."
