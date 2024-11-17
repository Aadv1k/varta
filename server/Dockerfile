FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE 1
ENV PYTHONUNBUFFERED 1

WORKDIR /varta-server

COPY requirements.txt /varta-server

RUN apt-get update && \
    apt-get install -y --no-install-recommends libmagic1 libmagic-dev && \
    pip install --no-cache-dir -r requirements.txt

COPY . /varta-server/

CMD ["python", "manage.py", "runserver", "0.0.0.0:8000"]
