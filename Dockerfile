
FROM python:3.10 as requirements-stage

WORKDIR /tmp

RUN pip install poetry

COPY ./pyproject.toml ./poetry.lock* /tmp/


RUN poetry export -f requirements.txt --output requirements.txt --without-hashes

FROM python:3.10

WORKDIR /code

COPY --from=requirements-stage /tmp/requirements.txt /code/requirements.txt

RUN pip install --no-cache-dir --upgrade -r /code/requirements.txt

COPY . /code/

# Heroku uses PORT, Azure App Services uses WEBSITES_PORT, Fly.io uses 8080 by default
CMD ["sh", "-c", "uvicorn server.main:app --host 0.0.0.0 --port 8000"]

# Expose port 8000
EXPOSE 8000

# define environment variables
ENV DATASTORE postgres
ENV OPENAI_API_KEY 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
ENV BEARER_TOKEN mylife-RsK09Zvut-6IJ4ct1v9-c0-U?/V5q?mNGQbKocX4?drpR8f!ewNX07lNO1BpiU-NRAaWs3zX=H6VY92s=4i=kESxdjBLKwxaDGkx/w5bY/rzeG9M=jUxZtk28KeO!imsWiA3uw3SblxNGUHbBw9bsBV7V/=75igKC/!/AwqQPtpvY36e?zcHOmQrvhuj/O2d?46ga8UykNfWbREwDXAg6Rc5BcUhk0H5oSX/5-MJXThuL0P2wsxNEKG83
ENV PG_HOST localhost
ENV PG_PORT 5432
ENV PG_USER postgres
ENV PG_PASSWORD 7bT!!icgg&f%7MH
ENV PG_DB postgres