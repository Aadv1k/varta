<p align="center">
    <img src="./app/assets/images/varta-logo-largest.png", height="76">
    <h1 align="center">Varta</h1>
  </a>
</p>

<center>
<p align="center" style="max-width: 320px;">
    WhatsApp isn't built for one-way multi-channel comunications. We Are.
</p>
</center>

## Introduction

School communications are often highly fragmented, as not every piece of communication is meant for everyone. Due to this, students and even more so teachers end up juggling multiple WhatsApp groups with varying levels of importance and activity, having to sort through information that might be irrelevant to them just to get to the important announcements.

Varta solves this by building scoped announcements on top of a comprehensive user identity system. While creating an announcement, a teacher can specify the exact audience the announcement should be visible to. For example, an announcement meant for all subject teachers of 9th, 10th, and 11th standards will ONLY be visible to those teachers and nobody else.

## Features

- **Scoped Announcements** allows teachers to specify one or multiple audiences to their announcement ensuring it reaches the relevant users. This allows for teacher-to-student as well as teacher-to-teacher communications.
    - [x] Attachments: users can attach documents and media to their announcement
    - [x] Multi-parameter search: the user can search through the relevant announcements based on the date-range, author and keywords within the body or title. 
    - [x] Incremental Updates: the client can call to server to receive live-updates. 
    - [ ] Scheduled Announcements: (Planned) Allow users to schedule announcements for future dates or setup reoccuring announcements.
    - [ ] Priority-Based Filtering: (Planned) Enable users to filter announcements based on priority levels.


<!-- ### Authentication

the user jwt token encodes the following information

- sub (the public id of the user)
- iat 
- exp: expiry of the token default `24h`
- role: refers to the user type (student, teacher, admin)
- iss: `varta.app` (in case of the APP login), `varta.web` (in case of web login)

### Permissions

- teachers
    - view all their announcements
    - create new announcements
- students
    - can only view announcements which are meant for them
- admin
    - can create new teachers
        - assign teacher to a department
        - assign teacher to a class
    - can create new students
        - assign student a class
    - can create new academic years
    - do CRUD on all incoming announcements  -->
