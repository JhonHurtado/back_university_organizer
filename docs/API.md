# API Documentation - University Organizer Backend

Complete API reference with request/response examples for all endpoints.

**Base URL:** `http://localhost:3000/api`

**Authentication:** Most endpoints require a Bearer token in the `Authorization` header:
```
Authorization: Bearer <your_access_token>
```

---

## Table of Contents

1. [Authentication](#authentication)
2. [Users](#users)
3. [API Clients](#api-clients)
4. [Careers](#careers)
5. [Academic (Semesters, Subjects, Periods, Enrollments)](#academic)
6. [Grades](#grades)
7. [Schedules](#schedules)
8. [Notifications](#notifications)
9. [Subscriptions & Plans](#subscriptions--plans)
10. [Payments & Invoices](#payments--invoices)
11. [Preferences](#preferences)
12. [Professors](#professors)
13. [Menus](#menus)
14. [Activity Logs](#activity-logs)
15. [Verification](#verification)
16. [Analytics](#analytics)

---

## Authentication

### Register User
**POST** `/auth/register`

**Authentication:** None (Public)

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123",
  "firstName": "John",
  "lastName": "Doe",
  "phone": "+1234567890",
  "timezone": "America/New_York",
  "language": "es"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Usuario registrado exitosamente",
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe",
      "emailVerified": false
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

### Login
**POST** `/auth/login`

**Authentication:** None (Public)

**Request:**
```json
{
  "email": "user@example.com",
  "password": "SecurePass123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login exitoso",
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "user@example.com",
      "firstName": "John",
      "lastName": "Doe"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

### Refresh Token
**POST** `/auth/refresh`

**Authentication:** None (Public)

**Request:**
```json
{
  "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Token renovado exitosamente",
  "data": {
    "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
    "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
  }
}
```

### Get Current User
**GET** `/auth/me`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg",
    "emailVerified": true,
    "timezone": "America/New_York",
    "language": "es",
    "createdAt": "2024-01-15T10:30:00Z"
  }
}
```

### Logout
**POST** `/auth/logout`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Sesión cerrada exitosamente"
}
```

### Logout All Sessions
**POST** `/auth/logout-all`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Todas las sesiones cerradas exitosamente"
}
```

### Google OAuth (One-Tap)
**POST** `/auth/google`

**Authentication:** None (Public)

**Request:**
```json
{
  "credential": "eyJhbGciOiJSUzI1NiIsImtpZCI6IjU5MmU0Y..."
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Login con Google exitoso",
  "data": {
    "user": {
      "id": "123e4567-e89b-12d3-a456-426614174000",
      "email": "user@gmail.com",
      "firstName": "John",
      "lastName": "Doe"
    },
    "tokens": {
      "accessToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
      "refreshToken": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9..."
    }
  }
}
```

---

## Users

### Create User (Admin)
**POST** `/users`

**Authentication:** Required

**Request:**
```json
{
  "email": "newuser@example.com",
  "password": "SecurePass123",
  "firstName": "Jane",
  "lastName": "Smith",
  "phone": "+1234567890",
  "timezone": "America/Los_Angeles",
  "language": "en"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Usuario creado exitosamente",
  "data": {
    "id": "223e4567-e89b-12d3-a456-426614174001",
    "email": "newuser@example.com",
    "firstName": "Jane",
    "lastName": "Smith"
  }
}
```

### Get All Users
**GET** `/users?page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `page` (optional): Page number (default: 1)
- `limit` (optional): Items per page (default: 10, max: 100)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "email": "user@example.com",
        "firstName": "John",
        "lastName": "Doe",
        "createdAt": "2024-01-15T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 50,
      "page": 1,
      "limit": 10,
      "totalPages": 5
    }
  }
}
```

### Search Users
**GET** `/users/search?query=john&page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `query` (required): Search term
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "users": [
      {
        "id": "123e4567-e89b-12d3-a456-426614174000",
        "email": "john@example.com",
        "firstName": "John",
        "lastName": "Doe"
      }
    ],
    "count": 1
  }
}
```

### Get User by ID
**GET** `/users/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "firstName": "John",
    "lastName": "Doe",
    "phone": "+1234567890",
    "avatar": "https://example.com/avatar.jpg",
    "emailVerified": true,
    "timezone": "America/New_York",
    "language": "es",
    "createdAt": "2024-01-15T10:30:00Z",
    "updatedAt": "2024-01-20T15:45:00Z"
  }
}
```

### Get User Statistics
**GET** `/users/:id/stats`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalCareers": 2,
    "totalSubjects": 45,
    "totalEnrollments": 30,
    "completedSubjects": 20,
    "averageGPA": 3.8
  }
}
```

### Update User
**PUT** `/users/:id`

**Authentication:** Required

**Request:**
```json
{
  "firstName": "John Updated",
  "lastName": "Doe Updated",
  "phone": "+9876543210",
  "avatar": "https://example.com/new-avatar.jpg",
  "timezone": "America/Chicago",
  "language": "en"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario actualizado exitosamente",
  "data": {
    "id": "123e4567-e89b-12d3-a456-426614174000",
    "email": "user@example.com",
    "firstName": "John Updated",
    "lastName": "Doe Updated"
  }
}
```

### Update Password
**PUT** `/users/:id/password`

**Authentication:** Required

**Request:**
```json
{
  "password": "NewSecurePass456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente"
}
```

### Soft Delete User
**DELETE** `/users/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario eliminado exitosamente"
}
```

### Activate User
**POST** `/users/:id/activate`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario activado exitosamente"
}
```

### Deactivate User
**POST** `/users/:id/deactivate`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario desactivado exitosamente"
}
```

### Restore User
**POST** `/users/:id/restore`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Usuario restaurado exitosamente"
}
```

---

## API Clients

### Create API Client
**POST** `/clients`

**Authentication:** None (for initial setup)

**Request:**
```json
{
  "name": "Mobile App",
  "description": "Official mobile application",
  "allowedOrigins": ["https://app.example.com", "http://localhost:3000"]
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Cliente creado exitosamente",
  "data": {
    "id": "client-123",
    "name": "Mobile App",
    "clientId": "cli_1234567890abcdef",
    "clientSecret": "sec_abcdef1234567890fedcba",
    "isActive": true
  }
}
```

### Get All API Clients
**GET** `/clients`

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "client-123",
      "name": "Mobile App",
      "clientId": "cli_1234567890abcdef",
      "isActive": true,
      "createdAt": "2024-01-15T10:30:00Z"
    }
  ]
}
```

### Get API Client by ID
**GET** `/clients/:id`

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "client-123",
    "name": "Mobile App",
    "clientId": "cli_1234567890abcdef",
    "description": "Official mobile application",
    "allowedOrigins": ["https://app.example.com"],
    "isActive": true
  }
}
```

### Update API Client
**PATCH** `/clients/:id`

**Request:**
```json
{
  "name": "Mobile App Updated",
  "description": "Updated description",
  "allowedOrigins": ["https://app.example.com", "https://new.example.com"]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Cliente actualizado exitosamente"
}
```

### Regenerate Client Secret
**POST** `/clients/:id/regenerate-secret`

**Response (200):**
```json
{
  "success": true,
  "message": "Secret regenerado exitosamente",
  "data": {
    "clientSecret": "sec_newabcdef1234567890"
  }
}
```

### Activate API Client
**POST** `/clients/:id/activate`

**Response (200):**
```json
{
  "success": true,
  "message": "Cliente activado exitosamente"
}
```

### Deactivate API Client
**POST** `/clients/:id/deactivate`

**Response (200):**
```json
{
  "success": true,
  "message": "Cliente desactivado exitosamente"
}
```

---

## Careers

### Create Career
**POST** `/careers`

**Authentication:** Required

**Request:**
```json
{
  "name": "Computer Science",
  "code": "CS-2024",
  "university": "MIT",
  "faculty": "Engineering",
  "campus": "Main Campus",
  "totalCredits": 180,
  "totalSemesters": 10,
  "currentSemester": 1,
  "gradeScale": "FIVE",
  "minPassingGrade": 3.0,
  "maxGrade": 5.0,
  "startDate": "2024-01-15T00:00:00Z",
  "expectedEndDate": "2029-06-30T00:00:00Z",
  "color": "#3B82F6",
  "status": "ACTIVE"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Carrera creada exitosamente",
  "data": {
    "id": "career-123",
    "name": "Computer Science",
    "code": "CS-2024",
    "university": "MIT",
    "totalCredits": 180,
    "totalSemesters": 10,
    "currentSemester": 1,
    "gradeScale": "FIVE",
    "status": "ACTIVE"
  }
}
```

### Get All Careers
**GET** `/careers?status=ACTIVE&page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `status` (optional): Filter by status (ACTIVE, COMPLETED, PAUSED, CANCELLED, GRADUATED)
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "careers": [
      {
        "id": "career-123",
        "name": "Computer Science",
        "university": "MIT",
        "status": "ACTIVE",
        "currentSemester": 1,
        "totalSemesters": 10
      }
    ],
    "pagination": {
      "total": 2,
      "page": 1,
      "limit": 10,
      "totalPages": 1
    }
  }
}
```

### Get Career by ID
**GET** `/careers/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "career-123",
    "name": "Computer Science",
    "code": "CS-2024",
    "university": "MIT",
    "faculty": "Engineering",
    "campus": "Main Campus",
    "totalCredits": 180,
    "totalSemesters": 10,
    "currentSemester": 1,
    "gradeScale": "FIVE",
    "minPassingGrade": 3.0,
    "maxGrade": 5.0,
    "startDate": "2024-01-15T00:00:00Z",
    "expectedEndDate": "2029-06-30T00:00:00Z",
    "color": "#3B82F6",
    "status": "ACTIVE",
    "createdAt": "2024-01-15T10:30:00Z",
    "semesters": [],
    "subjects": []
  }
}
```

### Get Career Statistics
**GET** `/careers/:id/stats`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalSubjects": 45,
    "completedSubjects": 20,
    "inProgressSubjects": 5,
    "failedSubjects": 2,
    "totalCredits": 180,
    "earnedCredits": 80,
    "averageGPA": 3.8,
    "completionPercentage": 44.4
  }
}
```

### Update Career
**PUT** `/careers/:id`

**Authentication:** Required

**Request:**
```json
{
  "name": "Computer Science - Updated",
  "currentSemester": 2,
  "status": "ACTIVE",
  "color": "#FF6B6B"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Carrera actualizada exitosamente",
  "data": {
    "id": "career-123",
    "name": "Computer Science - Updated",
    "currentSemester": 2
  }
}
```

### Update Current Semester
**PUT** `/careers/:id/semester`

**Authentication:** Required

**Request:**
```json
{
  "currentSemester": 3
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Semestre actualizado exitosamente",
  "data": {
    "currentSemester": 3
  }
}
```

### Soft Delete Career
**DELETE** `/careers/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Carrera eliminada exitosamente"
}
```

### Restore Career
**POST** `/careers/:id/restore`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Carrera restaurada exitosamente"
}
```

---

## Academic

### Semesters

#### Create Semester
**POST** `/academic/semesters`

**Authentication:** Required

**Request:**
```json
{
  "careerId": "career-123",
  "number": 1,
  "name": "First Semester",
  "description": "Introduction to Computer Science"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Semestre creado exitosamente",
  "data": {
    "id": "semester-123",
    "careerId": "career-123",
    "number": 1,
    "name": "First Semester"
  }
}
```

#### Get Semesters by Career
**GET** `/academic/careers/:careerId/semesters`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "semester-123",
      "number": 1,
      "name": "First Semester",
      "description": "Introduction to Computer Science",
      "subjects": []
    }
  ]
}
```

#### Get Semester by ID
**GET** `/academic/semesters/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "semester-123",
    "careerId": "career-123",
    "number": 1,
    "name": "First Semester",
    "description": "Introduction to Computer Science",
    "subjects": []
  }
}
```

#### Update Semester
**PUT** `/academic/semesters/:id`

**Authentication:** Required

**Request:**
```json
{
  "name": "First Semester - Updated",
  "description": "Updated description"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Semestre actualizado exitosamente"
}
```

#### Delete Semester
**DELETE** `/academic/semesters/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Semestre eliminado exitosamente"
}
```

### Subjects

#### Create Subject
**POST** `/academic/subjects`

**Authentication:** Required

**Request:**
```json
{
  "careerId": "career-123",
  "semesterId": "semester-123",
  "code": "CS101",
  "name": "Introduction to Programming",
  "description": "Basic programming concepts",
  "credits": 4,
  "hoursPerWeek": 6,
  "subjectType": "REQUIRED",
  "area": "Computer Science",
  "totalCuts": 3,
  "isElective": false,
  "gradeWeights": {
    "exams": 0.6,
    "homework": 0.3,
    "participation": 0.1
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Materia creada exitosamente",
  "data": {
    "id": "subject-123",
    "code": "CS101",
    "name": "Introduction to Programming",
    "credits": 4,
    "subjectType": "REQUIRED"
  }
}
```

#### Get Subjects by Career
**GET** `/academic/careers/:careerId/subjects?semesterId=semester-123&subjectType=REQUIRED`

**Authentication:** Required

**Query Parameters:**
- `semesterId` (optional): Filter by semester
- `subjectType` (optional): Filter by type (REQUIRED, ELECTIVE, FREE_ELECTIVE, COMPLEMENTARY)
- `isElective` (optional): Filter electives (true/false)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "subject-123",
      "code": "CS101",
      "name": "Introduction to Programming",
      "credits": 4,
      "subjectType": "REQUIRED",
      "semester": {
        "id": "semester-123",
        "number": 1,
        "name": "First Semester"
      }
    }
  ]
}
```

#### Get Subject by ID
**GET** `/academic/subjects/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "subject-123",
    "code": "CS101",
    "name": "Introduction to Programming",
    "description": "Basic programming concepts",
    "credits": 4,
    "hoursPerWeek": 6,
    "subjectType": "REQUIRED",
    "area": "Computer Science",
    "totalCuts": 3,
    "gradeWeights": {
      "exams": 0.6,
      "homework": 0.3,
      "participation": 0.1
    },
    "prerequisites": [],
    "semester": {
      "id": "semester-123",
      "number": 1
    }
  }
}
```

#### Update Subject
**PUT** `/academic/subjects/:id`

**Authentication:** Required

**Request:**
```json
{
  "name": "Introduction to Programming - Updated",
  "credits": 5,
  "hoursPerWeek": 8
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Materia actualizada exitosamente"
}
```

#### Delete Subject
**DELETE** `/academic/subjects/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Materia eliminada exitosamente"
}
```

#### Add Prerequisite
**POST** `/academic/subjects/:id/prerequisites`

**Authentication:** Required

**Request:**
```json
{
  "prerequisiteId": "subject-100",
  "isStrict": true
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Prerequisito agregado exitosamente"
}
```

#### Remove Prerequisite
**DELETE** `/academic/subjects/:id/prerequisites/:prerequisiteId`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Prerequisito eliminado exitosamente"
}
```

### Academic Periods

#### Create Academic Period
**POST** `/academic/periods`

**Authentication:** Required

**Request:**
```json
{
  "careerId": "career-123",
  "name": "2024-1",
  "startDate": "2024-01-15T00:00:00Z",
  "endDate": "2024-06-30T00:00:00Z"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Período académico creado exitosamente",
  "data": {
    "id": "period-123",
    "name": "2024-1",
    "startDate": "2024-01-15T00:00:00Z",
    "endDate": "2024-06-30T00:00:00Z"
  }
}
```

#### Get Periods by Career
**GET** `/academic/careers/:careerId/periods`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "period-123",
      "name": "2024-1",
      "startDate": "2024-01-15T00:00:00Z",
      "endDate": "2024-06-30T00:00:00Z",
      "isCurrent": true
    }
  ]
}
```

