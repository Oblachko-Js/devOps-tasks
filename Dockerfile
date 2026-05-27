FROM eclipse-temurin:17-jre-jammy

ARG APP_NAME=application_name
ENV APP_HOME=/opt/${APP_NAME}
WORKDIR ${APP_HOME}

# Копируем структуру приложения в контейнер
# Ожидается, что в build-контексте есть каталоги bin/, conf/, lib/
COPY bin/ ./bin/
COPY conf/ ./conf/
COPY lib/ ./lib/

ENV PORT=9001 \
    CONFIG_FILE_PATH=conf/application.conf \
    JAVA_OPTS="-Xms512m -Xmx1G"

RUN chmod +x ./bin/${APP_NAME}

ENTRYPOINT ["sh", "-c", "./bin/${APP_NAME} -Dconfig.file=$CONFIG_FILE_PATH -Dhttp.port=$PORT -Dfile.encoding=UTF8"]
