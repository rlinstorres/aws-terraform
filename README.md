# aws-terraform-bash

- Provisionamento de Instância On Demand- AWS

Este script consiste em provisionar uma nova instância on demand na Amazon AWS através da ferramenta Terraform da Empresa Hashcorp.
https://www.terraform.io/

##### How To:

Foi criado um script chamado "terraform.sh" que faz o tratamento através de parametros para criar as instancias.

```
./terraform.sh --help
```

##### Provisionar instancias:

```
Usage: ./terraform.sh -n app-web-1 -f t2.micro -b https://s3.amazonaws.com/bucket/file-user-data -t producao
```

OPTIONS:

```
-p, --provider  - Informar o provider aws
                DEFAULT: aws

-u, --user      - Informar o usuario access_key

-s, --pass      - Informar a senha secret_key

-n, --name      - Informar o nome da instancia
                Ex.: app-web-1

-c, --count     - Informar a quantidade de instancias
                DEFAULT: 1

-f, --flavor    - Informar o tipo de instancia

-m, --ami       - Informar a AMI da instancia.
                DEFAULT: ami-XXXX

-r, --subnet    - Informar a subnet.
                DEFAULT: subnet-XXXX

-b, --bootstrap - Informar a URL de Boostrap - User Data

-t, --tag       - Informar a TAG do Ambiente

-h, --help      - Apresentacao do Help
```

##### No script existem parâmetros a serem informados:

```
# Informar o local onde esta o script do terraform.sh #
PATH_SCRIPT=""

- Dominio das intancias criadas para o cadastro de DNS
DOMAIN="dominio.com.br"
AWS_ZONE_ID="123456"

- Variaveis DEFAULT
AWS_PROVIDER="aws"
AWS_AMI="ami-XXXX"
AWS_REGION="us-east-1"
AWS_INSTANCE_PROFILE="XXXX"
AWS_KEY_NAME="key-name"
AWS_SUBNET="subnet-XXXX"
AWS_SECURITY_GROUP="sg-XXXX"
AWS_USER_SSH="ubuntu"
AWS_KEY_SSH_FILE="/path/XXX.pem"
COUNT="1"

- Variaveis inputadas através do script
AWS_USER=""
AWS_PASS=""
NAME_POOL=""
AWS_FLAVOR=""
BOOTSTRAP=""
AWS_TAG=""
```