#### Get Current Period
**GET** `/academic/careers/:careerId/periods/current`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "period-123",
    "name": "2024-1",
    "startDate": "2024-01-15T00:00:00Z",
    "endDate": "2024-06-30T00:00:00Z"
  }
}
```

### Enrollments

#### Enroll in Subject
**POST** `/academic/enrollments`

**Authentication:** Required

**Request:**
```json
{
  "careerId": "career-123",
  "subjectId": "subject-123",
  "periodId": "period-123",
  "section": "A",
  "classroom": "Room 301"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Inscripción creada exitosamente",
  "data": {
    "id": "enrollment-123",
    "subjectId": "subject-123",
    "periodId": "period-123",
    "section": "A",
    "status": "ENROLLED"
  }
}
```

#### Get Enrollments by Career
**GET** `/academic/careers/:careerId/enrollments?status=ENROLLED&periodId=period-123`

**Authentication:** Required

**Query Parameters:**
- `status` (optional): Filter by status (ENROLLED, IN_PROGRESS, PASSED, FAILED, WITHDRAWN)
- `periodId` (optional): Filter by period

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "enrollment-123",
      "subject": {
        "id": "subject-123",
        "code": "CS101",
        "name": "Introduction to Programming",
        "credits": 4
      },
      "period": {
        "id": "period-123",
        "name": "2024-1"
      },
      "status": "ENROLLED",
      "section": "A",
      "finalGrade": null
    }
  ]
}
```

