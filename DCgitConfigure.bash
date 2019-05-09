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

echo "Configuiring DCgit..."
# Load the library functions...
SCRIPT_DIR=$(dirname $0)
. $SCRIPT_DIR/DCgitLib.bash

echo ""
echo -n "GitHub Username: "
read ENTERED_STUDENT_GITHUB_ID
SED_CMD='s/STUDENT_GITHUB_ID=".*"/STUDENT_GITHUB_ID="'$ENTERED_STUDENT_GITHUB_ID'"/g'
sed -i .bak $SED_CMD .DCgitConfig.bash

echo ""
echo -n "E-mail address: "
read ENTERED_STUDENT_EMAIL

echo ""
echo "DCgit can store your GitHub password on your machine."
echo "This makes it so you do not have to type it in repeatedly."
echo "However, it is stored in plain text on your machine."
STORE_PASSWORD="X"
while [[ "$STORE_PASSWORD" != "y" && "$STORE_PASSWORD" != "n" ]] ; do
  echo -n "Would you like DCgit to store your GitHub password [y/n]? "
  read STORE_PASSWORD
done
if [[ $STORE_PASSWORD == "y" ]] ; then
  ENTERED_STUDENT_GITHUB_PASSWORD=$(getGitHubPassword $ENTERED_STUDENT_GITHUB_ID "")
  SED_CMD='s/STUDENT_GITHUB_PASSWORD=".*"/STUDENT_GITHUB_PASSWORD="'$ENTERED_STUDENT_GITHUB_PASSWORD'"/g'
  sed -i .bak $SED_CMD .DCgitConfig.bash
fi

# Do the basic git configuration...
git config --global user.name $ENTERED_STUDENT_GITHUB_ID
git config --global user.email $ENTERED_STUDENT_EMAIL
git config --global credential.helper cache
git config --global push.default simple

# Do the merge tool configuration...
echo ""
echo -n "Configure a merge tool for git [y/n]: "
read CONFIG_MERGE
if $CONFGIG_MERGE ; then
  echo ""
  echo -n "Name of the merge tool (use git mergetool --tool-help to see supported tools): "
  read MERGE_TOOL_NAME
  git config --global merge.tool $MERGE_TOOL_NAME

  echo ""
  echo -n "Execution path to "$MERGE_TOOL_NAME" (can be empty if "$MERGE_TOOL_NAME" is on PATH): "
  read MERGE_TOOL_PATH
  git config --global "mergetool."$MERGE_TOOL_NAME".path" $MERGE_TOOL_PATH
  git config --global "mergetool."$MERGE_TOOL_NAME".trustExitCode" true
  git config --global mergetool.keepBackup false
fi

SED_CMD='s/CONFIGURED=.*/CONFIGURED=true/g'
sed -i .bak $SED_CMD .DCgitConfig.bash

rm .DCgitConfig.bash.bak

echo "Done."