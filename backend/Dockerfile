# ── Étape 1 : Build ─────────────────────────────────────────
FROM eclipse-temurin:17-jdk-alpine AS builder
WORKDIR /app

COPY gradlew .
COPY gradle gradle
COPY build.gradle .
COPY settings.gradle .
RUN chmod +x gradlew
RUN ./gradlew dependencies --no-daemon

COPY src src
RUN ./gradlew bootJar -x test --no-daemon

# ── Étape 2 : Production ─────────────────────────────────────
FROM eclipse-temurin:17-jre-alpine
WORKDIR /app

RUN addgroup -S mboalink && adduser -S mboalink -G mboalink
USER mboalink

COPY --from=builder /app/build/libs/*.jar app.jar

EXPOSE 8080

ENTRYPOINT ["java", \
  "-XX:+UseContainerSupport", \
  "-XX:MaxRAMPercentage=75.0", \
  "-Djava.security.egd=file:/dev/./urandom", \
  "-jar", "app.jar"]