#### Get Enrollment by ID
**GET** `/academic/enrollments/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "enrollment-123",
    "subject": {
      "id": "subject-123",
      "code": "CS101",
      "name": "Introduction to Programming"
    },
    "period": {
      "id": "period-123",
      "name": "2024-1"
    },
    "status": "IN_PROGRESS",
    "section": "A",
    "classroom": "Room 301",
    "finalGrade": null,
    "grades": []
  }
}
```

#### Update Enrollment
**PUT** `/academic/enrollments/:id`

**Authentication:** Required

**Request:**
```json
{
  "section": "B",
  "classroom": "Room 305",
  "status": "IN_PROGRESS"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Inscripción actualizada exitosamente"
}
```

#### Withdraw from Enrollment
**POST** `/academic/enrollments/:id/withdraw`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Inscripción retirada exitosamente"
}
```

---

## Grades

### Create Grade
**POST** `/grades/grades`

**Authentication:** Required

**Request:**
```json
{
  "enrollmentId": "enrollment-123",
  "cutNumber": 1,
  "value": 4.5,
  "weight": 0.33,
  "gradeDate": "2024-03-15T00:00:00Z",
  "observations": "Excellent work"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Nota creada exitosamente",
  "data": {
    "id": "grade-123",
    "enrollmentId": "enrollment-123",
    "cutNumber": 1,
    "value": 4.5,
    "weight": 0.33
  }
}
```

### Get Grades by Enrollment
**GET** `/grades/enrollments/:enrollmentId/grades`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "grades": [
      {
        "id": "grade-123",
        "cutNumber": 1,
        "value": 4.5,
        "weight": 0.33,
        "gradeDate": "2024-03-15T00:00:00Z",
        "observations": "Excellent work",
        "gradeItems": []
      }
    ],
    "finalGrade": 4.5,
    "weightedAverage": 4.5
  }
}
```

### Update Grade
**PUT** `/grades/grades/:id`

**Authentication:** Required

**Request:**
```json
{
  "value": 4.7,
  "observations": "Outstanding performance"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Nota actualizada exitosamente"
}
```

### Delete Grade
**DELETE** `/grades/grades/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Nota eliminada exitosamente"
}
```

### Create Grade Item
**POST** `/grades/grade-items`

**Authentication:** Required

**Request:**
```json
{
  "gradeId": "grade-123",
  "name": "Midterm Exam",
  "value": 4.5,
  "weight": 0.5,
  "maxValue": 5.0,
  "gradeDate": "2024-03-15T00:00:00Z"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Item de nota creado exitosamente",
  "data": {
    "id": "grade-item-123",
    "gradeId": "grade-123",
    "name": "Midterm Exam",
    "value": 4.5
  }
}
```

### Update Grade Item
**PUT** `/grades/grade-items/:id`

**Authentication:** Required

**Request:**
```json
{
  "value": 4.8,
  "weight": 0.6
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Item de nota actualizado exitosamente"
}
```

### Delete Grade Item
**DELETE** `/grades/grade-items/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Item de nota eliminado exitosamente"
}
```

### Get Career GPA
**GET** `/grades/careers/:careerId/gpa`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "gpa": 3.85,
    "totalCredits": 180,
    "earnedCredits": 80,
    "gradeScale": "FIVE",
    "breakdown": [
      {
        "period": "2024-1",
        "gpa": 4.0,
        "credits": 20
      }
    ]
  }
}
```

---

## Schedules

### Create Schedule
**POST** `/schedules/schedules`

**Authentication:** Required

**Request:**
```json
{
  "enrollmentId": "enrollment-123",
  "dayOfWeek": 1,
  "startTime": "08:00",
  "endTime": "10:00",
  "location": "Room 301",
  "scheduleType": "LECTURE",
  "isRecurring": true
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Horario creado exitosamente",
  "data": {
    "id": "schedule-123",
    "enrollmentId": "enrollment-123",
    "dayOfWeek": 1,
    "startTime": "08:00",
    "endTime": "10:00",
    "location": "Room 301"
  }
}
```

### Get Schedules by Enrollment
**GET** `/schedules/enrollments/:enrollmentId/schedules`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "schedule-123",
      "dayOfWeek": 1,
      "startTime": "08:00",
      "endTime": "10:00",
      "location": "Room 301",
      "scheduleType": "LECTURE"
    }
  ]
}
```

### Get Weekly Schedule
**GET** `/schedules/schedules/weekly?careerId=career-123&periodId=period-123`

**Authentication:** Required

