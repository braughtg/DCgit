# DCGit User Stories

## For Students

### Beginning a new Course

This must be done once on each machine that you use.

1. Open terminal
1. git clone _CourseGitHubURL_
   - _CourseGitHubURL_ will be given by the instructor.
1. Change to the created course directory.
1. ./DCGitConfigure

### Starting an Assignment

This is only done once per assignment, and only by one partner if the work is paired.

#### Using the Scripts:
1. Open terminal
1. Change to course directory.
1. ./DCgitBegin _AssignmentID_ [ _PartnerID_ ]
   - Provide _PartnerID_ for paired work, omit for individual work.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration.)
   - Ask again if failure to authenticate with GitHub
1. The script then:
   1. Copies the assignment repository from the Course GitHub organization to the student's GitHub as a private repository.
   1. Invites the instructor to collaborate on the assignment repository.
   1. Invites the partner (if specified) to collaborate on the assignment repository.
   1. Clones the assignment from the student's GitHub to the local machine.
1. The script terminates if:
   - it is not running inside of the course directory.
   - the assignment repository already exists locally in the course directory.
   - the Course repository for the assignment doesn't exist
   - the assignment repository already exists in the student GitHub.
   - _PartnerID_ (if specified) does not exist on GitHub.

#### Manually through GitHub:
1. Copy URL of assignment repository from the Course.
1. Import repository into student's GitHub as a __private__ repository.
   - Choose "Import repository" under the + icon in the upper right.
1. Add the instructor and partner (if necessary) as collaborators on the assignment repository.
   1. Open the "Settings" tab (the _gear icon_) for the repository
   1. Choose "Collaborators"
   1. Add the instructor and/or partner
1. Copy URL of student's assignment repository on GitHub.
1. Open terminal on the local machine.
1. Change to course directory.
1. git clone _AssignmentURL_

### Adding and Removing Partners

A partner and the instructor are automatically added as collaborators when the DCgitBegin script is used.  So using it is the easiest way to have them setup.

#### Adding Instructor or Partner after Starting an Assignment:
1. Manually add the instructor or partner as collaborators on the assignment repository in GitHub.
   1. Open the "Settings" tab (_gear icon_) for the repository
   1. Choose "Collaborators"
   1. Add the instructor and/or partner

#### Removing a Partner from an Assignment:
1. Manually remove the partner as a collaborator on the assignment repository in GitHub.
   1. Open the "Settings" tab (_gear icon_) for the repository
   1. Choose "Collaborators"
   1. Click the "X" next to partner's ID

### Working on an Assignment
1. Pull work from GitHub using DCgitPull (see below).
1. Work on the files on the local machine.
1. Push the work to GitHub using DCgitPush (see below).

#### Pulling an Assignment from GitHub to Local Machine:
1. Open terminal (if not already open)
1. Change to the course directory.
1. ./DCgitPull _AssignmentID_ [ _ForceRemote_ | _ManualMerge_ ]
   - _AssignmentID_ indicates the assignment to be pulled from GitHub.
   - Specify _ForceRemote_ to overwrite local repository with the GitHub version.
   - Specify _ManualMerge_ to launch a merge tool to resolve conflicts manually.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
   - Ask again if failure to authenticate with GitHub
1. The script then pulls the content from GitHub and attempts to merge into the local repository.
   - if the assignment doesn't exist in the course on the local machine it is cloned instead of being pulled.
   - if _ForceRemote_ is specified, the local repository is forced to mirror the GitHub repository.
   - if _ManualMerge_ is specified and there are conflicts the configured merge tool is launched.
1. The script terminates if:
   - it is not running in the course directory.
   - the student does not have access to the assignment in the student's (or partner's) GitHub.
   - there are merge conflicts and neither _ForceRemote_ nor _ManualMerge_ are specified.

#### Pushing an Assignment from Local Machine to GitHub:
1. Open terminal
1. Change to course directory.
1. ./DCgitPush _AssignmentID_ [ _ForceLocal_ ]
   - _AssignmentID_ indicates the assignment to be pushed to GitHub.
   - Specify _ForceLocal_ to overwrite GitHub repository with the version from the local machine.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
   - Ask again if failure to authenticate with GitHub
1. The script then:
   1. Commits all changed files to the local repository
   1. Pushes the changes to the remote repository on GitHub.
      - If _ForceLocal_ is specified, the GitHub repository is forced to mirror the local repository.
1. The script terminates if:
   - it is not running inside of the course directory.
   - the _GitHubUserName_ does not have write permission for the remote assignment repository.
   - there are no local changes to commit.
   - there is a problem committing changed files and _ForceLocal_ is not specified.

#### Seeing your Graded and Marked Work on GitHub
1. Graded work returned by the instructor can easily be viewed on GitHub.
1. Go to the assignment repository on GitHub.
1. Click the box labeled "Branch: master"
1. Choose "Graded"
   - This will switch you to the version of your files returned by the instructor.
   - They will have the instructor's comments and grades in them when you view them.
1. Clicking the word "Compare" will highlight the additions/changes made by the instructor.
   - This doesn't work with Jupyter Notebooks, but fine with textual code files.
1. Click the box labeled "Branch: Graded" and choose "master" to return to your version of the files.

#### Getting your Graded and Marked Work locally
1. Open terminal
1. Change to the assignment directory
1. git fetch
1. git checkout Graded
   - All files will now be those returned by the instructor.
1. git checkout master
   - Returns you to your version of the files.

