FROM crystallang/crystal:1.8.2-alpine

RUN mkdir /app
COPY . /app
# Instalação das dependências do PostgreSQL
# RUN apt-get update && apt-get install -y libpq-dev

# Diretório de trabalho dentro do contêiner
WORKDIR /app

# ADD shards.yml /app/
# Copiar arquivos de origem para o contêiner
RUN shards install --frozen

# COPY ./ /app/
# Compilação do aplicativo Crystal
RUN crystal build --release src/api.cr

# Comando para executar o aplicativo
CMD ["./api"]