**Query Parameters:**
- `careerId` (required): Career ID
- `periodId` (optional): Period ID (default: current period)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "monday": [
      {
        "id": "schedule-123",
        "startTime": "08:00",
        "endTime": "10:00",
        "subject": {
          "code": "CS101",
          "name": "Introduction to Programming"
        },
        "location": "Room 301"
      }
    ],
    "tuesday": [],
    "wednesday": [],
    "thursday": [],
    "friday": [],
    "saturday": [],
    "sunday": []
  }
}
```

### Check Schedule Conflicts
**GET** `/schedules/careers/:careerId/schedules/conflicts?dayOfWeek=1&startTime=08:00&endTime=10:00`

**Authentication:** Required

**Query Parameters:**
- `dayOfWeek` (required): Day of week (0-6)
- `startTime` (required): Start time (HH:MM)
- `endTime` (required): End time (HH:MM)
- `periodId` (optional): Period ID

**Response (200):**
```json
{
  "success": true,
  "data": {
    "hasConflict": true,
    "conflicts": [
      {
        "id": "schedule-123",
        "subject": "CS101",
        "startTime": "08:00",
        "endTime": "10:00"
      }
    ]
  }
}
```

### Update Schedule
**PUT** `/schedules/schedules/:id`

**Authentication:** Required

**Request:**
```json
{
  "startTime": "09:00",
  "endTime": "11:00",
  "location": "Room 305"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Horario actualizado exitosamente"
}
```

### Delete Schedule
**DELETE** `/schedules/schedules/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Horario eliminado exitosamente"
}
```

### Create Schedule Exception
**POST** `/schedules/schedule-exceptions`

**Authentication:** Required

**Request:**
```json
{
  "scheduleId": "schedule-123",
  "exceptionDate": "2024-03-20T00:00:00Z",
  "reason": "Holiday",
  "isCancelled": true
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Excepción de horario creada exitosamente",
  "data": {
    "id": "exception-123",
    "scheduleId": "schedule-123",
    "exceptionDate": "2024-03-20T00:00:00Z",
    "reason": "Holiday"
  }
}
```

### Update Schedule Exception
**PUT** `/schedules/schedule-exceptions/:id`

**Authentication:** Required

**Request:**
```json
{
  "reason": "University Holiday",
  "newStartTime": "10:00",
  "newEndTime": "12:00"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Excepción actualizada exitosamente"
}
```

### Delete Schedule Exception
**DELETE** `/schedules/schedule-exceptions/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Excepción eliminada exitosamente"
}
```

---

## Notifications

### Create Notification
**POST** `/notifications`

**Authentication:** Required (Admin/Internal)

**Request:**
```json
{
  "title": "New Grade Posted",
  "message": "Your grade for CS101 has been posted",
  "type": "GRADE",
  "priority": "MEDIUM",
  "actionUrl": "/grades/123"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Notificación creada exitosamente",
  "data": {
    "id": "notification-123",
    "title": "New Grade Posted",
    "type": "GRADE",
    "priority": "MEDIUM"
  }
}
```

### Get User Notifications
**GET** `/notifications?page=1&limit=20&unreadOnly=true&type=GRADE`

**Authentication:** Required

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `unreadOnly` (optional): Filter unread only (true/false)
- `type` (optional): Filter by type (GRADE, SCHEDULE, PAYMENT, SYSTEM, REMINDER, ACADEMIC, CUSTOM)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "notifications": [
      {
        "id": "notification-123",
        "title": "New Grade Posted",
        "message": "Your grade for CS101 has been posted",
        "type": "GRADE",
        "priority": "MEDIUM",
        "isRead": false,
        "createdAt": "2024-03-20T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 50,
      "page": 1,
      "limit": 20,
      "totalPages": 3
    }
  }
}
```

### Get Unread Count
**GET** `/notifications/unread/count`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "count": 15
  }
}
```

### Get Notification by ID
**GET** `/notifications/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "notification-123",
    "title": "New Grade Posted",
    "message": "Your grade for CS101 has been posted",
    "type": "GRADE",
    "priority": "MEDIUM",
    "isRead": false,
    "actionUrl": "/grades/123",
    "createdAt": "2024-03-20T10:30:00Z"
  }
}
```

### Mark as Read
**PUT** `/notifications/:id/read`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Notificación marcada como leída"
}
```

### Mark All as Read
**PUT** `/notifications/read-all`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Todas las notificaciones marcadas como leídas"
}
```

### Update Notification
**PUT** `/notifications/:id`

**Authentication:** Required

**Request:**
```json
{
  "isRead": true
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Notificación actualizada exitosamente"
}
```

### Delete Notification
**DELETE** `/notifications/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Notificación eliminada exitosamente"
}
```

### Delete All Read Notifications
**DELETE** `/notifications/read-all`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Notificaciones leídas eliminadas exitosamente",
  "data": {
    "deletedCount": 25
  }
}
```

---

## Subscriptions & Plans

### Plans

#### Create Plan (Admin)
**POST** `/subscriptions/plans`

**Authentication:** Required

**Request:**
```json
{
  "name": "Premium",
  "description": "Full access to all features",
  "price": 29.99,
  "currency": "USD",
  "billingPeriod": "MONTHLY",
  "maxCareers": 5,
  "maxSubjectsPerCareer": 100,
  "features": {
    "analytics": true,
    "gpaCalculator": true,
    "scheduleConflicts": true,
    "emailNotifications": true,
    "export": true
  },
  "isActive": true
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Plan creado exitosamente",
  "data": {
    "id": "plan-123",
    "name": "Premium",
    "price": 29.99,
    "billingPeriod": "MONTHLY"
  }
}
```

#### Get All Plans
**GET** `/subscriptions/plans`

**Authentication:** None (Public)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "plan-free",
      "name": "Free",
      "price": 0,
      "billingPeriod": "MONTHLY",
      "maxCareers": 1,
      "maxSubjectsPerCareer": 20,
      "isActive": true
    },
    {
      "id": "plan-premium",
      "name": "Premium",
      "price": 29.99,
      "billingPeriod": "MONTHLY",
      "maxCareers": 5,
      "maxSubjectsPerCareer": 100,
      "isActive": true
    }
  ]
}
```

#### Get Plan by ID
**GET** `/subscriptions/plans/:id`

**Authentication:** None (Public)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "plan-premium",
    "name": "Premium",
    "description": "Full access to all features",
    "price": 29.99,
    "currency": "USD",
    "billingPeriod": "MONTHLY",
    "maxCareers": 5,
    "maxSubjectsPerCareer": 100,
    "features": {
      "analytics": true,
      "gpaCalculator": true,
      "scheduleConflicts": true,
      "emailNotifications": true,
      "export": true
    }
  }
}
```

#### Update Plan
**PUT** `/subscriptions/plans/:id`

**Authentication:** Required

**Request:**
```json
{
  "price": 34.99,
  "description": "Updated description"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Plan actualizado exitosamente"
}
```

#### Delete Plan
**DELETE** `/subscriptions/plans/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Plan eliminado exitosamente"
}
```

### Subscriptions

#### Create Subscription
**POST** `/subscriptions`

**Authentication:** Required

**Request:**
```json
{
  "planId": "plan-premium"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Suscripción creada exitosamente",
  "data": {
    "id": "subscription-123",
    "planId": "plan-premium",
    "status": "ACTIVE",
    "startDate": "2024-03-20T00:00:00Z",
    "endDate": "2024-04-20T00:00:00Z"
  }
}
```

#### Get User Subscriptions
**GET** `/subscriptions?status=ACTIVE`

**Authentication:** Required

