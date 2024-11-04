# Varta Server

- [🔨 Self-hosting Guide](#self-hosting-guide)
- [📖 Reference](#reference)
    - Configuration
    - API
    - Database
- [🏗️ Architecture](#architecture)

## Self-hosting Guide

You first need to accquire certain environment variables see [`.env.example`](./.env.example)

```env
DB_HOST=""
DB_PORT="5432"
DB_PASSWORD=""
DB_NAME=""
DB_USER=""

# https://www.zoho.com/zeptomail/help/api/email-sending.html
ZEPTOMAIL_TOKEN="<ZeptoMail Token>"
ZEPTOMAIL_FROM_ADDRESS="<ZeptoMail Domain>"

REDIS_HOST=""
REDIS_PORT=""

GOOGLE_APPLICATION_CREDENTIALS=".firebase/service-account.json"
```

To accquire the `.firebase/service-account.json` you can see [Create and delete service account keys](https://cloud.google.com/iam/docs/keys-create-delete).

Once you've set all the variables, you should first load all the data from the fixtures (if you are running for the first time)

```shell
python manage.py loaddata initial_classrooms initial_academic_year initial_departments
```

Finally the server provides a [`compose.yml`](./compose.yml), which will run a local redis instance, start the RQ worker in the background and run the 

```yml
name: varta-server
services:
  redis-cache:
    image: "redis:alpine"
    ports:
      - "6379:6379"
  server: 
    build:
      context: .
    command: sh -c "python manage.py start_rq_worker & python manage.py runserver 0.0.0.0:8000"
    depends_on: 
      - redis-cache
    ports:
      - "8000:8000"
    environment:
      REDIS_HOST: redis-cache
      REDIS_PORT: "6379"
      FIREBASE_SERVICE_ACCOUNT_JSON: ${FIREBASE_SERVICE_ACCOUNT_JSON}
    volumes:
      - ${FIREBASE_SERVICE_ACCOUNT_JSON}:/varta-server/.firebase/service-account.json
```

Once you have all this, you can simply run the following command to run everything within a vps.

```shell
FIREBASE_SERVICE_ACCOUNT_JSON=/path/to/your/service-account.json
docker compose -f ./compose.yml --env-file /path/to/env up
```

## Reference 

### Configuration

All configuration is done through [`config/setting.py`]()

### API
### Database

## Architecture
