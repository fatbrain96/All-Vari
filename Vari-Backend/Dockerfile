# Use Maven image for building, then OpenJDK for running
FROM maven:3.9.4-eclipse-temurin-17 AS build

# Set working directory
WORKDIR /app

# Copy pom.xml and download dependencies
COPY pom.xml .
RUN mvn dependency:go-offline -B

# Copy source code and build
COPY src ./src
RUN mvn clean package -DskipTests

# Use OpenJDK for the runtime
FROM eclipse-temurin:17-jre-alpine

# Copy the built jar from the build stage
COPY --from=build /app/target/vari-backend-0.0.1-SNAPSHOT.jar app.jar

# Expose port
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "/app.jar"]