#### Getting a Copy of Completed Partnered Work in Your Own GitHub
1. Ensure that you have used DCgitPull to get a copy of the assignment from your partner.
1. Open terminal
1. Change to the course directory
1. ./DCGitCopy _AssignmentID_ [ Replace ]
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
   - Ask again if failure to authenticate with GitHub
1. The script then:
  - Creates a new bare repo on GitHub.
  - Changes the origin remote in the local repo to point at the GitHub repo.
  - Pushes all branches of the local repo to GitHub.
1. The script terminates if:
  - not run from within the course directory.
  - the assignment doesn't exist locally.
  - the assignment remotes already point to the student's GitHub
  - the assignment exists in the student's GitHub but "Replace" is not indicated.

#### Starting an Assignment Over Again
1. Open terminal
1. Change to course directory.
1. ./DCgitExpunge _AssignmentID_
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
   - Ask again if failure to authenticate with GitHub
1. The script then:
   - confirms the assignment name.
   - removes the local repository if it exists.
   - removes the repository from the student's GitHub if it exists and the student is the owner (i.e. not a partner who is a collaborator).
1. The script terminates if:
   - not run from within the course directory.

## For Faculty

#### Setup
1. Configure git
   - git config --global user.name <GitHubUserName>
   - git config --global user.email <you@email.org>
   - git config --global push.default simple
   - git config --global credential.helper cache
      - Note: Or any other credential.helper if you like.  It is not required but will make it so you don't have to repeatedly enter username and password.

#### Creating a new Course
1. Create a organization for the course (a new organization is recommended for each course.)
1. Use the DCGit repo as a template to create new repository for the course in the organization.
1. Clone the Course repository.
1. Edit the README.md file to add Course specific information
1. Edit the .DCgitConfig.bash file to set the values of:
   - COURSE_ID - the name of the course repository.
   - GITHUB_COURSE_ORG - point to the owner of the course repository.
   - INSTRUCTOR_GITHUB_ID - id of the instructor for invitations to student repositories.
1. Commit and push the changes.
1. Create assignments.

#### Creating an Assignment
1. Create a repository in the course organization for the assignment.
   - Use DCgitAssignmentTemplate as a template to get the default licenses pre-configured in the README.md.
1. Clone the assignment repository.
1. Add instructions, files and resources as necessary.
1. Commit and push the changes.

#### Grading or Marking an Assignment
1. Check the assignments using DCgitCheck (see below)
   - This accepts collaboration invitations and reports on student collaborators.
1. Collect the assignments using DCgitCollect (see below)
1. Make changes to files in the "Graded" branch of each repository.
   - Changes can be committed manually or the DCgitReturn script will commit them all at once.
2. Return the graded assignments using DCgitReturn (see below)

#### Checking/Accepting Collaboration Invitations
1. Open terminal
1. Change to Instructor directory for the course.
1. ./DCgitCheck _AssignmentID_ -L _StudentList_ | -S _StudentID_
   - -L _StudentList_ | -S _StudentID_
      - -L StudentList - provide a list of students. See the _StudentList.sample_ file in the Instructor directory.
      - -S StudentID - provide the GitHub ID of a single student.
1. The script then:
   - Reads the _StudentList_ file, if specified, from the Instructor directory.
   - Get all current invitations to collaborate
   - Accept all invitations to the assignment from students in the list.
   - Report lists of
      - Students and their collaborators.
      - Students not active on the assignment (i.e. not an owner and not a collaborator).
      - Students active more than once on the assignment.
1. The script terminates if:
   - not run from the _CourseID_/Instructor directory.
   - the _StudentList_ file is not readable.

#### Collecting an Assignment
1. Open terminal
1. Change to Instructor directory for the course.
1. ./DCgitCollect _AssignmentID_ -L _StudentList_ | -S _StudentID_ [ _Replace_ ]
   - -L _StudentList_ | -S _StudentID_
      - -L StudentList - provide a list of students. See the _StudentList.sample_ file in the Instructor directory.
      - -S StudentID - provide the GitHub ID of a single student.
   - Replace:
      - Include to replace already collected assignment repositories.
      - Omit to only collect a repository if it has not already been collected.
1. The script then:
   - Reads the _StudentList_ file, if specified, from the Instructor directory.
   - creates an _AssignmentID_.submissions directory within the Instructor directory.
     - if the directory exists it is left in place.
   - for each student in the list:
     - if an _AssignmentID_ repository is __owned__ on GitHub by the student:
         - gets a list of the collaborators on the repository.
         - if _Replace_ is used remove the prior submission.
         - creates a directory for the student and collaborators in the _AssignmentID_.submissions directory.
            - the directory is named using a period delimited concatenation of the student collaborators' GitHub IDs.
         - clone's the repository into the directory
1. Makes a "Graded" branch
1. Checks out the "Graded" branch
1. The script terminates if:
   - not run from the _CourseID_/Instructor directory.
   - the _StudentList_ file is not readable.

#### Returning an Assignment
1. Open terminal
1. Change to the Instructor directory for the course.
1. ./DCgitReturn _AssignmentID_ [ _StudentID_ ]
      -S StudentID - [optional] provide the GitHub ID of a single student to return any repo on which that student is a collaborator.
1. The script then:
   - For each repository (or for those involving the specified student):
      - Commits changes to the "Graded" branch.
      - Pushes the "Graded" branch to GitHub.
1. The script terminates if:
   - not run from the _CourseID_/Instructor directory.
   - the _StudentList_ file is not readable.
   - there is no _AssignmentID_.submissions directory.

  ___
  ![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License")
  ###### All textual materials used in this course are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)
