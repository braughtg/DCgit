# Course Title

Information about the specific course goes here.

## Getting Started
The assignments in this course are distributed, collected and returned using DCgit. The basic process for completing the assignments is as follows:

1. Create a GitHub account
* From the command line on your machine:
  1. `git clone [URL copied from Clone or Download Button]`
  * `cd [CourseName]`
  * `./DCgitConfigure.bash`
* Once for each assignment:
  * `./DCgitBegin.bash [AssignmentName]`
* Anytime working on a new machine:
  * If an individual assignment or you are first partner:
    * `./DCgitClone.bash [AssignmentName]`
  * If a paired assignment and you are the second partner:
    * `./DCgitPartnerClone.bash [AssignmentName] [PartnerGitHubID]`
* Each work session:
  1. `cd [CourseName]`
  * `cd [AssignmentName]`
  * `../DCgitPull.bash`
  * Work on the assignment in an editor.
  * `../DCgitPush.bash`

___
![Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](https://i.creativecommons.org/l/by-nc-sa/4.0/88x31.png "Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License")
###### All textual materials used in this course are licensed under a [Creative Commons Attribution-NonCommercial-ShareAlike 4.0 International License](http://creativecommons.org/licenses/by-nc/4.0/)

###### All executable code used in this course is licensed under the [GNU General Public Licence Version 3](https://www.gnu.org/licenses/gpl.txt)
