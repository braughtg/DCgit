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

FORCE_REMOTE=false
MANUAL_MERGE=false

if [[ "$#" -eq 1 && "$1" == "ForceRemote" ]] ; then
  FORCE_REMOTE=true
elif [[ "$#" -eq 1 && "$1" == "ManualMerge" ]] ; then
  MANUAL_MERGE=true
elif [ "$#" -ne 0 ] ;  then
  echo "Usage: DCgitPull.bash [ ForceRemote | ManualMerge ]"
  echo "  ForceRemote : replaces your local version with the current GitHub version."
  echo "  ManualMerge : launches a merge tool that allows you to combine versions manually."
  exit -1
fi

# Get the name of the current directory and confirm that it is an assignment...
ASSIGNMENT_ID=$(basename $(pwd))
if [ ! -f .dcgit.bash ] ; then
  echo "DCgitPull.bash must be run from within an assignment directory."
  echo "Things to try:"
  echo "  Use cd to change into the assignment directory."
  exit -1
fi

# Load the configuration file and the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/.DCgitConfig.bash
. $SCRIPT_DIR/DCgitLib.bash

# Obtain and validate the student's GitHub password
STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD)

# Make sure that the student has access to the repository on GitHub...
if ! $(repoAccessibleOnGitHub $ASSIGNMENT_ID $STUDENT_GITHUB_ID $STUDENT_GITHUB_PASSWORD) ; then
  echo "You do not have access to "$ASSIGNMENT_ID" on GitHub."
  echo "See your instructor for assistance in resolving this issue."
  exit -1
fi

#
# Everything looks cool so...
#

echo "Pulling the assignment from GitHub to the local machine..."

if $FORCE_REMOTE ; then
  echo "  Request to force remote version..."
  echo "    This will overwrite any changes to your local assignemnt with what exists on GitHub."
  echo "    Work that you have done locally since the last pull will be lost."
  echo -n "    Type ForceRemote to confirm: "
  read CONFIRM
  if [[ $CONFIRM == "ForceRemote" ]] ; then
    echo "  Fetching assignment updates from GitHub..."
    GIT_OUT=$(git fetch 2>&1)
    echo "  Resetting local assignment to match fetched assignment..."
    GIT_OUT=$(git reset --hard origin/master 2>&1)
    GIT_OUT=$(git clean -fdx 2>&1)
  else
    echo "    ForceRemote was not entered, canceling DCgitPull.bash ForceRemote."
    exit -1
  fi
else

  # Add all local changes and commit so that conflicts will be seen by the pull...
  echo "  Staging local changes to the assignemnt..."
  # Add all of the changed files...
  GIT_OUT=$(git add --all 2>&1)
  if [[ $GIT_OUT != "" ]] ; then
    # unstage everyting just to be safe.
    git reset 2>&1 > /dev/null
    echo "    Problem staging the changed assignment."
    echo "    See your instructor for assistance."
    exit -1
  fi

  # Commit the changes to the local repository...
  echo "  Commiting staged changes to the local assignment..."
  COMMIT_MESSAGE=$(whoami)" used DCgitPull.bash "$(date)"."
  GIT_OUT=$(git commit -m "$COMMIT_MESSAGE" 2>&1)

  echo "  Fetching assignment updates from GitHub..."
  GIT_OUT=$(git fetch 2>&1)

  if $MANUAL_MERGE ; then
    echo "  Starting manual merge..."
    GIT_OUT=$(git merge 2>&1)
    CONFLICT_COUNT=$(grep -r "<<<<<<<" . | wc -l)
    if [ "$CONFLICT_COUNT" -gt "0" ] ; then
      while [ "$CONFLICT_COUNT" -gt "0" ] ; do
        echo "    Merge conflicts exist."
        echo "    Launching diff tool, please resolve all conflicts..."
        GIT_OUT=$(git mergetool -y)

        # If any files still have conflict markers ensure we loop back to them...
        CONFLICT_FILES=$(grep -l -r "<<<<<<<" .)
        for FILE in $CONFLICT_FILES ; do
          # Make sure the files are marked as conflicted again...
          GIT_OUT=$(git reset $FILE 2>&1)
          GIT_OUT=$(git checkout --conflict=merge $FILE 2>&1)
        done

        CONFLICT_COUNT=$(grep -l -r "<<<<<<<" . | wc -l)
      done

      # Clean up extraneous backup files that may be created...
      GIT_OUT=$(git clean -f *.orig 2>&1)
      # Finish the commit...
      echo "    Commiting the changes..."
      COMMIT_MESSAGE=$(whoami)" used DCgitPull.bash ManualMerge "$(date)"."
      GIT_OUT=$(git commit -m "$COMMIT_MESSAGE" 2>&1)

      echo "    Confilicts have been merged."
      echo "    Be sure to use DCgitPush.bash when you finish working to push the changes to GitHub."
    else
      echo "    There are no conflicts to be merged."
      GIT_OUT=$(git status 2>&1)
      if [[ $GIT_OUT == *"Your branch is ahead"* ]] ; then
        echo "    However, you have changes to the assignment that are not on GitHub."
        echo "    Be sure to use DCgitPush.bash when you finish working to push your changes to GitHub."
      fi
    fi

  else # Try automatic merge.

    echo "  Testing for conflicts with local edits..."
    GIT_OUT=$(git merge --no-ff --no-commit 2>&1)
    GIT_OUT2=$(git merge --abort 2>&1)

    if [[ $GIT_OUT == *"Automatic merge failed"* ]] ; then
      # Put things back the way we found them...
      git reset --soft HEAD~1 2>&1 > /dev/null  # undo commit
      git reset 2>&1 > /dev/null # undo stage

      echo "    There are conflicts between your local version and the version on GitHub."
      echo "    This can occur when:"
      echo "       Your partner pushed changes to GitHub that you did not pull before editing."
      echo "       You pushed changes from another machine to GitHub that you did not pull before editing."
      echo "       You did not resolve all conflicts during a manual merge."
      echo "    You can:"
      echo "      Push your version to GitHub using DGgitPush.bash ForceLocal"
      echo "      Switch to the version on GitHub using DCgitPull.bash ForceRemote"
      echo "      Try to merge the versions manually using DCgitPull.bash ManualMerge"
      exit -1
    elif [[ $GIT_OUT == *"Already up to date"* ]] ; then
      echo "    Local version already has all changes from GitHub."
      GIT_OUT=$(git status 2>&1)
      if [[ $GIT_OUT == *"Your branch is ahead"* ]] ; then
        echo "    However, you have changes to the assignment that are not on GitHub."
        echo "    Be sure to use DCgitPush.bash when you finish working to push your changes to GitHub."
      fi
    elif [[ $GIT_OUT == *"Automatic merge went well"* ]] ; then
      echo "    Changes on GitHub do not conflict with local edits."
      echo "  Automatically merging non-conflicting changes from GitHub into your local version."
      GIT_OUT=$(git merge 2>&1)
    fi
  fi
fi

echo "Done."
