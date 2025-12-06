# Project: Sheer Love Rwanda

### Sections:
[Interview](Interview.md)

[Prototype](prototype/README.md)

[Project Scope](ProjectScope.md)

We did not incorporate any AI capabilities due to the assumption that our target group is not technologically proficient. To ensure usability, we developed the features to be as easy to digest and understand as possible, hence no AI 'magic'. We utilized Claude code and ChatGPT to iterate on these features.

Features Added:
* Parent Portal
  * Storage for relevant documents and resources related to their student
  * Teachers can upload resources to this portal for parents
  * Insights into their student's grades, performance, attendance, and feedback
* Drawing Assignment
  * Various drawing tools for the canvas
  * Personalized grading and feedback by the teacher
  * Submission gallery where students can view submissions by the entire class
* Private Messaging
* Group Messaging associated with assignments

Future Work - We would like to gamify the platform for students more. Examples of this gamification would be custom avatar creation and the ability to like or comment on submissions in the gallery. Goal of this extension is to further encourage collaboration with 'fun' aspects, as our target group is younger students (~ 6 years old).


#### How To Run:
1. flutter pub get   # install dependencies
2. flutter run

3. Demo Credentials
   * Teacher
     * username - teacher1
     * password - 1234
   * Student1
     * username - S01
     * password - homelga
   * Student2
     * username - S02
     * password - homelga
   * Parent
     * username - user@example.com
     * password - parent123
