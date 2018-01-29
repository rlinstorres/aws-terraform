#!/bin/bash
#
#################################################
# Script para provionamento de Instancias       #
# na Amazon AWS atraves da Ferramenta Terraform #
# Ref.: https://www.terraform.io/               #
# Terraform v0.10.6                             #
#################################################

# Informar o local onde esta o script do terraform.sh #
# Ex.: /home/user/terraform.sh
PATH_SCRIPT=""

# Para criar diretorio e arquivo temporario para o uso do terraform #
TMP_ERROR=$(mktemp)
TMP_DIRECTOR=$(mktemp -d)

# Dominio das intancias criadas para o cadastro de DNS #
DOMAIN="dominio.com.br"
AWS_ZONE_ID="123456"

# Variaveis DEFAULT #
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

# Variaveis inputadas pelo script #
AWS_USER=""
AWS_PASS=""
NAME_POOL=""
AWS_FLAVOR=""
BOOTSTRAP=""
AWS_TAG=""

# Help #
usage_help() {
    echo ""
    echo "  - Provisionar instancias:"
    echo ""
    echo "  Usage: ./terraform.sh -n app-web-1 -f t2.micro -b https://s3.amazonaws.com/bucket/file-user-data -t producao"
    echo ""
    echo "  OPTIONS:"
    echo ""
    echo "  -p, --provider  - Informar o provider aws"
    echo "                    DEFAULT: aws"
    echo ""
    echo "  -u, --user      - Informar o usuario access_key"
    echo ""
    echo "  -s, --pass      - Informar a senha secret_key"
    echo ""
    echo "  -n, --name      - Informar o nome da instancia"
    echo "                    Ex.: app-web-1"
    echo ""
    echo "  -c, --count     - Informar a quantidade de instancias"
    echo "                    DEFAULT: ${COUNT}"
    echo ""
    echo "  -f, --flavor    - Informar o instance type da aws"
    echo ""
    echo "  -m, --ami       - Informar a AMI da instancia"
    echo "                    DEFAULT: ${AWS_AMI}"
    echo ""
    echo "  -r, --subnet    - Informar a subnet"
    echo "                    DEFAULT: ${AWS_SUBNET}"
    echo ""
    echo "  -b, --bootstrap - Informar a URL de Boostrap do Ambiente"
    echo ""
    echo "  -t, --tag       - Informar a TAG do Ambiente"
    echo ""
    echo "  -h, --help      - Apresentacao do Help"
}

# Tratando os inputs #
while [ $# -gt 0 ]; do
    case "$1" in
        -h|--help)
            usage_help
            exit 1
            ;;
        -p|--provider)
            AWS_PROVIDER=$2
            ;;
        -u|--user)
            AWS_USER=$2
            ;;
        -s|--pass)
            AWS_PASS=$2
            ;;
        -n|--name)
            NAME_POOL=$2
            ;;
        -c|--count)
            COUNT=$2
            ;;
        -f|--flavor)
            AWS_FLAVOR=$2
            ;;
        -m|--ami)
            AWS_AMI=$2
            ;;
        -r|--subnet)
            AWS_SUBNET=$2
            ;;
        -b|--bootstrap)
            BOOTSTRAP=$2
            ;;
        -t|--tag)
            AWS_TAG=$2
            ;;
    esac
    shift
done

# Tratando os inputs do script #
if [ "${AWS_PROVIDER}" = "aws" ]; then

    if  [ "${AWS_USER}" = "" ]; then
        echo "Digite a access_key de seu profile"
        read USER
    fi

    if  [ "${AWS_PASS}" = "" ]; then
        echo "Digite a secret_key de seu profile"
        read PASS
    fi

    if  [ "${NAME_POOL}" = "" ]; then
        echo "Digite o nome do pool"
        read NAME_POOL
    fi

    if  [ "${BOOTSTRAP}" = "" ]; then
        echo "Digite o endereco de Bootstrap do Ambiente"
        read BOOTSTRAP
    fi
