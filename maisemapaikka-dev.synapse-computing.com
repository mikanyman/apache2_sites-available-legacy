<VirtualHost *:80>

        ServerName maisemapaikka-dev.synapse-computing.com
        ServerAdmin info@synapse-computing.com

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

        ErrorLog ${APACHE_LOG_DIR}/error.log

        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel info

        CustomLog ${APACHE_LOG_DIR}/access.log combined

        Alias /doc/ "/usr/share/doc/"
        <Directory "/usr/share/doc/">
                Options Indexes MultiViews FollowSymLinks
                AllowOverride None
                Order deny,allow
                Deny from all
                Allow from 127.0.0.0/255.0.0.0 ::1/128
        </Directory>

        # ---------- mod_wsgi ----------

        # ihtml -- fetch inserted html-page
        AliasMatch ^/\w+/rockart/research/ihtml/(\w+)/(\w+\.\w+) /home/mnyman/.virtualenvs/maisemapaikka/filestore/media/uploads/$1/$2

        # lhtml -- only image-endings here -- Django renders surrounding portal content
        AliasMatch ^/\w+/rockart/research/lhtml/(\w+)/(\w+\.jpg) /home/mnyman/.virtualenvs/maisemapaikka/filestore/media/uploads/$1/$2
        AliasMatch ^/\w+/rockart/research/lhtml/(\w+)/(\w+\.png) /home/mnyman/.virtualenvs/maisemapaikka/filestore/media/uploads/$1/$2
        AliasMatch ^/\w+/rockart/research/lhtml/(\w+)/(\w+\.gif) /home/mnyman/.virtualenvs/maisemapaikka/filestore/media/uploads/$1/$2

        WSGIDaemonProcess maisemapaikka-dev.synapse-computing.com user=mnyman group=mnyman processes=2 threads=15 display-name=%{GROUP}
        WSGIProcessGroup maisemapaikka-dev.synapse-computing.com

        WSGIScriptAlias / /home/mnyman/.virtualenvs/maisemapaikka/staging/maisemapaikka/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/maisemapaikka/staging/maisemapaikka/apache>
                Order deny,allow
                Allow from all
        </Directory>

</VirtualHost>

