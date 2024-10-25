FROM hlebsur/pet_clinic_not_full:latest AS build
FROM eclipse-temurin:18-jre-jammy AS production

EXPOSE 8080

RUN mkdir -p /app
COPY --from=build /app/target/spring-petclinic-*.jar /app/spring-petclinic.jar
COPY __cacert_entrypoint.sh /app/__cacert_entrypoint.sh
RUN cp -f /app/spring-petclinic.jar /spring-petclinic.jar && \
    cp -f /app/__cacert_entrypoint.sh /__cacert_entrypoint.sh

CMD ["java", "-Djava.security.egd=file:/dev/./urandom", "-jar", "/spring-petclinic.jar"]
HEALTHCHECK --start-period=1m CMD curl -f http://localhost:8080/ || exit 1
