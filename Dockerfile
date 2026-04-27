# Use Maven for building, then OpenJDK for running
FROM maven:3.9.4-openjdk-17 AS build

# Set working directory
WORKDIR /app

# Copy the backend project
COPY Vari-Backend/ .

# Build the application
RUN mvn clean package -DskipTests

# Use OpenJDK for runtime
FROM openjdk:17-jdk-slim

# Copy the built jar
COPY --from=build /app/target/vari-backend-0.0.1-SNAPSHOT.jar /app.jar

# Expose port
EXPOSE 8080

# Run the application
CMD ["java", "-Dserver.port=${PORT:-8080}", "-jar", "/app.jar"]