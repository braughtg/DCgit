# StudentScripts
Scripts to be used by the students to get and submit assignments.

The files in this repository are:
* __Setup__
  * Generates the configuration file used by these scripts and also configures git to know the user and their password.
    * This script needs to be run once on each machine that the student uses.
  
* __Pull__ _AssignmentName_ _GitHubPartner_ 
  * Retrives content for an assignment from GitHub to the student's local machine.
    * This script should be run at the start of each work session.
  
    * If the student is not in the requested repository on their local machine:
      * Attempt to clone the repository from their GitHub.  If the repository does not exist on their GitHub then attempt to clone it from their partner's GitHub.  If the repository does not exist in the partner's GitHub user first Fork the the repository from the course site to the student's GitHub, establish the partner and the instructor(s) as a collaborator and then clone the repo to the local machine.
    * If the student is in the requested repository on their local machine:
      * Pull the contents of the repository from the origin (either their GitHub or their partner's GitHub).
    
  * _NOTE_: Each assignment can be configured to be indiviudal or partnered. The script will not allow individual assignments to be pulled without 
    
* __Push__ _AssignmentName_ _GitHubUser_
  * Commits all changes in the local repository and pushes to the origin.
    * This script should be run at the end of each work session.

* __Submit__

* __Expunge__




___
![Creative Commons Attribution-NonCommercial 4.0 International License](https://i.creativecommons.org/l/by-nc/4.0/88x31.png "Creative Commons Attribution-NonCommercial 4.0 International License")

All materials used in Dickinson College COMP 130</span> are licensed under a [Creative Commons Attribution-NonCommercial 4.0 International ](http://creativecommons.org/licenses/by-nc/4.0/)
