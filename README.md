# StudentScripts
Scripts to be used by the students to get and submit assignments.

The files in this repository are:
* __COMP130Setup__
  * Generates the configuration file used by these scripts and also configures git to know the user and their password.
    * This script needs to be run once on each machine that the student uses.
  
* __COMP130Pull__ _AssignmentName_ [_PartnerGitHubID_]
  * Retrives content for an assignment (repository) from GitHub to the student's local machine.
    * This script should be run at the start of each work session.
  
    * Parameters:
      * _AssignmentName_ : The name of the repository in the course organization on GitHub.
      * [_PartnerGitHubID_] : The GitHub username of the partner for a partnered assignment.
      
    * Behavior:
      * If the student is not in the requested repository on their local machine:
        * The script first attempts to clone the repository from the student's GitHub.  If the repository does not exist on the student's GitHub and a partner is specified, the script then attempts to clone the repository from the partner's GitHub.  If the repository does not exist in the partner's GitHub, the script first forks the the repository from the course organization to the student's GitHub, establish the partner (if specified) as a collaborator and the instructor(s) as collaborator(s) and then clones the repo to the local machine.
        * _NOTE_: Each assignment is configured to be indiviudal or partnered in the course repository. For assignments configured to be individual, the script will terminate if a _PartnerGitHubID_ is specified.
      * If the student is in the requested repository on their local machine:
        * Pull the contents of the repository from the origin (either their GitHub or their partner's GitHub).
    
* __COMP130Push__ _AssignmentName_ _GitHubUser_ [ force ]
  * Commits all changes to the local repository and push to the origin.
    * This script should be run at the end of each work session.
    
  * 

* __COMP130Submit__ _AssignmentName_ _GitHubUser_

* __COMP130Expunge__ _AssignmentName_ _GitHubUser_


_NOTE_: These scripts have been produced for the specific use cases invovled in our course.  They are not designed to handle every use case, nor are they designed to prohibit sufficiently motivated and unethical students from working around the basic restrictions that they impose.

___
![Creative Commons Attribution-NonCommercial 4.0 International License](https://i.creativecommons.org/l/by-nc/4.0/88x31.png "Creative Commons Attribution-NonCommercial 4.0 International License")
###### All materials used in Dickinson College COMP 130</span> are licensed under a [Creative Commons Attribution-NonCommercial 4.0 International ](http://creativecommons.org/licenses/by-nc/4.0/)
