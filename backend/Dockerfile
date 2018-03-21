FROM python:alpine

RUN pip3 install --no-cache-dir flask

COPY app.py /opt/app.py

ENV FLASK_APP=/opt/app.py

EXPOSE 8000

CMD ["flask", "run", "--host=0.0.0.0", "--port=8000"]