else
    echo "Error: User: ${AWS_USER} e/ou Pass: ${AWS_PASS} e/ou Name_Pool: ${NAME_POOL} e/ou Bootstrap ${BOOTSTRAP} nao foram encontrados"
    echo "Veja: ./terraform.sh --help"
    exit 1
fi

# Tratando o template Terraform #
if [ "${AWS_PROVIDER}" = "aws" ]; then

/bin/cat << EOF > $TMP_DIRECTOR/aws.tf
provider "aws" {
    version = "~> 1.0"
    access_key = "\${var.access_key}"
    secret_key = "\${var.secret_key}"
    region = "\${var.region}"
}

resource "aws_instance" "${NAME_POOL}" {
    count = "\${var.count}"
    instance_type = "\${var.instance_type}"
    disable_api_termination = "true"
    ami = "\${var.ami}"
    key_name = "\${var.key_name}"
    iam_instance_profile = "\${var.instance_profile}"
    subnet_id = "\${var.subnet_id}"
    security_groups = [ "\${var.security_group}" ]
    tags {
        Name = "${NAME_POOL}"
        Ambiente = "${AWS_TAG}"
    }

    connection {
        user = "\${var.user_ssh}"
        private_key = "\${file(var.key_ssh_file)}"
        timeout = "3m"
        agent = "true"
    }

    provisioner "remote-exec" {
        inline = [
            "wget -O- ${BOOTSTRAP} | sudo bash"
        ]
    }
}

resource "aws_route53_record" "${NAME_POOL}" {
    zone_id = "${AWS_ZONE_ID}"
    name = "${NAME_POOL}.${DOMAIN}"
    type = "A"
    ttl = "300"
    records = ["\${aws_instance.${NAME_POOL}.private_ip}"]
}

output "DNS" {
    value = "\${aws_route53_record.${NAME_POOL}.name}"
}

output "IP" {
    value = "\${aws_instance.${NAME_POOL}.private_ip}"
}
EOF

# Arquivo de Variavies #
/bin/cat << EOF > $TMP_DIRECTOR/variables.tf
variable "access_key" { default = "${AWS_USER}" }
variable "secret_key" { default = "${AWS_PASS}" }
variable "ami" { default = "${AWS_AMI}" }
variable "count" { default = "${COUNT}" }
variable "region" { default = "${AWS_REGION}" }
variable "instance_type" { default = "${AWS_FLAVOR}" }
variable "instance_profile" { default = "${AWS_INSTANCE_PROFILE}" }
variable "key_name" { default = "${AWS_KEY_NAME}" }
variable "subnet_id" { default = "${AWS_SUBNET}" }   
variable "security_group" { default = "${AWS_SECURITY_GROUP}" }
variable "user_ssh" { default = "${AWS_USER_SSH}" }
variable "key_ssh_file" { default = "${AWS_KEY_SSH_FILE}" }
EOF

else
    echo "Error: Nos Inputs das informacoes nos arquivos do Terraform"
    echo "Veja: ./terraform.sh --help"
    exit 1
fi

# Validando e executando terraform com os arquivos de configuracao #
if [[ -n "$(which terraform 2>/dev/null)" ]]; then
    TERRAFORM=$(which terraform 2>/dev/null);
fi;

cd ${TMP_DIRECTOR} && ${TERRAFORM} init
run=$(${TERRAFORM} validate ${TMP_DIRECTOR}) 2> "${TMP_ERROR}"
if [[ $run = *Error* ]]; then
    echo "Validacao dos arquivos do Terraform"
    echo "$(cat ${TMP_ERROR})"
    exit 1
else
    echo "Provisionando a Instancia ${NAME_POOL}, aguarde um momento =)"
    run=$(${TERRAFORM} apply ${TMP_DIRECTOR})
fi
