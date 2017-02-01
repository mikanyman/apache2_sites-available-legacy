<VirtualHost *:80>

        ###
        #
        # CHRI - CHURCHES
        #
        ######

        ServerName churches.synapse-computing.com
        ServerAdmin info@synapse-computing.com

        #RewriteEngine on
        #RewriteRule ^/site_media/(.*)$ http://a29.myrootshell.com:8080/transdeco/staging/site_media/$1
        #RewriteRule ^/admin_media/(.*)$ http://a29.myrootshell.com:8080/transdeco/production/admin_media/$1

        DocumentRoot /var/www
        <Directory />
                Options FollowSymLinks
                AllowOverride None
        </Directory>
        <Directory /var/www/>
                Options Indexes FollowSymLinks MultiViews
                AllowOverride None
                Order allow,deny
                allow from all
        </Directory>

        ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
        <Directory "/usr/lib/cgi-bin">
                AllowOverride None
                Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
                Order allow,deny
                Allow from all
        </Directory>

        ErrorLog /var/log/apache2/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn

        CustomLog /var/log/apache2/access.log combined

        Alias /doc/ "/usr/share/doc/"
        <Directory "/usr/share/doc/">
            Options Indexes MultiViews FollowSymLinks
            AllowOverride None
            Order deny,allow
            Deny from all
            Allow from 127.0.0.0/255.0.0.0 ::1/128
        </Directory>

        # ---------- mod_wsgi ----------

        WSGIDaemonProcess churches.synapse-computing.com user=mnyman group=mnyman processes=2 threads=15 display-name=%{GROUP}
        WSGIProcessGroup churches.synapse-computing.com

        WSGIScriptAlias / /home/mnyman/.virtualenvs/churches/staging/churches/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/churches/staging/churches/apache>
            Order deny,allow
            Allow from all
        </Directory>

</VirtualHost>