**Query Parameters:**
- `status` (optional): Filter by status (ACTIVE, EXPIRED, CANCELLED, PENDING)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "subscription-123",
      "plan": {
        "id": "plan-premium",
        "name": "Premium",
        "price": 29.99
      },
      "status": "ACTIVE",
      "startDate": "2024-03-20T00:00:00Z",
      "endDate": "2024-04-20T00:00:00Z"
    }
  ]
}
```

#### Get Active Subscription
**GET** `/subscriptions/active`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "subscription-123",
    "plan": {
      "id": "plan-premium",
      "name": "Premium",
      "maxCareers": 5,
      "features": {
        "analytics": true
      }
    },
    "status": "ACTIVE",
    "startDate": "2024-03-20T00:00:00Z",
    "endDate": "2024-04-20T00:00:00Z"
  }
}
```

#### Get Subscription by ID
**GET** `/subscriptions/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "subscription-123",
    "plan": {
      "id": "plan-premium",
      "name": "Premium"
    },
    "status": "ACTIVE",
    "startDate": "2024-03-20T00:00:00Z",
    "endDate": "2024-04-20T00:00:00Z",
    "autoRenew": true
  }
}
```

#### Update Subscription
**PUT** `/subscriptions/:id`

**Authentication:** Required

**Request:**
```json
{
  "autoRenew": false
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Suscripción actualizada exitosamente"
}
```

#### Change Plan
**PUT** `/subscriptions/:id/plan`

**Authentication:** Required

**Request:**
```json
{
  "newPlanId": "plan-enterprise"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Plan cambiado exitosamente",
  "data": {
    "newPlanId": "plan-enterprise",
    "effectiveDate": "2024-04-20T00:00:00Z"
  }
}
```

#### Cancel Subscription
**POST** `/subscriptions/:id/cancel`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Suscripción cancelada exitosamente",
  "data": {
    "status": "CANCELLED",
    "endDate": "2024-04-20T00:00:00Z"
  }
}
```

#### Renew Subscription
**POST** `/subscriptions/:id/renew`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Suscripción renovada exitosamente",
  "data": {
    "status": "ACTIVE",
    "newEndDate": "2024-05-20T00:00:00Z"
  }
}
```

### Feature Validation

#### Validate Feature Access
**GET** `/subscriptions/features/:featureName/validate`

**Authentication:** Required

**Path Parameters:**
- `featureName`: Name of the feature to validate

**Response (200):**
```json
{
  "success": true,
  "data": {
    "hasAccess": true,
    "featureName": "analytics",
    "plan": "Premium"
  }
}
```

#### Validate Career Limit
**GET** `/subscriptions/limits/careers`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "canCreate": true,
    "current": 2,
    "limit": 5,
    "remaining": 3
  }
}
```

#### Validate Subject Limit
**GET** `/subscriptions/limits/subjects/:careerId`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "canCreate": true,
    "current": 45,
    "limit": 100,
    "remaining": 55
  }
}
```

---

## Payments & Invoices

### Payments

#### Create Payment
**POST** `/payments`

**Authentication:** Required

**Request:**
```json
{
  "subscriptionId": "subscription-123",
  "amount": 29.99,
  "currency": "USD",
  "paymentMethod": "CREDIT_CARD",
  "paymentProvider": "STRIPE"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Pago creado exitosamente",
  "data": {
    "id": "payment-123",
    "amount": 29.99,
    "currency": "USD",
    "status": "PENDING",
    "paymentMethod": "CREDIT_CARD"
  }
}
```

#### Get User Payments
**GET** `/payments?status=COMPLETED&page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `status` (optional): Filter by status (PENDING, COMPLETED, FAILED, REFUNDED, CANCELLED)
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "payments": [
      {
        "id": "payment-123",
        "amount": 29.99,
        "currency": "USD",
        "status": "COMPLETED",
        "paymentMethod": "CREDIT_CARD",
        "createdAt": "2024-03-20T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 10,
      "page": 1,
      "limit": 10,
      "totalPages": 1
    }
  }
}
```

#### Get Payment by ID
**GET** `/payments/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "payment-123",
    "amount": 29.99,
    "currency": "USD",
    "status": "COMPLETED",
    "paymentMethod": "CREDIT_CARD",
    "paymentProvider": "STRIPE",
    "transactionId": "txn_1234567890",
    "subscription": {
      "id": "subscription-123",
      "plan": {
        "name": "Premium"
      }
    },
    "createdAt": "2024-03-20T10:30:00Z"
  }
}
```

#### Update Payment
**PUT** `/payments/:id`

**Authentication:** Required

**Request:**
```json
{
  "status": "COMPLETED",
  "transactionId": "txn_1234567890"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pago actualizado exitosamente"
}
```

#### Process Payment
**POST** `/payments/:id/process`

**Authentication:** Required

**Request:**
```json
{
  "paymentToken": "tok_visa",
  "metadata": {
    "customerId": "cus_123"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Pago procesado exitosamente",
  "data": {
    "status": "COMPLETED",
    "transactionId": "txn_1234567890"
  }
}
```

#### Refund Payment
**POST** `/payments/:id/refund`

**Authentication:** Required

**Request:**
```json
{
  "amount": 29.99,
  "reason": "Customer request"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Reembolso procesado exitosamente",
  "data": {
    "status": "REFUNDED",
    "refundAmount": 29.99
  }
}
```

### Invoices

#### Create Invoice
**POST** `/payments/invoices`

**Authentication:** Required

**Request:**
```json
{
  "subscriptionId": "subscription-123",
  "amount": 29.99,
  "currency": "USD",
  "dueDate": "2024-04-20T00:00:00Z",
  "items": [
    {
      "description": "Premium Plan - Monthly",
      "quantity": 1,
      "unitPrice": 29.99,
      "total": 29.99
    }
  ]
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Factura creada exitosamente",
  "data": {
    "id": "invoice-123",
    "invoiceNumber": "INV-2024-001",
    "amount": 29.99,
    "status": "PENDING",
    "dueDate": "2024-04-20T00:00:00Z"
  }
}
```

#### Get User Invoices
**GET** `/payments/invoices?status=PAID&page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `status` (optional): Filter by status (DRAFT, PENDING, PAID, OVERDUE, CANCELLED, REFUNDED)
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "invoices": [
      {
        "id": "invoice-123",
        "invoiceNumber": "INV-2024-001",
        "amount": 29.99,
        "currency": "USD",
        "status": "PAID",
        "dueDate": "2024-04-20T00:00:00Z",
        "createdAt": "2024-03-20T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 5,
      "page": 1,
      "limit": 10,
      "totalPages": 1
    }
  }
}
```

#### Generate Invoice Number
**GET** `/payments/invoices/generate-number`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "invoiceNumber": "INV-2024-042"
  }
}
```

#### Get Invoice by ID
**GET** `/payments/invoices/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "invoice-123",
    "invoiceNumber": "INV-2024-001",
    "amount": 29.99,
    "currency": "USD",
    "status": "PAID",
    "dueDate": "2024-04-20T00:00:00Z",
    "items": [
      {
        "description": "Premium Plan - Monthly",
        "quantity": 1,
        "unitPrice": 29.99,
        "total": 29.99
      }
    ],
    "payment": {
      "id": "payment-123",
      "status": "COMPLETED"
    }
  }
}
```

#### Update Invoice
**PUT** `/payments/invoices/:id`

**Authentication:** Required

**Request:**
```json
{
  "status": "PAID",
  "paidDate": "2024-03-25T00:00:00Z"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Factura actualizada exitosamente"
}
```

#### Mark Invoice as Paid
**POST** `/payments/invoices/:id/mark-paid`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Factura marcada como pagada",
  "data": {
    "status": "PAID",
    "paidDate": "2024-03-25T00:00:00Z"
  }
}
```

