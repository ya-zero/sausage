FROM python:latest
ADD . /app
WORKDIR /app
RUN pip install -r requirements.txt 
RUN curl https://storage.yandexcloud.net/cloud-certs/CA.pem -o YandexInternalRootCA.crt
ENTRYPOINT ["python"]
CMD ["app.py"]
EXPOSE 8080
