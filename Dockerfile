# Use Maven for building, then Eclipse Temurin for running
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy the backend project
COPY Vari-Backend/ .

# Build the application
RUN mvn clean package -DskipTests

# Use Eclipse Temurin JRE for runtime (smaller and faster)
FROM eclipse-temurin:17-jre-focal

# Copy the built jar
COPY --from=build /app/target/vari-backend-0.0.1-SNAPSHOT.jar /app.jar

# Expose port
EXPOSE 8080

# Run the application with proper environment variable handling
CMD ["sh", "-c", "java -Dserver.port=${PORT:-8080} -Dspring.profiles.active=production -jar /app.jar"]