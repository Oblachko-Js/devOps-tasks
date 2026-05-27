## Использование systemd service файлов

### Установка
1. Скопировать service файлы в `/etc/systemd/system/`:
```bash
sudo cp app1.service /etc/systemd/system/
sudo cp app2@.service /etc/systemd/system/
sudo systemctl daemon-reload
```

### Запуск сервисов

Запуск app1:
```bash
sudo systemctl start app1.service
```

Запуск двух экземпляров app2 (запустятся только после app1):
```bash
sudo systemctl start app2@1.service
sudo systemctl start app2@2.service
```

### Автозагрузка
```bash
sudo systemctl enable app1.service
sudo systemctl enable app2@1.service
sudo systemctl enable app2@2.service
```

### Проверка статуса
```bash
sudo systemctl status app1.service
sudo systemctl status app2@1.service
sudo systemctl status app2@2.service
```

### Логи
```bash
sudo journalctl -u app1.service -f
sudo journalctl -u app2@1.service -f
sudo journalctl -u app2@2.service -f
```

## Особенности конфигурации

- **app1.service** - базовый сервис, запускается на порту 9001
- **app2@.service** - template для двух экземпляров:
  - app2@1 запускается на порту 9001 после app1
  - app2@2 запускается на порту 9002 после app1
- `Requires=app1.service` гарантирует, что app2 не запустится без app1
- `After=app1.service` гарантирует порядок запуска

## Dockerfile

Пример `Dockerfile` для приложения с той же структурой `bin/`, `conf/` и `lib/`:

- Базовый образ: `eclipse-temurin:17-jre-jammy`
- Копирование `bin/`, `conf/`, `lib/`
- Переменные окружения: `PORT`, `CONFIG_FILE_PATH`, `JAVA_OPTS`
- Запуск через `./bin/application_name`

### Сборка
```bash
docker build -t app1-image .
```

Если нужно использовать другой исполняемый файл, можно переопределить аргумент:
```bash
docker build --build-arg APP_NAME=app2 -t app2-image .
```
```

### Запуск
```bash
docker run -e PORT=9001 app1-image
```

Для второго приложения запустить два контейнера:
```bash
docker run -e PORT=9002 app2-image
docker run -e PORT=9003 app2-image
```

### Примечание

В контейнере приложение получает переменные окружения, а `ENTRYPOINT` передаёт их в `-Dconfig.file`, `-Dhttp.port` и `-Dfile.encoding`.

## Docker Compose

Пример `docker-compose.yml` для запуска одной копии `app1` и двух экземпляров `app2`.

- `app1` запускается первым
- `app2_1` и `app2_2` зависят от `app1` через `depends_on`
- `app2_1` использует порт `9002`, `app2_2` — порт `9003`

### Запуск
```bash
docker compose up --build
```

### Остановка
```bash
docker compose down
```

### Если нужно запустить только часть
```bash
docker compose up --build app1
``` 
или
```bash
docker compose up --build app2_1 app2_2
```

### Структура

- `docker-compose.yml` описывает три сервиса: `app1`, `app2_1`, `app2_2`
- все сервисы строятся из `Dockerfile` с аргументом `APP_NAME`
- `app2` контейнеры запускаются только после поднятия `app1`
