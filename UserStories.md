# DCGit User Stories

## For Students

### Beginning a new Course
1. Open terminal
1. git clone _CourseGitHubURL_
  - _CourseGitHubURL_ will be given by the instructor.
1. Change to the created course directory.
1. ./DCGitConfigure

### Starting an Assignment

#### Using the Scripts:
1. Open terminal
1. Change to course directory.
1. ./DCgitBegin _AssignmentID_ [_PartnerID_]
  - Provide _PartnerID_ for paired work, omit for individual work.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration.)
  - Ask again if failure to authenticate with GitHub
1. The script then:
  1. Clones the assignment repository from the Course to the student's GitHub as a private repository.
  1. Invites the instructor to collaborate on the assignment repository.
  1. Invites the partner (if specified) to collaborate on the assignment repository.
  1. Clones the assignment from the student's GitHub to the local machine.
1. The script terminates if:
  - it is not running inside of the course directory.
  - the assignment repository already exists locally in the course directory.
  - _PartnerID_ (if specified) does not exist on GitHub.
  - the Course repository for the assignment doesn't exist
  - the assignment repository already exists in the student GitHub.

#### Manually through GitHub:
1. Copy URL of assignment repository from the Course.
1. Import repository into student GitHub as a __private__ repository.
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

#### Adding Instructor or Partner after Starting an Assignment:
1. Add the instructor or partner as collaborators on the assignment repository.
  1. Open the "Settings" tab (_gear icon_) for the repository
  1. Choose "Collaborators"
  1. Add the instructor and/or partner

#### Removing a Partner from an Assignment:
1. Remove the partner as collaborators on the assignment repository.
  1. Open the "Settings" tab (_gear icon_) for the repository
  1. Choose "Collaborators"
  1. Click the "X" next to partner's ID

### Working on an Assignment

#### Pulling an Assignment from GitHub to Local Machine:
1. Open terminal (if not already open)
1. Change to assignment directory.
1. ../DCgitPull [_PartnerGitHubID_] [_FORCE_REMOTE_ | _MANUAL_MERGE_]
  - Specify _FORCE_REMOTE_ to overwrite local repository with the GitHub version.
  - Specify _MANUAL_MERGE_ to launch a merge tool to resolve conflicts manually.
  - Specify a _PartnerGitHubID_ if your partner was the one to begin the assignment and you would like to pull it to your local machine to work on it there.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
  - Ask again if failure to authenticate with GitHub
1. The script then pulls the content from GitHub and attempts to merge into the local repository.
  - if _FORCE_REMOTE_ is specified, the local repository is forced to mirror the GitHub repository.
  - if _MANUAL_MERGE_ is specified and there are conflicts the configured merge tool is launched.
1. The script terminates if:
  - it is not running inside of an assignment directory.
  - the assignment does not exist in the student's GitHub.
  - there are merge conflicts and neither _FORCE_REMOTE_ nor _MANUAL_MERGE_ are specified.

#### Pushing an Assignment from Local Machine to GitHub:
1. Open terminal
1. Change to assignment directory.
1. ../DCgitPush [_FORCE_LOCAL_]
  - Specify _FORCE_LOCAL_ to overwrite GitHub repository with the version from the local machine.
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
  - Ask again if failure to authenticate with GitHub
1. The script then:
  - Commits all changed files to the local repository
  - Pushes the changes to the remote repository on GitHub.
    - If _FORCE_LOCAL_ is specified, the GitHub repository is forced to mirror the local repository.
1. The script terminates if:
  - it is not running inside of an assignment directory.
  - there are no local changes to commit.
  - there is a problem committing changed files and _FORCE_LOCAL_ is not specified.
  - the assignment repository does not exist on GitHub.
  - the _GitHubUserName_ does not have write permission for the remote assignment repository.
  - there is a problem pushing committed changes and _FORCE_LOCAL_ is not specified.

#### Getting a Copy of Partnered Work in Your GitHub
1. Import repository into your GitHub as a __private__ repository.
  - Choose "Import repository" under the + icon in the upper right.

#### Starting an Assignment Over Again
1. Open terminal
1. Change to course directory.
1. ./DCgitExpunge _AssignmentID_
1. Enter _GitHubUserName_ and _GitHubPassword_ (if not saved during configuration)
  - Ask again if failure to authenticate with GitHub
1. The script then:
  - removes the local repository if it exists.
  - removes the repository from the student's GitHub if it exists and the student is the owner (i.e. not a partner who is a collaborator).
1. The script terminates if:
  - the local repository does not exist.
  - the remote GitHub repository does not exist.
  - the remote GitHub repository is not owned by _GitHubUserName_

## For Faculty

#### Setup
1. Configure git
  - git config --global user.name <GitHubUserName>
  - git config --global user.email <you@email.org>
  - git config --global push.default simple
  - git config --global credential.helper cache
    - Note: credential.helper is not required and will make it so you don't have to repeatedly enter username and password.

#### Creating a new Course
1. Create a organization for the course (a new organization is recommended for each course.)
1. Use the DCGit repo as a template to create new repository for the course in the organization.
1. Clone the Course repository.
1. Edit the README.md file to add Course specific information
1. Edit the .DCgitConfig.bash file to set the values of:
  - GITHUB_COURSE_ORG - point to the owner of the course repository.
  - INSTRUCTOR_GITHUB_ID - id of the instructor for invitations to student repositories.
1. Commit and push the changes.
1. Create assignments.

#### Creating an Assignment
1.  Create a repository in the course organization for the assignment.
  - Use DCgitAssignmentTemplate as a template to get the default licenses pre-configured in the README.md.
1. Clone the assignment repository.
1. Add instructions, files and resources as necessary.
1. Commit and push the changes.

#### Collecting an Assignment
1. Open terminal
1. Change to course directory
1. ./Instructor/DCgitCollect _AssignmentID_ _StudentList_
1. The script then:
  - reads the _StudentList_ file from the Instructor directory.
    - See the _StudentList.sample_ file in the Instructor directory.
  - Clones each of the student repositories into a directory named _AssignmentID_.submissions in the course directory.
1. Mark and comment on the files in the student repositories.
1. The script terminates if:
  - There is not a readable _StudentList_ file in the Instructor directory.

#### Returning an Assignment
1. Open terminal
1. Change to the assignment directory
1. ./Instructor/DCgitReturn _AssignmentID_
1. The script then:
  - Commits and pushes all changes to all repositories in the _AssignmentID_.submissions directory.
1. The script terminates if:
  - There is no _AssignmentID_.submissions directory.

  ___
  ![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License")
  ###### All textual materials used in this course are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc-sa/4.0/)
