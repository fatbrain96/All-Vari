# Vari Backend Setup Guide

## Project Overview
This is a Spring Boot 3 backend application for the Vari health reporting system, built with Java 17 and PostgreSQL (Supabase).

## Setup Guide

### Prerequisites
- Java 17 or higher
- Maven 3.6+
- VS Code with Java Extension Pack OR IntelliJ IDEA
- Supabase account with PostgreSQL database

### Import Project into VS Code
1. Open VS Code
2. Install the "Extension Pack for Java" if not already installed
3. File → Open Folder → Select the `Vari-Backend` folder
4. VS Code will automatically detect the Maven project and download dependencies
5. Wait for the Java Language Server to initialize

### Import Project into IntelliJ IDEA
1. Open IntelliJ IDEA
2. File → Open → Select the `Vari-Backend` folder
3. IntelliJ will automatically import the Maven project
4. Wait for indexing and dependency resolution to complete

### Database Configuration
1. Create a Supabase project at https://supabase.com
2. Go to Settings → Database
3. Copy your connection string
4. Open `src/main/resources/application.properties`
5. Replace `[PASTE_YOUR_SUPABASE_URI_HERE]` with your Supabase URI
6. Replace `[PASTE_YOUR_PASSWORD_HERE]` with your database password

### Running the Application
```bash
# Using Maven
mvn spring-boot:run

# Or using Java directly (after mvn clean package)
java -jar target/vari-backend-0.0.1-SNAPSHOT.jar
```

The application will start on `http://localhost:8080`

## API Documentation

### Endpoints

| Method | Endpoint | Description | Request Body | Response |
|--------|----------|-------------|--------------|----------|
| GET | `/` | Health check endpoint | None | JSON status message |
| POST | `/api/reports` | Create new health report | HealthReport JSON | Created HealthReport |
| GET | `/api/reports` | Get all health reports | None | Array of HealthReport |

### Sample JSON Payloads

#### POST /api/reports - Create Health Report
```json
{
  "source": "Community Health Worker",
  "illCount": "5",
  "symptom": "Fever and headache",
  "villageName": "Kampala Village",
  "latitude": 0.3476,
  "longitude": 32.5825,
  "photoUrl": "https://example.com/photo.jpg"
}
```

#### Response - Created Health Report
```json
{
  "id": 1,
  "source": "Community Health Worker",
  "illCount": "5",
  "symptom": "Fever and headache",
  "villageName": "Kampala Village",
  "latitude": 0.3476,
  "longitude": 32.5825,
  "reportTime": "2024-01-20T10:30:00",
  "photoUrl": "https://example.com/photo.jpg"
}
```

#### GET /api/reports - Get All Reports
```json
[
  {
    "id": 1,
    "source": "Community Health Worker",
    "illCount": "5",
    "symptom": "Fever and headache",
    "villageName": "Kampala Village",
    "latitude": 0.3476,
    "longitude": 32.5825,
    "reportTime": "2024-01-20T10:30:00",
    "photoUrl": "https://example.com/photo.jpg"
  }
]
```

#### GET / - Health Check
```json
{
  "message": "Vari Backend API is running",
  "version": "1.0.0",
  "status": "healthy"
}
```

## Database Guide

### HealthReport Table Structure

The `health_reports` table is automatically created by Hibernate with the following structure:

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | BIGINT | PRIMARY KEY, AUTO_INCREMENT | Unique identifier |
| source | VARCHAR(255) | - | Source of the report (e.g., "Health Worker") |
| ill_count | VARCHAR(255) | - | Number of ill people reported |
| symptom | VARCHAR(255) | - | Symptoms observed |
| village_name | VARCHAR(255) | - | Name of the village |
| latitude | DOUBLE | - | GPS latitude coordinate |
| longitude | DOUBLE | - | GPS longitude coordinate |
| report_time | TIMESTAMP | NOT NULL, DEFAULT NOW() | When the report was created |
| photo_url | VARCHAR(255) | - | URL to associated photo |

### Database Features
- **Auto-timestamps**: `report_time` is automatically set when a record is created
- **Hibernate DDL**: Tables are created/updated automatically on application startup
- **PostgreSQL Dialect**: Optimized for PostgreSQL database features

### Supabase Integration
- The application connects to Supabase PostgreSQL instance
- Uses standard PostgreSQL JDBC driver
- Supports all PostgreSQL data types and features
- Automatic connection pooling via HikariCP (Spring Boot default)

## Development Notes
- **CORS**: Enabled for all origins (configure for production)
- **Error Handling**: Basic error responses implemented
- **Lombok**: Used for reducing boilerplate code
- **JPA Repositories**: Additional query methods can be added as needed
- **Production Ready**: Includes proper logging, error handling, and configuration