# aws-terraform

- Provisionamento de Instância - AWS

Este script consiste em provisionar uma nova instância na Amazon AWS através da ferramenta Terraform da Empresa Hashcorp.
Referência: https://www.terraform.io/

##### How To:

Foi criado um script chamado "terraform.sh" que faz o tratamento através de parametros para criar as instancias.

```
./terraform.sh --help
```

##### Provisionar instancias:

```
Usage: ./terraform.sh -u ABCBABS -s ABCBA -n app-web-1 -r private-1a -b https://s3.amazonaws.com/bucket/file-user-data
```

OPTIONS:

```
-p, --provider  - Informar o provider aws

-u, --user      - Informar o usuario access_key

-s, --pass      - Informar a senha secret_key

-n, --name      - Informar o nome da instancia
                Ex.: app-web-1

-c, --count     - Informar a quantidade de instancias
                DEFAULT: 1

-f, --flavor    - Informar o tipo de instancia

-m, --ami       - Informar a AMI da instancia.
                HVM: ami-XXXX
                PVM: ami-XXXX

-r, --subnet    - Informar a subnet.
                DEFAULT: subnet-XXXX - private-1a

-b, --bootstrap - Informar a URL de Boostrap - User Data

-h, --help      - Apresentacao do Help
```

##### No script existem parametros a serem informados:

```
- Dominio das intancias criadas para o cadastro de DNS
DOMAIN="dominio.com.br"
ZONE_ID="123456"

- Variaveis DEFAULT
PROVIDER="aws"
BOOTSTRAP=""
USER=""
PASS=""
NAME_POOL=""
COUNT="1"
USER_SSH="ubuntu"

AWS_REGION="us-east-1"
AWS_FLAVOR=""
AWS_AMI=""
AWS_INSTANCE_PROFILE=""
AWS_KEY_NAME=""
AWS_SUBNET=""
AWS_SECURITY_GROUP=""
AWS_KEY_SSH_FILE="~/.ssh/XXX.pem"
```
