# Quick Start Guide - University Organizer Backend

Complete guide to get started with the University Organizer Backend API.

## 📚 Table of Contents

1. [Prerequisites](#prerequisites)
2. [Installation](#installation)
3. [Database Setup](#database-setup)
4. [Running the Application](#running-the-application)
5. [Testing the API](#testing-the-api)
6. [Available Resources](#available-resources)
7. [Test Credentials](#test-credentials)

---

## Prerequisites

Before you begin, ensure you have the following installed:

- **Node.js** (v18 or higher)
- **npm** or **yarn**
- **PostgreSQL** (v14 or higher)
- **Postman** (optional, for API testing)

---

## Installation

1. **Clone the repository** (if you haven't already):
   ```bash
   git clone <repository-url>
   cd back_university_organizer
   ```

2. **Install dependencies**:
   ```bash
   npm install
   ```

3. **Configure environment variables**:

   Create a `.env` file in the root directory with the following variables:

   ```env
   # Server Configuration
   NODE_ENV=development
   PORT=3000

   # Database
   DATABASE_URL="postgresql://username:password@localhost:5432/university_organizer?schema=public"

   # JWT Secrets
   JWT_SECRET=your-super-secret-jwt-key-change-this-in-production
   JWT_REFRESH_SECRET=your-super-secret-refresh-jwt-key-change-this-in-production
   JWT_EXPIRES_IN=15m
   JWT_REFRESH_EXPIRES_IN=7d

   # Google OAuth (Optional)
   GOOGLE_CLIENT_ID=your-google-client-id
   GOOGLE_CLIENT_SECRET=your-google-client-secret
   GOOGLE_CALLBACK_URL=http://localhost:3000/api/auth/google/callback

   # Frontend URL
   FRONTEND_URL=http://localhost:3001

   # Email Configuration (SMTP)
   SMTP_HOST=smtp.gmail.com
   SMTP_PORT=587
   SMTP_SECURE=false
   SMTP_USER=your-email@gmail.com
   SMTP_PASSWORD=your-app-password
   EMAIL_FROM=noreply@university-organizer.com
   EMAIL_FROM_NAME=University Organizer

   # Rate Limiting
   RATE_LIMIT_WINDOW_MS=900000
   RATE_LIMIT_MAX_REQUESTS=100
   ```

---

## Database Setup

### 1. Create the PostgreSQL database:

```bash
# Connect to PostgreSQL
psql -U postgres

# Create database
CREATE DATABASE university_organizer;

# Exit psql
\q
```

### 2. Run Prisma migrations:

```bash
# Generate Prisma Client
npx prisma generate

# Run migrations to create tables
npx prisma migrate dev --name init
```

### 3. Seed the database with test data:

```bash
# Run the seed script
npm run seed
```

This will populate your database with:
- ✅ 2 API clients
- ✅ 3 subscription plans (Free, Premium, Enterprise)
- ✅ 5 menu items with hierarchy
- ✅ 3 test users
- ✅ 2 careers (Computer Science, Business Administration)
- ✅ 6 subjects with prerequisites
- ✅ 3 professors
- ✅ 5 enrollments with grades
- ✅ 3 schedules
- ✅ 3 notifications
- ✅ And more...

---

## Running the Application

### Development Mode (with auto-reload):

```bash
npm run dev
```

The server will start at `http://localhost:3000`

### Production Build:

```bash
# Build the project
npm run build

# Start production server
npm start
```

---

## Testing the API

### Option 1: Using Postman (Recommended)

1. **Import the Postman collection**:
   - Open Postman
   - Click "Import"
   - Select the file: `docs/postman/collection.json`

2. **Configure the environment variables**:
   - The collection includes variables: `baseUrl`, `accessToken`, `refreshToken`
   - `baseUrl` is set to `http://localhost:3000/api` by default

3. **Login to get access token**:
   - Navigate to `Authentication > Login`
   - Use test credentials (see below)
   - The access token will be automatically saved to the collection variable
   - All subsequent requests will use this token automatically

### Option 2: Using cURL

```bash
# Login
curl -X POST http://localhost:3000/api/auth/login \
  -H "Content-Type: application/json" \
  -d '{
    "email": "john.doe@university.edu",
    "password": "password123"
  }'

# Get current user (replace TOKEN with the accessToken from login response)
curl -X GET http://localhost:3000/api/auth/me \
  -H "Authorization: Bearer TOKEN"
```

### Option 3: Using the API Documentation

Open the complete API documentation at `docs/API.md` for:
- 📖 All 100+ endpoints organized by module
- 📝 Request/response examples
- 🔐 Authentication requirements
- ⚙️ Query parameters and path variables

---

## Available Resources

### Documentation Files

| File | Description |
|------|-------------|
| `README.md` | Project overview and features |
| `ROADMAP.md` | Development roadmap and progress (100% complete) |
| `docs/API.md` | Complete API reference with examples |
| `docs/QUICK_START.md` | This file - quick start guide |
| `docs/postman/collection.json` | Postman collection with all endpoints |

### Key Features by Module

1. **Authentication** (`/api/auth`)
   - Email/password registration and login
   - Google OAuth integration
   - JWT access and refresh tokens
   - Email verification
   - Password reset

2. **Users** (`/api/users`)
   - User CRUD operations
   - User statistics
   - Search and pagination

3. **Careers** (`/api/careers`)
   - Manage academic careers
   - Track progress and statistics
   - Multiple grading scales support

4. **Academic** (`/api/academic`)
   - Semesters, subjects, and periods
   - Enrollments with prerequisites
   - Automatic prerequisite validation

5. **Grades** (`/api/grades`)
   - Multi-cut grading system
   - GPA calculation
   - Grade items and weighted averages

6. **Schedules** (`/api/schedules`)
   - Weekly schedules
   - Conflict detection
   - Schedule exceptions (holidays, changes)

7. **Analytics** (`/api/analytics`)
   - Career statistics by period
   - GPA prediction
   - Subject recommendations
   - Performance trends

8. **Notifications** (`/api/notifications`)
   - Real-time notifications
   - Multiple types and categories
   - Read/unread tracking

9. **Subscriptions** (`/api/subscriptions`)
   - Plan-based access control
   - Feature validation
   - Limit enforcement

10. **Activity Logs** (`/api/activity-logs`)
    - Automatic action logging
    - User activity tracking
    - Audit trail

---

## Test Credentials

The seed script creates the following test users:

### User 1 (Premium Subscription)
- **Email**: `john.doe@university.edu`
- **Password**: `password123`
- **Career**: Computer Science at MIT
- **Status**: 3rd semester, active enrollments

### User 2 (Free Plan)
- **Email**: `jane.smith@university.edu`
- **Password**: `password123`
- **Career**: Business Administration at Harvard
- **Status**: 2nd semester

### User 3 (Unverified)
- **Email**: `mike.johnson@university.edu`
- **Password**: `password123`
- **Status**: Email not verified

---

## Common Commands

```bash
# Development
npm run dev              # Start dev server with auto-reload

# Database
npx prisma studio        # Open Prisma Studio (visual database editor)
npx prisma migrate dev   # Create and run new migration
npx prisma db push       # Push schema changes without migration
npm run seed             # Seed database with test data

# Build
npm run build            # Build for production
npm start                # Start production server

# Prisma
npx prisma generate      # Regenerate Prisma Client
npx prisma migrate reset # Reset database (WARNING: deletes all data)
```

---

## API Response Format

### Success Response
```json
{
  "success": true,
  "message": "Operation completed successfully",
  "data": {
    // Response data here
  }
}
```

### Error Response
```json
{
  "success": false,
  "message": "Error description",
  "error": "ERROR_CODE",
  "errors": {
    // Validation errors (if applicable)
  }
}
```

---

## Next Steps

1. ✅ **Explore the API**: Import the Postman collection and test endpoints
2. ✅ **Read the API docs**: Check `docs/API.md` for complete endpoint documentation
3. ✅ **View the database**: Run `npx prisma studio` to explore the seeded data
4. ✅ **Check the roadmap**: See `ROADMAP.md` for all implemented features
5. ✅ **Customize**: Modify environment variables and seed data as needed

---

## Troubleshooting

### Database Connection Issues
- Verify PostgreSQL is running: `pg_isready`
- Check DATABASE_URL in `.env`
- Ensure database exists: `psql -l`

### Migration Errors
- Reset database: `npx prisma migrate reset`
- Regenerate client: `npx prisma generate`
- Run migrations: `npx prisma migrate dev`

### Seed Errors
- Ensure migrations are up to date
- Check for unique constraint violations
- Reset and re-seed: `npx prisma migrate reset && npm run seed`

### Authentication Issues
- Verify JWT_SECRET is set in `.env`
- Check token expiration time
- Clear browser cookies/localStorage

---

## Support

For issues or questions:
- Check the API documentation: `docs/API.md`
- Review the roadmap: `ROADMAP.md`
- Explore with Prisma Studio: `npx prisma studio`

---

**🎉 You're all set! Happy coding!**
