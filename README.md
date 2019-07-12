# DCgit

DCgit is a set of scripts for managing assignments as GitHub repositories in an introductory programming course.

## Technical Dependencies
- Required:
   - basic Unix tools: bash, grep, sed, tr, cut, head, wc, etc..
  - curl
  - python3
- Optional:
  - visual merge tool (e.g. meld)

## Basic Student Use:
1. Create a GitHub account
1. __Once on each machine__ you use:
   1. Open a terminal
   1. `git clone CourseURL`
   1. `cd CourseName`
   1. `chmod 755 DCgit*`
   1. `./DCgitConfigure`
1. __Once by one partner__ for each assignment:
   1. Open a terminal
   1. `cd CourseName`
   1. `./DCgitBegin AssignmentID [PartnerID]`
1. During each work session:
   1. Open a terminal
   1. `cd CourseName`
   1. `./DCgitPull AssignmentID`
   1. Work on the assignment.
   1. `./DCgitPush AssignmentID`
1. To see instructor comments:
   1. Log into GitHub
   1. Open the assignment repository
   1. Click the "Branch: master" button
   1. Choose "Graded" to see files with instructor comments and grades.
   1. Choose "master" to return to ungraded files.
   1. To get live files you can work with:
      1. Open a terminal
      1. `cd CourseName`
      1. `./DCgitPull AssignmentID`
      1. `git checkout Graded` to access files with instructor comments and grades.
      1. `git checkout master` to return to ungraded files.
1. To copy from partner when assignment is complete:
   1. Open a terminal
   1. `cd CourseName`
   1. `./DCgitCopy AssignmentID`

## Basic Instructor Use:
1. Create an organization for your course.
1. Use the "Use this template" button in the DCgit repository on GitHub to create a repository for your course in your organization.
1. Through the GitHub interface, edit the .DCGitConfig.bash file and update:
   - `GITHUB_COURSE_ORG`
   - `COURSE_ID`
1. Clone the repository to your machine.
1. `cd CourseName/Instructor`
1. `chmod 755 DCgit*`
1. If you want to use GitHub Pages for the course website:
   1. Edit \_config.yml
   1. Edit index.md
      - Be sure to adjust licensing on the web pages, if other than the CC-A-NC-SA 4.0 and GPL3.
   1. Add additional files as necessary
   1. Open settings for the repository
      1. Choose "master branch /docs folder" as the GitHub pages source.
      1. Choose a theme for your site.
   1. Website URL will be: _CourseOrg_.github.io/_CourseRepoName_
1. Commit and push changes
1. Edit the .DCgitConfig.bash file and set:
   - `CONFIGURED=true`
   - `INSTRUCTOR_GITHUB_ID`
1. Create a student list file in the Instructor directory (see StudentList.sample).
   - Best not to commit and push this file.
1. Create a repository within the course organization for each assignment.
1. Grading:
   1. Use DCgitCheck to accept invitations to student repositories.
   1. Use DCgitCollect to pull student repositories to your machine.
   1. Edit the files in the "Graded" branch of the student repositories.
      - The "Graded" branch is created and checked out by DCgitCollect.
   1. Use DCgitReturn to push the "Graded" branch to the students.

___
![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License") All textual materials used in this course are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)

![GPL V3 or Later](https://www.gnu.org/graphics/gplv3-or-later-sm.png "GPL V3 or later") All executable code used in this course is licensed under the [GNU General Public License Version 3 or later](https://www.gnu.org/licenses/gpl.txt)
