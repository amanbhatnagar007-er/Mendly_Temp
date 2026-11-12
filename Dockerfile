FROM python:3.12-slim

ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    DATABASE_URL=sqlite:////var/data/mendaly.db \
    MENDALY_REQUIRE_AUTH=1

WORKDIR /app
COPY requirements.txt ./requirements.txt
RUN pip install --no-cache-dir \
    'fastapi>=0.110,<1' \
    'uvicorn>=0.27,<1' \
    'sqlalchemy>=2.0,<3' \
    'pydantic>=2.6,<3' \
    'httpx>=0.27,<1' \
    'python-dotenv>=1.0,<2'
COPY app ./app
RUN mkdir -p /var/data
EXPOSE 8000
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