#### Delete Invoice
**DELETE** `/payments/invoices/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Factura eliminada exitosamente"
}
```

### Webhooks

#### Payment Webhook
**POST** `/payments/webhooks`

**Authentication:** None (Validated by signature)

**Request:**
```json
{
  "type": "payment.completed",
  "data": {
    "paymentId": "payment-123",
    "status": "COMPLETED",
    "transactionId": "txn_1234567890"
  },
  "signature": "sha256_signature_here"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Webhook procesado exitosamente"
}
```

---

## Preferences

### Get User Preferences
**GET** `/preferences`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "pref-123",
    "notifications": {
      "emailGradeUpdates": true,
      "emailScheduleChanges": true,
      "pushNotifications": true,
      "smsReminders": false
    },
    "display": {
      "theme": "dark",
      "language": "es",
      "timezone": "America/New_York",
      "dateFormat": "DD/MM/YYYY",
      "timeFormat": "24h"
    },
    "academic": {
      "defaultGradeScale": "FIVE",
      "showGPA": true,
      "weekStartsOn": 1
    }
  }
}
```

### Update Preferences
**PUT** `/preferences`

**Authentication:** Required

**Request:**
```json
{
  "notifications": {
    "emailGradeUpdates": true,
    "pushNotifications": false
  },
  "display": {
    "theme": "light",
    "language": "en"
  }
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferencias actualizadas exitosamente",
  "data": {
    "id": "pref-123",
    "notifications": {
      "emailGradeUpdates": true,
      "pushNotifications": false
    },
    "display": {
      "theme": "light",
      "language": "en"
    }
  }
}
```

### Update Notification Preferences
**PUT** `/preferences/notifications`

**Authentication:** Required

**Request:**
```json
{
  "emailGradeUpdates": true,
  "emailScheduleChanges": true,
  "pushNotifications": true,
  "smsReminders": false
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferencias de notificación actualizadas exitosamente"
}
```

### Update Display Preferences
**PUT** `/preferences/display`

**Authentication:** Required

**Request:**
```json
{
  "theme": "dark",
  "language": "es",
  "timezone": "America/Los_Angeles",
  "dateFormat": "MM/DD/YYYY",
  "timeFormat": "12h"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferencias de visualización actualizadas exitosamente"
}
```

### Update Academic Preferences
**PUT** `/preferences/academic`

**Authentication:** Required

**Request:**
```json
{
  "defaultGradeScale": "TEN",
  "showGPA": true,
  "weekStartsOn": 0
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Preferencias académicas actualizadas exitosamente"
}
```

---

## Professors

### Create Professor
**POST** `/professors`

**Authentication:** Required

**Request:**
```json
{
  "firstName": "Dr. Jane",
  "lastName": "Smith",
  "email": "jane.smith@university.edu",
  "phone": "+1234567890",
  "department": "Computer Science",
  "officeLocation": "Building A, Room 305",
  "officeHours": "Mon-Wed 2-4 PM"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Profesor creado exitosamente",
  "data": {
    "id": "professor-123",
    "firstName": "Dr. Jane",
    "lastName": "Smith",
    "email": "jane.smith@university.edu",
    "department": "Computer Science"
  }
}
```

### Get All Professors
**GET** `/professors?department=Computer Science&page=1&limit=10`

**Authentication:** Required

**Query Parameters:**
- `department` (optional): Filter by department
- `page` (optional): Page number
- `limit` (optional): Items per page

**Response (200):**
```json
{
  "success": true,
  "data": {
    "professors": [
      {
        "id": "professor-123",
        "firstName": "Dr. Jane",
        "lastName": "Smith",
        "email": "jane.smith@university.edu",
        "department": "Computer Science"
      }
    ],
    "pagination": {
      "total": 20,
      "page": 1,
      "limit": 10,
      "totalPages": 2
    }
  }
}
```

### Search Professors
**GET** `/professors/search?query=smith&limit=10`

**Authentication:** Required

**Query Parameters:**
- `query` (required): Search term
- `limit` (optional): Max results (default: 10)

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "professor-123",
      "firstName": "Dr. Jane",
      "lastName": "Smith",
      "email": "jane.smith@university.edu",
      "department": "Computer Science"
    }
  ]
}
```

### Get Professor by ID
**GET** `/professors/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "professor-123",
    "firstName": "Dr. Jane",
    "lastName": "Smith",
    "email": "jane.smith@university.edu",
    "phone": "+1234567890",
    "department": "Computer Science",
    "officeLocation": "Building A, Room 305",
    "officeHours": "Mon-Wed 2-4 PM",
    "biography": "Expert in AI and Machine Learning",
    "subjects": []
  }
}
```

### Get Professor Subjects
**GET** `/professors/:id/subjects`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "enrollmentId": "enrollment-123",
      "subject": {
        "id": "subject-123",
        "code": "CS101",
        "name": "Introduction to Programming"
      },
      "period": {
        "id": "period-123",
        "name": "2024-1"
      },
      "section": "A"
    }
  ]
}
```

### Update Professor
**PUT** `/professors/:id`

**Authentication:** Required

**Request:**
```json
{
  "phone": "+9876543210",
  "officeLocation": "Building B, Room 101",
  "officeHours": "Tue-Thu 3-5 PM"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profesor actualizado exitosamente"
}
```

### Assign Professor to Enrollment
**POST** `/professors/assign`

**Authentication:** Required

**Request:**
```json
{
  "professorId": "professor-123",
  "enrollmentId": "enrollment-123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profesor asignado exitosamente"
}
```

### Remove Professor from Enrollment
**POST** `/professors/remove`

**Authentication:** Required

**Request:**
```json
{
  "enrollmentId": "enrollment-123"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Profesor removido exitosamente"
}
```

### Soft Delete Professor
**DELETE** `/professors/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Profesor eliminado exitosamente"
}
```

### Restore Professor
**POST** `/professors/:id/restore`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Profesor restaurado exitosamente"
}
```

---

## Menus

### Get User Menu Tree
**GET** `/menus/user/tree`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "menu-1",
      "name": "Dashboard",
      "path": "/dashboard",
      "icon": "dashboard",
      "order": 1,
      "children": []
    },
    {
      "id": "menu-2",
      "name": "Academic",
      "path": "/academic",
      "icon": "school",
      "order": 2,
      "children": [
        {
          "id": "menu-2-1",
          "name": "Careers",
          "path": "/academic/careers",
          "icon": "graduation-cap",
          "order": 1
        }
      ]
    }
  ]
}
```

### Get Menu Tree (All Active)
**GET** `/menus/tree`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "menu-1",
      "name": "Dashboard",
      "path": "/dashboard",
      "icon": "dashboard",
      "order": 1,
      "parentId": null,
      "children": []
    }
  ]
}
```

### Get All Menus (Flat)
**GET** `/menus`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "menu-1",
      "name": "Dashboard",
      "path": "/dashboard",
      "icon": "dashboard",
      "order": 1,
      "parentId": null,
      "isActive": true
    }
  ]
}
```

### Create Menu
**POST** `/menus`

**Authentication:** Required

**Request:**
```json
{
  "name": "Analytics",
  "path": "/analytics",
  "icon": "chart-bar",
  "order": 5,
  "parentId": null,
  "description": "Advanced analytics and reports"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Menú creado exitosamente",
  "data": {
    "id": "menu-123",
    "name": "Analytics",
    "path": "/analytics",
    "icon": "chart-bar",
    "order": 5
  }
}
```

### Get Menu by ID
**GET** `/menus/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "menu-123",
    "name": "Analytics",
    "path": "/analytics",
    "icon": "chart-bar",
    "order": 5,
    "parentId": null,
    "description": "Advanced analytics and reports",
    "isActive": true
  }
}
```

### Update Menu
**PUT** `/menus/:id`

**Authentication:** Required

**Request:**
```json
{
  "name": "Advanced Analytics",
  "order": 3
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Menú actualizado exitosamente"
}
```

### Soft Delete Menu
**DELETE** `/menus/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Menú eliminado exitosamente"
}
```

### Restore Menu
**POST** `/menus/:id/restore`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "message": "Menú restaurado exitosamente"
}
```

