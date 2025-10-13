#Build
FROM maven:3.9-eclipse-temurin-17 AS build
WORKDIR /app
COPY pom.xml .
RUN mvn -q -e -DskipTests dependency:go-offline
COPY src ./src
RUN mvn -q -DskipTests package

#Runtime
FROM eclipse-temurin:17-jre-jammy
WORKDIR /app

#Labels OCI
ARG APP_VERSION=0.1.0
LABEL org.opencontainers.image.title="testinfra-java" \
      org.opencontainers.image.description="Servicio test para CI/CD" \
      org.opencontainers.image.version="${APP_VERSION}" \
      org.opencontainers.image.authors="Alfredo Mazza <alfredolmazza@gmail.com>" \
      org.opencontainers.image.url="https://github.com/alfmazza/evi-baby" \
      org.opencontainers.image.source="https://github.com/alfmazza/evi-baby" \
      org.opencontainers.image.licenses="MIT"

#Seguridad: usuario no-root
RUN useradd -m appuser
USER appuser

COPY --from=build /app/target/*.jar /app/app.jar
EXPOSE 8080
ENV SPRING_PROFILES_ACTIVE=prod
ENV JAVA_TOOL_OPTIONS="-Xms256m -Xmx512m"
ENTRYPOINT ["java","-jar","/app/app.jar"]
