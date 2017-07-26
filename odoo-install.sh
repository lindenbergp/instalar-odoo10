#!/bin/bash

#--------------------------------------------------
# Parâmetros de instalação do Servidor Odoo
#--------------------------------------------------
AT_ADMPASS=senha_super_admin_Odoo
AT_XMLRPC=True
AT_XMLRPCPORT=8069
AT_DBHOST=127.0.0.1
AT_DBPORT=5432
AT_DBUSER=odoo
AT_DBPASS=senha_odoo_pro_Postgresql
WKHTMLTOX_X64=https://downloads.wkhtmltopdf.org/0.12/0.12.2.1/wkhtmltox-0.12.2.1_linux-trusty-amd64.deb
WKHTMLTOX_X32=http://download.gna.org/wkhtmltopdf/0.12/0.12.1/wkhtmltox-0.12.1_linux-trusty-i386.deb

#--------------------------------------------------
# Atualizando Servidor
#--------------------------------------------------

echo -e "\n---- Update Server ----"
sudo apt-get update
sudo apt-get upgrade -y

#--------------------------------------------------
# PostgreSQL Server
#--------------------------------------------------
service postgres status

if [ "$?" -gt "0" ]; then
  echo -e "\n---- Instalando PostgreSQL Server ----"
  sudo apt-get install postgresql -y
else
  echo -e "\n---- PostgreSQL Server instalado com sucesso ----"
fi

echo -e "\n---- Criando usuário odoo no PostgreSQL User  ----"
sudo -u postgres psql -e --command "CREATE USER $AT_DBUSER WITH SUPERUSER PASSWORD '$AT_DBPASS'"

#--------------------------------------------------
# Dependêncies
#--------------------------------------------------

echo -e "\n---- Instalando ferramentas necessárias ----"
sudo apt-get install wget apache2 subversion git bzr bzrtools python-pip gdebi-core -y

echo -e "\n---- Instalando pacotes python ----"
sudo apt-get install python-suds python-dateutil python-feedparser python-ldap python-libxslt1 python-lxml python-mako python-openid python-psycopg2 python-pybabel python-pychart python-pydot python-pyparsing python-reportlab python-simplejson python-tz python-vatnumber python-vobject python-webdav python-werkzeug python-xlwt python-yaml python-zsi python-docutils python-psutil python-mock python-unittest2 python-jinja2 python-pypdf python-decorator python-requests python-passlib python-pil -y

echo -e "\n---- Instalando python libraries ----"
sudo pip install gdata psycogreen ofxparse XlsxWriter

echo -e "\n--- Instalando outros pacotes requeridos"
sudo apt-get install node-clean-css -y
sudo apt-get install node-less -y
sudo apt-get install python-gevent -y
sudo apt-get install nodejs npm -y
sudo npm install -g less -y
sudo npm install -g less-plugin-clean-css -y
sudo ln -s /usr/bin/nodejs /usr/bin/node

echo -e "\n---- Instalando wkhtml (PDF) necessário para o ODOO ----"
if [ "`getconf LONG_BIT`" == "64" ];then
    _url=$WKHTMLTOX_X64
else
    _url=$WKHTMLTOX_X32
fi
sudo wget $_url
sudo gdebi --n `basename $_url`
sudo ln -s /usr/local/bin/wkhtmltopdf /usr/bin
sudo ln -s /usr/local/bin/wkhtmltoimage /usr/bin

echo -e "\n---- Criando usuário ODOO no sistema ----"
sudo adduser --system --home=/opt/adax/odoo --group odoo

echo -e "\n---- Baixando repositório ODOO ----"
sudo git clone --depth 1 --branch 10.0 https://github.com/odoo/odoo.git /opt/adax/odoo

echo -e "\n---- Instalando dependências da localização brasileira ----"
sudo apt-get install libpq-dev libldap2-dev libsasl2-dev libxmlsec1-dev python-cffi libjpeg-dev -y

