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

import json,sys

repo=sys.argv[1]
invitee=sys.argv[2]
inviter=sys.argv[3]

obj=json.load(sys.stdin)

for invite in obj:
  if invite['repository']['name'] == repo and \
     invite['invitee']['login'] == invitee and \
     invite['inviter']['login'] == inviter:

     print(str(invite['id']))
