FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1
ENV PORT=8080

WORKDIR /app

COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

COPY sheets_proxy.py .

EXPOSE 8080

CMD ["python", "sheets_proxy.py"]
