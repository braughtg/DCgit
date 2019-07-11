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

CONFIGURED=false
if ! $CONFIGURED ; then
  echo "DCgit has not been configured for this computer."
  echo "Please run DCgitConfigure.bash before using the DCgit commands."
  exit -1
fi

# These are set by the instructor after the repo for the course is created.
GITHUB_COURSE_ORG="CourseOrg"  # Must match the course org name.
COURSE_ID="CourseRepo"  # Must match the course repo name.

# These will be rewritten by the DCgitConfig script when run by the student.
STUDENT_GITHUB_ID="StudentGitHubID"
STUDENT_EMAIL="student@student.stu"
INSTRUCTOR_GITHUB_ID="InstructorGitHubID"
