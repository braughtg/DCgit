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

CONFIGURED=true

GITHUB_COURSE_ORG="dickinson-comp130"
INSTRUCTOR_GITHUB_ID="braughtg"

STUDENT_GITHUB_ID="braughtstu"
STUDENT_GITHUB_PASSWORD="1NC7WXUjOB"

if ! $CONFIGURED ; then
  echo "DCgit has not been configured for this computer."
  echo "Please run DCgitSetup.bash"
  exit -1
fi
