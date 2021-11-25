#!/bin/bash
#
# /etc/bacula/scripts/before-bacula-pfsense.sh
#
# Rubens C. Urquisa
#
# Adaptado por: Heitor Faria 
#               Bluesball
#
####
# Backup Pfsense via curl
# Requisitos:
#           Checar se https esta habilitado
#           Checar se curl esta instalado
# Testado na Versao pfsense 2.5.2
#####
# Substitua por suas credenciais do Pfsense
USER=usuario
PASSWORD=senha
# Informe o Local de backup (no servidor bacula)
DIR_BKP="/local/onde/serao/salvos/os/arquivos/"
# Modificar IP'S e quantidades de Pfsense (HOST[x]=ip)
HOST[0]="x.x.x.x"
#HOST[1]="x.x.x.x2"
# Testa e eventualmente Cria Dir de Backup
if [ ! -d "$DIR_BKP" ]; then
 mkdir $DIR_BKP
fi
# Faz backup - acessa os hosts Pfsense
x=0;
while [ $x != ${#HOST[@]} ]
do
 
 echo "`date` Iniciando bkp config.xml ${HOST[$x]}"

# Fetch the login form and save the cookies and CSRF token:
curl -L -k --cookie-jar $DIR_BKP/cookies.txt https://${HOST[$x]} | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > $DIR_BKP/csrf.txt
# Submit the login form to complete the login procedure:
curl -L -k --cookie $DIR_BKP/cookies.txt --cookie-jar $DIR_BKP/cookies.txt --data-urlencode "login=Login" --data-urlencode "usernamefld=$USER" --data-urlencode "passwordfld=$PASSWORD" --data-urlencode "__csrf_magic=$(cat csrf.txt)" https://${HOST[$x]}> /dev/null
# Fetch the target page to obtain a new CSRF token:
curl -L -k --cookie $DIR_BKP/cookies.txt --cookie-jar $DIR_BKP/cookies.txt https://${HOST[$x]}/diag_backup.php  | grep "name='__csrf_magic'" | sed 's/.*value="\(.*\)".*/\1/' > $DIR_BKP/csrf.txt
# Download the backup:
curl -L -k --cookie $DIR_BKP/cookies.txt --cookie-jar $DIR_BKP/cookies.txt --data-urlencode "download=download" --data-urlencode "donotbackuprrd=yes" --data-urlencode "__csrf_magic=$(head -n 1 $DIR_BKP/csrf.txt)" https://${HOST[$x]}/diag_backup.php > $DIR_BKP/config-${HOST[$x]}-`date +%Y%m%d%H%M%S`.xml
 
 STATUS=$(echo $?)
 
 if [[ $STATUS == 0 ]]; then
 echo "Ok bkp config.xml ${HOST[$x]}"
 else
 echo "Erro bkp config.xml ${HOST[$x]}"
 ERRO=1
 fi
 
 let "x = x +1"
done
if [[ $ERRO == 1 ]]; then
 echo "Erro na execucao, exit 1"
 exit 1
fi
