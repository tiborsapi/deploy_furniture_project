# ======================
# 1. Build stage
# ======================
FROM eclipse-temurin:21-jdk AS builder

# Install Maven
RUN apt-get update && apt-get install -y maven && rm -rf /var/lib/apt/lists/*

# Set workdir
WORKDIR /app

# Copy Maven files first for caching
COPY ./be/pom.xml .
COPY ./be/src ./src

# Build the application (skip tests for faster build)
RUN mvn -ntp -DskipTests package

# ======================
# 2. Runtime stage
# ======================
FROM eclipse-temurin:21-jdk

WORKDIR /app

# Copy the built jar from builder stage
COPY --from=builder /app/target/*.jar app.jar

# Expose port (optional, for documentation)
EXPOSE 8080

# Run the application
ENTRYPOINT ["java", "-jar", "app.jar"]