sudo -H pip install --upgrade pip
sudo -H pip install Babel==1.3 Jinja2==2.7.3 Mako==1.0.1 MarkupSafe==0.23 Pillow==2.7.0 Python-Chart==1.39
sudo -H pip install PyYAML==3.11 Werkzeug==0.9.6 argparse==1.2.1 decorator==3.4.0 docutils==0.12 feedparser==5.1.3
sudo -H pip install gdata==2.0.18 gevent==1.0.2 greenlet==0.4.7 jcconv==0.2.3 lxml==3.4.1 mock==1.0.1 ofxparse==0.14
sudo -H pip install passlib==1.6.2 psutil==2.2.0 psycogreen==1.0 psycopg2==2.5.4 pyPdf==1.13 pydot==1.0.2 
sudo -H pip install pyparsing==2.0.3 pyserial==2.7 python-dateutil==2.4.0 python-ldap==2.4.19 python-openid==2.2.5
sudo -H pip install pytz==2014.10 pyusb==1.0.0b2 qrcode==5.1 reportlab==3.1.44 requests==2.6.0 six==1.9.0 suds-jurko==0.6
sudo -H pip install vobject==0.6.6 wsgiref==0.1.2 XlsxWriter==0.7.7 xlwt==0.7.5 openpyxl==2.4.0-b1 boto==2.38.0
sudo -H pip install odoorpc suds_requests pytrustnfe python-boleto python-cnab
sudo -H pip install http://labs.libre-entreprise.org/frs/download.php/897/pyxmlsec-0.3.1.tar.gz

echo -e "\n---- Baixando repositório da localização brasileira ----"
sudo git clone --depth 1 --branch 10.0 https://github.com/Trust-Code/odoo-brasil.git /opt/adax/odoo-brasil

echo -e "\n---- Removendo módulo /opt/adax/odoo/addons/l10n_br para usar o br_coa em /opt/adax/odoo-brasil ----"
sudo rm -rf /opt/adax/odoo/addons/l10n_br

echo -e "* Criando arquivo de configuração do servidor"
sudo touch /etc/odoo-server.conf
sudo chown odoo:root /etc/odoo-server.conf
sudo chmod 640 /etc/odoo-server.conf

echo -e "* Inserindo dados ao arquivo de configuração do servidor"
sudo su root -c "echo '[options]' >> /etc/odoo-server.conf"
sudo su root -c "echo 'admin_passwd = $AT_ADMPASS' >> /etc/odoo-server.conf"
sudo su root -c "echo 'xmlrpc = $AT_XMLRPC' >> /etc/odoo-server.conf"
sudo su root -c "echo 'xmlrpc_port = $AT_XMLRPCPORT' >> /etc/odoo-server.conf"
sudo su root -c "echo 'db_host = $AT_DBHOST' >> /etc/odoo-server.conf"
sudo su root -c "echo 'db_port = $AT_DBPORT' >> /etc/odoo-server.conf"
sudo su root -c "echo 'db_user = $AT_DBUSER' >> /etc/odoo-server.conf"
sudo su root -c "echo 'db_password = $AT_DBPASS' >> /etc/odoo-server.conf"
sudo su root -c "echo 'logfile = /var/log/odoo/log' >> /etc/odoo-server.conf"
sudo su root -c "echo 'addons_path = /opt/adax/odoo/addons,/opt/adax/odoo-brasil' >> /etc/odoo-server.conf"

echo -e "\n---- Criando diretório de Log ----"
sudo mkdir /var/log/odoo
sudo chown odoo:root /var/log/odoo

echo "\n---- Criando arquivo de inicialização do servidor ---"
sudo cat <<EOF > /etc/systemd/system/odoo.service

[Unit]
Description=Odoo - ADAX Technology
Documentation=http://www.adaxtechnology.com/

[Service]

# Ubuntu/Debian:

Type=simple
User=odoo
ExecStart=/opt/adax/odoo/odoo-bin -c /etc/odoo-server.conf

[Install]
WantedBy=default.target
EOF

sudo chmod a+x /etc/systemd/system/odoo.service

echo -e "* Startando serviço Odoo"
sudo systemctl start odoo.service

echo -e "* Ativando serviço Odoo no boot"
sudo systemctl enable odoo.service
