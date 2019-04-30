# StudentScripts
Scripts to be used by the students to manage assignments.

The files in this repository are:
* __DCgitSetup__ _CourseID_
  * Run once for each course on each machine that the student uses to setup the common configuration parameters.
  
  * Parameters: 
    * _CourseID_ : The identifier for the course. 
    
  * Behavior:
    * Creates a directory for the specified course where all repositories for the course will reside.
    * Creates a configuration file for the course within the course directory.
    * Configures git to know the username and password of the student.
    
* __DCgitBegin__ _CourseID_ _AssignmentID_ [ _PartnerGitHubID_ ]
  * Run within the CourseID folder once at the beginning of an assignment to produce an editable version of the assignment that is available to the student, and possibly a partner. 

  * Parameters:
    * _CourseID_ : The identifier for the course. 
    * _AssignmentID_ : The identifier of the repository in the course organization on GitHub.
    * [ _PartnerGitHubID_ ] : The GitHub username of a partner for a partnered assignment.
      * _NOTE_: Each assignment is configured to be indiviudal or partnered in the course repository. For assignments configured to be individual, the script will terminate if a _PartnerGitHubID_ is specified.
      
   * Error Conditions:
     * If the confifguration file for the course does not exist the script terminates with a suggestion to check the _CourseID_ and to be sure that _DCgitSetup_ is run prior to use of the other scripts.
     * If the _PartnerGitHubID_ is specified and does not exist on GitHub then the script terminates with a suggestion to check the _PartnerGitHubID_.
     * If the _PartnerGitHubID_ is specified but the assignment is an individual assignment then the script terminates with an indication that the assignment is not partnered and the _PartnerGitHubID_ should be omitted.
     * If the repository already exists in the student's GitHub, the partner's GitHub and/or on the local machine then the script terminates indicating that the assignment already exists and that _DCgitPull_ may be the intended action. 
     * If the repository does not exist in the course organization the script terminates with a suggestion to check the _CourseID_ and the _AssignmentID_.
     
   * Behavior:
     * The repository is copied from the course organization into the student's GitHub as a private repository.
     * If a _PartnerGitHubID_ is specified, the partner will be established as a collaborator on the private repository.
     * The instructor(s) for the course are added as collaborators on the private repository.
    
