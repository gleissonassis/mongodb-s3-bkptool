# Usando uma imagem base que inclui as ferramentas necessárias
FROM mongo:latest

ARG SOURCE 
ARG DATABASE_NAME 
ARG S3_BUCKET_PATH 
ARG S3_ACCESS_KEY 
ARG S3_SECRET_KEY 
ARG S3_ENDPOINT_URL 
ARG CRON_SCHEDULE 

ENV SOURCE=$SOURCE
ENV DATABASE_NAME=$DATABASE_NAME
ENV S3_BUCKET_PATH=$S3_BUCKET_PATH
ENV S3_ACCESS_KEY=$S3_ACCESS_KEY
ENV S3_SECRET_KEY=$S3_SECRET_KEY
ENV S3_ENDPOINT_URL=$S3_ENDPOINT_URL
ENV CRON_SCHEDULE=$CRON_SCHEDULE

# Instalando AWS CLI e cron
RUN apt-get update && apt-get install -y awscli cron

# Copiando o script para o container
COPY backup_script.sh /backup_script.sh
RUN chmod +x /backup_script.sh

# Copiando o script de inicialização
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh

# Iniciando o script de entrada
ENTRYPOINT ["/entrypoint.sh"]