### Assign Plan Access
**POST** `/menus/access`

**Authentication:** Required

**Request:**
```json
{
  "menuId": "menu-123",
  "planId": "plan-premium"
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Acceso asignado exitosamente"
}
```

### Update Plan Access
**PUT** `/menus/access`

**Authentication:** Required

**Request:**
```json
{
  "menuId": "menu-123",
  "planId": "plan-premium",
  "canView": true,
  "canEdit": false
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Acceso actualizado exitosamente"
}
```

### Remove Plan Access
**DELETE** `/menus/access?menuId=menu-123&planId=plan-premium`

**Authentication:** Required

**Query Parameters:**
- `menuId` (required): Menu ID
- `planId` (required): Plan ID

**Response (200):**
```json
{
  "success": true,
  "message": "Acceso removido exitosamente"
}
```

### Get Plan Access
**GET** `/menus/access/:planId`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "menuId": "menu-123",
      "menu": {
        "name": "Analytics",
        "path": "/analytics"
      },
      "canView": true,
      "canEdit": false
    }
  ]
}
```

---

## Activity Logs

### Get Activity Logs
**GET** `/activity-logs?page=1&limit=20&action=CREATE&entity=CAREER`

**Authentication:** Required

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `action` (optional): Filter by action (CREATE, UPDATE, DELETE, LOGIN, etc.)
- `entity` (optional): Filter by entity (USER, CAREER, SUBJECT, etc.)
- `startDate` (optional): Filter from date (ISO 8601)
- `endDate` (optional): Filter to date (ISO 8601)

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-123",
        "action": "CREATE",
        "entity": "CAREER",
        "entityId": "career-123",
        "description": "Created career Computer Science",
        "ipAddress": "192.168.1.1",
        "userAgent": "Mozilla/5.0...",
        "createdAt": "2024-03-20T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 20,
      "totalPages": 5
    }
  }
}
```

### Get User Statistics
**GET** `/activity-logs/stats`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "totalActions": 250,
    "actionsByType": {
      "CREATE": 50,
      "UPDATE": 80,
      "DELETE": 10,
      "LOGIN": 100,
      "LOGOUT": 10
    },
    "lastLogin": "2024-03-20T10:30:00Z",
    "mostActiveDay": "2024-03-15",
    "actionsToday": 15
  }
}
```

### Get All Activity Logs (Admin)
**GET** `/activity-logs/admin/all?page=1&limit=50&userId=user-123`

**Authentication:** Required (Admin)

**Query Parameters:**
- `page` (optional): Page number
- `limit` (optional): Items per page
- `userId` (optional): Filter by user ID
- `action` (optional): Filter by action
- `entity` (optional): Filter by entity

**Response (200):**
```json
{
  "success": true,
  "data": {
    "logs": [
      {
        "id": "log-123",
        "userId": "user-123",
        "user": {
          "email": "user@example.com",
          "firstName": "John"
        },
        "action": "CREATE",
        "entity": "CAREER",
        "createdAt": "2024-03-20T10:30:00Z"
      }
    ],
    "pagination": {
      "total": 1000,
      "page": 1,
      "limit": 50,
      "totalPages": 20
    }
  }
}
```

### Get Activity by Entity
**GET** `/activity-logs/entity/:entity/:entityId`

**Authentication:** Required

**Path Parameters:**
- `entity`: Entity type (USER, CAREER, SUBJECT, etc.)
- `entityId`: Entity ID

**Response (200):**
```json
{
  "success": true,
  "data": [
    {
      "id": "log-123",
      "action": "CREATE",
      "entity": "CAREER",
      "entityId": "career-123",
      "description": "Created career Computer Science",
      "createdAt": "2024-03-20T10:30:00Z"
    },
    {
      "id": "log-124",
      "action": "UPDATE",
      "entity": "CAREER",
      "entityId": "career-123",
      "description": "Updated career Computer Science",
      "createdAt": "2024-03-21T14:20:00Z"
    }
  ]
}
```

### Get Activity Log by ID
**GET** `/activity-logs/:id`

**Authentication:** Required

**Response (200):**
```json
{
  "success": true,
  "data": {
    "id": "log-123",
    "userId": "user-123",
    "action": "CREATE",
    "entity": "CAREER",
    "entityId": "career-123",
    "description": "Created career Computer Science",
    "ipAddress": "192.168.1.1",
    "userAgent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64)...",
    "metadata": {
      "careerName": "Computer Science",
      "university": "MIT"
    },
    "createdAt": "2024-03-20T10:30:00Z"
  }
}
```

### Create Activity Log (Manual)
**POST** `/activity-logs`

**Authentication:** Required (Admin/Internal)

**Request:**
```json
{
  "action": "CUSTOM",
  "entity": "OTHER",
  "entityId": "custom-123",
  "description": "Custom activity log",
  "metadata": {
    "customField": "value"
  }
}
```

**Response (201):**
```json
{
  "success": true,
  "message": "Log de actividad creado exitosamente",
  "data": {
    "id": "log-456",
    "action": "CUSTOM",
    "entity": "OTHER",
    "createdAt": "2024-03-20T10:30:00Z"
  }
}
```

### Delete Old Logs (Admin)
**DELETE** `/activity-logs/admin/clean?days=90`

**Authentication:** Required (Admin)

**Query Parameters:**
- `days` (required): Delete logs older than X days

**Response (200):**
```json
{
  "success": true,
  "message": "Logs antiguos eliminados exitosamente",
  "data": {
    "deletedCount": 500
  }
}
```

---

## Verification

### Verify Email
**GET** `/verification/verify-email?token=eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...`

**Authentication:** None (Public)

**Query Parameters:**
- `token` (required): Email verification token

**Response (200):**
```json
{
  "success": true,
  "message": "Email verificado exitosamente",
  "data": {
    "email": "user@example.com",
    "verified": true
  }
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Token inválido o expirado",
  "error": "INVALID_TOKEN"
}
```

### Resend Verification Email
**POST** `/verification/resend-verification`

**Authentication:** None (Public)

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Email de verificación enviado exitosamente"
}
```

### Request Password Reset
**POST** `/verification/request-password-reset`

**Authentication:** None (Public)

**Request:**
```json
{
  "email": "user@example.com"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Email de recuperación enviado exitosamente"
}
```

### Reset Password
**POST** `/verification/reset-password`

**Authentication:** None (Public)

