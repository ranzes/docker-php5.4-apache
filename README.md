# A Apache 2.4  e PHP 5.4 imagem docker


----

## Instruções


1. Crie uma pasta para seu projeto.
Dentro da pasta crie duas pastas:
    * `dev`: Coloque o conteúdo da sua aplicação dentro da pasta dev. normalmente usado  o conteúdo de `/var/www/html`
    * `db_data`: Pasta usada para  o banco de dados.

2. Crie o arquivo `docker-compose.yml` com o seguinte código:
```
version: '3'

services:
  wordpress:
    build: https://github.com/ranzes/docker-php5.4-apache.git
    links:
      - mysql
    ports:
      - 8080:8080
    volumes:
      - ./dev/:/var/www/html

  mysql:
    image: mariadb
    volumes:
      - ./db_data/:/var/lib/mysql
    ports:
     - 3306:3306
    environment:
      MYSQL_ROOT_PASSWORD: senha do root
      MYSQL_DATABASE: nome do banco
      MYSQL_USER: usuario do banco
      MYSQL_PASSWORD: senha do usuario do banco

volumes:
    db_data:
```

Execute `docker-compose build` dentro da raiz da pastado projeto para contruir a imagem do container.

Execute docker-compose up  para subir o container.
