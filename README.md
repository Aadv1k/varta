# Varta

WhatsApp isn't built for one-way multi-channel school communications; We Are.

**Target Audience**: we are targeting schools whose primary means of informal (and formal) communications is WhatsApp.

## Features

> NOTE: these are features for the MVP

- **Scoped Announcement**: not all announcements are meant for everyone, hence when creating the announcement multiple scopes can be attached that control precisely who can see the announcement.

- **OTP Login**: users login with OTP instead of having to store/remember a password

- **Announcement Search**: powerful announcement search allows you to look through the academic year, a date, title or the author of the announcement     


Initially there is going to be NO admin dashboard, instead a school is going to be manually configured and setup   

---

> NOTE: NOT IMPLEMENTED

- **Announcement Attachments**
- **Scheduled Announcements** 
- **Custom Scope definition**
- **On-Boarding Experience** 
- **Admin Dashboard with a rudimentary SIS (student information system)**

## Push Notifications


push notifications are expected


## Authentication / Authorization

To login, a user specifies their school, along with `phone_number` an SMS is sent with a 6-digit OTP to **either the email or the phone number**

> this is a measure to reduce/spread the cost of user login. a certain percent of the time email will be sent, else the number will be used. This is done since sending emails is much cheaper than sending OTPs

- When a user first logs in they are assigned an access and refresh token
- the access token stays valid **for a week** and can be renewed through a refresh token which stays valid **for a month**

the user jwt token encodes the following information

- sub (the public id of the user)
- iat 
- exp: expiry of the token default `24h`
- role: refers to the user type (student, teacher, admin)
- iss: `varta.app` (in case of the APP login), `varta.web` (in case of web login)

### Perms

- any user with the role teacher can
    - view all their announcements
    - view all student announcements
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
    - do CRUD on all incoming announcements 

### School

All users must belong to some school, a school has the following basic information

- id
- name: title-case name for the school. ASCII only, may not contain special characters
- `phone_number`
- address: text only adress 128 characters long
- email: must be unique
- website

`POST /v1/admin/school` (this can only be done once)

### Academic Year

All information for a school, is organized in the following way

- a school is initialized, with the current academic year
- students have an admission which defines which academic year thye were in school. 
    - to promote a student they must be explicitly re-admitted to the school
- teachers much also go through a re-assignemnt process for their deparment and class

- all announcements are created under an academic year
- when a user requests an announcement set, they receive the paginated set for that academic particular year

### Announcements

- title: plain unicode text capped at 256 characters 
- body: simple plain unicode text max 4000 characters
- scopes: an announcement may have maximum of 12 scopes
    - `scope_type`: teacher, student, admin
    - `scope_filter`
      - for teachers: `t_class_teacher_of, t_subject_teacher_of_standard, t_subject_teacher_of_standard_division, t_department, t_subject_taught, t_grade_level` 
      - for students: `stu_standard, stu_standard_division, stu_house`
    - `scope_content`


`GET /v1/announcements`

- `page=` get the the Xth page out of N pages
- `per_page=` number of items per page
- `academic_year=` by default the current academic year announcemnets are returned, but you can specify an year in this way `2023-2024`  

```
{
    "status": "success",
    "code": 200,
    "message": "Request processed successfully",
    "data": [...],
    "metadata": {
        page_number: 1,
        page_length: 10,
        page_count: 10,
    },
}
```

To ensure the freshness of the announcements, the client can also request only the new announcements (and perhaps cache the rest) by doing so

`GET /v1/announcements/new-since/:timestamp`

```
{
    "status": "success",
    "code": 200,
    "message": "Request processed successfully",
    "data": [...],
    "metadata": {
        page_number: 1,
        page_length: 1,
        page_count: 1,
        new_since: "time-stamp-formatted"
    },
}
```

This endpoint can be polled


### Search Announcements


`GET /v1/announcements/search`
- `q=` the plain, case-insensetive search query that will look through the title and the body  
- `academic_year=` by default the current academic year is searched but search can be specified for previous ones too
- `author=` the `public_id` of the user who has authopred the announcement 
- `date_from=`, `date_to=` 
    - when these are provided, `academic_year` is ignored
    - if only this is provided, all announcemnts from the date up until now are returned
    - if only this is provided, all announcemnts to the current date are returned
    - both are provided the date range is returned 


Announcements can be searched for with the following criterion

- all announcements from and to, a date. if no end date is provided all announcements up-until from
  to now are shown instead