**Request:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9...",
  "newPassword": "NewSecurePass456"
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Contraseña actualizada exitosamente"
}
```

**Error Response (400):**
```json
{
  "success": false,
  "message": "Token inválido o expirado",
  "error": "INVALID_TOKEN"
}
```

---

## Analytics

### Get Career Statistics
**GET** `/analytics/career/statistics?careerId=career-123&periodId=period-123`

**Authentication:** Required

**Query Parameters:**
- `careerId` (required): Career ID
- `periodId` (optional): Period ID (default: all periods)

**Response (200):**
```json
{
  "success": true,
  "message": "Estadísticas obtenidas exitosamente",
  "data": {
    "period": {
      "id": "period-123",
      "name": "2024-1"
    },
    "totalSubjects": 45,
    "completedSubjects": 20,
    "inProgressSubjects": 5,
    "failedSubjects": 2,
    "averageGrade": 4.2,
    "gpa": 3.85,
    "creditDistribution": {
      "total": 180,
      "earned": 80,
      "inProgress": 20,
      "remaining": 80
    },
    "gradeDistribution": {
      "A": 8,
      "B": 10,
      "C": 2,
      "F": 2
    },
    "subjectsByType": {
      "REQUIRED": 35,
      "ELECTIVE": 8,
      "FREE_ELECTIVE": 2
    }
  }
}
```

### Predict GPA
**POST** `/analytics/gpa/predict`

**Authentication:** Required

**Request:**
```json
{
  "careerId": "career-123",
  "targetGrades": [
    {
      "subjectId": "subject-150",
      "grade": 4.5,
      "credits": 4
    },
    {
      "subjectId": "subject-151",
      "grade": 4.0,
      "credits": 3
    }
  ]
}
```

**Response (200):**
```json
{
  "success": true,
  "message": "Predicción de GPA calculada exitosamente",
  "data": {
    "currentGPA": 3.85,
    "projectedGPA": 3.92,
    "improvementNeeded": 0.07,
    "targetGrades": [
      {
        "subjectId": "subject-150",
        "subjectName": "Advanced Algorithms",
        "grade": 4.5,
        "credits": 4,
        "impact": 0.05
      }
    ],
    "analysis": {
      "totalCreditsUsed": 87,
      "weightedAverage": 3.92,
      "suggestion": "Keep up the good work to maintain your GPA above 3.9"
    }
  }
}
```

### Get Subject Recommendations
**GET** `/analytics/subjects/recommendations?careerId=career-123&limit=5`

**Authentication:** Required

**Query Parameters:**
- `careerId` (required): Career ID
- `limit` (optional): Number of recommendations (default: 5, max: 20)

**Response (200):**
```json
{
  "success": true,
  "message": "Recomendaciones obtenidas exitosamente",
  "data": {
    "count": 5,
    "recommendations": [
      {
        "subject": {
          "id": "subject-150",
          "code": "CS301",
          "name": "Advanced Algorithms",
          "credits": 4,
          "semester": {
            "number": 3,
            "name": "Third Semester"
          }
        },
        "recommendationScore": 15,
        "reason": "Recommended for current semester, required subject",
        "prerequisites": [
          {
            "id": "subject-100",
            "code": "CS101",
            "name": "Introduction to Programming",
            "isPassed": true
          }
        ],
        "difficulty": "MEDIUM",
        "estimatedWorkload": "6 hours/week"
      }
    ]
  }
}
```

### Analyze Performance by Subject Type
**GET** `/analytics/performance/by-type?careerId=career-123`

**Authentication:** Required

**Query Parameters:**
- `careerId` (required): Career ID

**Response (200):**
```json
{
  "success": true,
  "message": "Análisis de rendimiento obtenido exitosamente",
  "data": {
    "byType": [
      {
        "subjectType": "REQUIRED",
        "totalSubjects": 35,
        "completedSubjects": 18,
        "averageGrade": 4.1,
        "passRate": 0.9,
        "totalCredits": 140,
        "earnedCredits": 72
      },
      {
        "subjectType": "ELECTIVE",
        "totalSubjects": 8,
        "completedSubjects": 2,
        "averageGrade": 4.5,
        "passRate": 1.0,
        "totalCredits": 32,
        "earnedCredits": 8
      }
    ],
    "overallAverage": 4.2,
    "bestPerformingType": "ELECTIVE",
    "needsImprovement": null
  }
}
```

### Get Performance Trends
**GET** `/analytics/performance/trends?careerId=career-123&periods=5`

**Authentication:** Required

**Query Parameters:**
- `careerId` (required): Career ID
- `periods` (optional): Number of periods to analyze (default: 5, max: 20)

**Response (200):**
```json
{
  "success": true,
  "message": "Tendencias de rendimiento obtenidas exitosamente",
  "data": {
    "trends": [
      {
        "period": {
          "id": "period-120",
          "name": "2023-2"
        },
        "averageGrade": 3.8,
        "gpa": 3.65,
        "subjectsEnrolled": 6,
        "subjectsPassed": 5,
        "subjectsFailed": 1,
        "totalCredits": 24,
        "passRate": 0.83
      },
      {
        "period": {
          "id": "period-123",
          "name": "2024-1"
        },
        "averageGrade": 4.2,
        "gpa": 3.85,
        "subjectsEnrolled": 5,
        "subjectsPassed": 5,
        "subjectsFailed": 0,
        "totalCredits": 20,
        "passRate": 1.0
      }
    ],
    "analysis": {
      "trend": "IMPROVING",
      "averageGrowth": 0.2,
      "consistencyScore": 0.85,
      "prediction": "Based on current trend, GPA will reach 4.0 in 2 semesters"
    }
  }
}
```

---

## Error Responses

All endpoints may return the following error responses:

### 400 Bad Request
```json
{
  "success": false,
  "message": "Datos de entrada inválidos",
  "errors": {
    "email": "Email inválido",
    "password": "Mínimo 8 caracteres"
  }
}
```

### 401 Unauthorized
```json
{
  "success": false,
  "message": "No autorizado",
  "error": "TOKEN_INVALID"
}
```

### 403 Forbidden
```json
{
  "success": false,
  "message": "Acceso denegado",
  "error": "INSUFFICIENT_PERMISSIONS"
}
```

### 404 Not Found
```json
{
  "success": false,
  "message": "Recurso no encontrado",
  "error": "RESOURCE_NOT_FOUND"
}
```

### 409 Conflict
```json
{
  "success": false,
  "message": "El email ya existe",
  "error": "EMAIL_ALREADY_EXISTS"
}
```

### 429 Too Many Requests
```json
{
  "success": false,
  "message": "Demasiadas solicitudes, intenta más tarde",
  "error": "RATE_LIMIT_EXCEEDED"
}
```

### 500 Internal Server Error
```json
{
  "success": false,
  "message": "Error interno del servidor",
  "error": "SERVER_ERROR"
}
```

---

## Rate Limiting

All endpoints are rate-limited to prevent abuse:

- **Public endpoints:** 100 requests per 15 minutes per IP
- **Authenticated endpoints:** 1000 requests per 15 minutes per user
- **Login endpoint:** 5 attempts per 15 minutes per IP

Rate limit headers are included in all responses:
```
X-RateLimit-Limit: 1000
X-RateLimit-Remaining: 999
X-RateLimit-Reset: 1679328000
```

---

## Pagination

List endpoints support pagination with the following query parameters:

- `page`: Page number (default: 1)
- `limit`: Items per page (default: 10, max: 100)

Paginated responses include:
```json
{
  "success": true,
  "data": {
    "items": [...],
    "pagination": {
      "total": 100,
      "page": 1,
      "limit": 10,
      "totalPages": 10
    }
  }
}
```

---

## Timestamps

All timestamps are in ISO 8601 format (UTC):
```
2024-03-20T10:30:00Z
```

---

## Changelog

- **v1.0.0** (2024-03-20): Initial API release with all 13 modules (100+ endpoints)