* __DCgitPull__ _CourseID_ _AssignmentID_ [ _PartnerGitHubID_ ] [ ForceLocal | ForceRemote | Merge ]
  * Run at the beginning of each work session to pull the editable version of the assignment down from GitHub to the student's local machine.
  
  * Parameters:
    * _CourseID_ : The identifier for the course. 
    * _AssignmentID_ : The identifier of the repository in the course organization on GitHub.
    * [ _PartnerGitHubID_ ] : The GitHub username of the partner for a partnered assignment.
    * [ ForceLocal | ForceRemote | Merge ] : Force merge conflicts to be resolved in favor of the local version, in favor of the version currently on GitHub, or to launch a merge tool that will allow the conflicts to be resoved.
      
  * Error Conditions:
    * If the confifguration file for the course does not exist the script terminates with a suggestion to check the _CourseID_ and to be sure that _DCgitSetup_ is run prior to use of the other scripts.
    * If the _PartnerGitHubID_ is specified and does not exist on GitHub then the script terminates with a suggestion to check the _PartnerGitHubID_.
    * If the _PartnerGitHubID_ is specified but the assignment is an individual assignment then the script terminates with an indication that the assignment is not partnered and the _PartnerGitHubID_ should be omitted.
    * If the repository does not exist in the student's GitHub or in the the partner's GitHub the script fails and suggest that the _AssignmentID_ and _PartnerGitHubID_ are checked and that _DCgitBegin_ may need to be used if this is a new assignment.
  
  * Behavior:
    * If the repository for the assignment does not exist on the local machine:
      * Clone the repository from the student's GitHub.  
      * A log file is created in the local the repository and the date/time/user are written in as the creation message.
      
    * If the repository for the assignment exists on the local machine:
      * Pull the contents of the repository from the origin (either their GitHub or their partner's GitHub).  
        * If there are merge conflicts the script will terminate with a message suggesting the use of one of the _[ ForceLocal | ForceRemote | Merge ]_ flags.
      * The date/time/user, the command used and the results are added to the log file in the local repository.
    
* __DCgitPush__ _CourseID_ _AssignmentID_ [ ForceLocal ]
  * Run at the end of each work session to push the current version of the assignment from the student's local machine up to GitHub.
    
  * Parameters:
    * _CourseID_ : The identifier for the course. 
    * _AssignmentID_ : The identifier of the repository in the course organization on GitHub.
    * [ ForceLocal ] : Forces the assignment on GitHub to look identical to the version on the local machine.
    
  * Error Conditions:
    * If the confifguration file for the course does not exist the script terminates with a suggestion to check the _CourseID_ and to be sure that _DCgitSetup_ is run prior to use of the other scripts.
    * If the repository does not exist locally or on GitHub the script fails and suggest that the _CourseID_ and _AssignmentID_ are checked.
    
  * Behavior:
    * The date/time/user and the command being used are written to the log file in the local repository.
    * All of the changes to the local repository are committed using the date/time and local username as the commit message.
    * The local repository is pushed from the local machine to GitHub. 
      * If there are merge conflicts the script terminates, a message including date/time/user and the command is added to the log file and a suggestion is made that either a _DCgitPull_ be done to resolve the conflict or that the [ ForceLocal ] flag be used.


* __DCgitMirror__ _CourseID_ _AssignmentID_ _PartnerGitHubID_
  * Run to mirror an assignment from one partner to the other.  This is typcially used after an assignment has been returned so that both partners own a copy of it.
  
  * Parameters:
    * _CourseID_ : The identifier for the course. 
    * _AssignmentID_ : The identifier of the repository in the course organization on GitHub.
    * _PartnerGitHubID_ : The GitHub username of the partner for a partnered assignment.
    
  * Behavior:
    * The repository for the assignment is copied from the partner's GitHub to the student's GitHub.  
      * If the repository already exists then confirmation is requested and if given the exiting repository is deleted and the copy made.
      * If the repository or the _PartnerGitHubID_ do not exist on GitHub then the script terminates with a suggestion that the _CourseID_, _AssignmentID_, and _PartnerGitHubID_ be checked.
    
* __DCgitExpunge__ _CourseID_ _AssignmentID_
  * Run to remove an assignment completely from the local machine and the student's GitHub.  This is typically used when something goes horribly wrong and they want to start over from scratch.

  * Parameters:
    * _CourseID_ : The identifier for the course. 
    * _AssignmentID_ : The identifier of the repository in the course organization on GitHub.
    
  * Behavior:
    * If the student is in the indicated repository on the local machine, the repositiory is removed.
      * Otherwise a message including the date/time/user and the command is added to the log file.
    * Regardless of whether the local repository is removed, an attempt is made to remove the repository on the student's GitHub.
      * If the repository cannot be removed a message including the date/time/user and the command is added to the log file and a message indicating that the command must be run by the owner of the repository.

_NOTE_: These scripts have been produced for the specific use cases invovled in our course.  They are not designed to handle every use case. Nor are they designed to prohibit sufficiently motivated and unethical students from working around the basic restrictions that they impose.  The code has been released under a Creative Commons Licence (see below) so please feel free to adapt to your purposes. Pull requests that handle additional use cases or improve the robustness of the scripts in a sufficently general way that does not impact our specific usecases are welcome and will be considered on a case-by-case basis.

___
![Creative Commons Attribution-NonCommercial 4.0 International License](https://i.creativecommons.org/l/by-nc/4.0/88x31.png "Creative Commons Attribution-NonCommercial 4.0 International License")
###### All materials used in Dickinson College COMP 130</span> are licensed under a [Creative Commons Attribution-NonCommercial 4.0 International ](http://creativecommons.org/licenses/by-nc/4.0/)