- announcements can be searched for by the academic year
- announcements can be searched for by title
- announcements can be searched by the author

### User

A user may be of a type teacher, student or admin. a user may have this generic information. 

- `public_id` the public UUID associated with the user
- `first_name`
- `middle_name`
- `last_name`
- `user_type` teacher, student, or admin

#### Contact

all users must have two kinds of "contacts" an email and a number

- Contact importance: can be primary or secondary
- Contact type: either email or phone number 
- Contact data

the primary contacts will be used by default, unless they fail. In which case the secondary contacts will be used to send the OTP or communications   

`GET /v1/me/contacts`

> **TODO** in the future teacher can do CRUD on their contacts, studnets can also do those actions, but on a request queue to be approved by the admin

#### Teacher

> A teacher is assigned to multiple departments (mathematics, social_studies, english) this means they teach multiple subjects
> a teacher needs to be assigned to a class, and it needs to be specificed about the subject taught (TeacherClass: class, subject, teacher, `is_class_teacher`)

#### Student

a student is assigned to a particular class , in a StudentClass relationship, which is OneToMany. So a student-class looks like this

- student (fk)
- class (fk)
- academic-year (fk)

#### Admin

- an admin is analogous to a teacher except it is optional for them to be assigned a class and they
  have special permissions (access to admin dashboard) 

> **TODO** Admin Mechanism for promoting students the next grade and managing them? 

### Class

A class is a reference table with the following structure

- standard
- division

The reference table is pre-defined in accordance with this logic (hence their is no public logic for editing this) 

`for 6..12 do i{A..J}`

## Stories

- An announcement is to be made for the subject teachers of class 12A and 12B
- An announcement is to be made to all physics teachers of 9th standard
- An announcement is to be made for all the class teachers of 6th, to 9th
- An announcement is to be made for students of 12A, 12B
- An announcmenet is to be made for all humanities students of class 12D 

## API Routes

### Base Response

```json
{
    "status": "success",
    "code": 200,
    "message": "Request processed successfully",
    "data": { },
    "metadata": { },
}
```

### Base Error

```json
{
    "status": "error",
    "code": 400,
    "message": "Something went wrong while trying to sign you in",
    "errors": [
        {
            field: "phone_number",
            error: "invalid phone number format"
        }

    ]
}
```
### Resource

### Authentication and Authorization

`GET /v1/me`

- role
- first_name
- middle_name
- last_name

IF STUDENT

- classroom
    - standard
    - division

IF TEACHER / ADMIN

- `is_subject_teacher`
- classroom
    - standard
    - division
- `teaches_classrooms` (teaches in classrooms)
  - standard
  - division
- departments (array)
    - id
    - name

`POST /v1/me/login`

- input_format: email or phone
- input_data

- data
  - `otp_sent_to`: format

`POST /v1/me/verify`

- input_format
- input_data 
- otp

OUTPUT

- data
  - access token
  - refresh token

`GET /v1/me/refresh`

OUTPUT

- data
  - access token


### Create, View, Update, Delete Announcements

- `POST /v1/announcements`
- `GET /v1/announcements`

```
{
    /* ... */

    data: [
        {
            title: "Announcement title",
            body: "Announcement body",
            posted_by: "Jane Doe",
            high_priority: true,
            scope: [
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9A" },
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9B" },
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9C" }
            ]
        }
    ]

    /* ... */
}
```


- `DELETE /v1/announcements`
- `PUT /v1/announcements`

- `GET /v1/announcements/search`
    - `date_to=`
    - `date_from=`
    - `posted_by=`
    - `q=`

```
{
    /* ... */

    data: [
        announcements: {
            title: "Announcement title",
            body: "Announcement body",
            posted_by: "Jane Doe",
            high_priority: true,
            scope: [
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9A" },
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9B" },
                { scope_type: "students", scope_filter_type: "stu_standard_division", scope_filter_content: "9C" }
            ]
        }
    ]
    metadata: {
        results: foo
    }
    /* ... */
}
```

### teachers

> **NOTE**: in the MVP we would add management for the admin as well

- `GET /v1/teachers`
    - only allowed for admin and teachers

```
{
    /* ... */

    data: [
        {
            id: "40bdbd7d-6937-4b8a-95ae-fcf4d35f36ff" // this is the public ID
            first_name: "Jane",
            last_name: "Doe",
            departments: ["science", "english"],
            classes: ["9A", "9B", "9C"],
            is_class_teacher: true,
            class_teacher_of: "9A"
        }
    ], 

    /* ... */
}
```

