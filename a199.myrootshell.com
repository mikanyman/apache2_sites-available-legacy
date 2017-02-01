<VirtualHost *:8080>

        ServerName a199.myrootshell.com
        ServerAdmin webmaster@localhost

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


        # ---------- AWStats ----------

        Alias /awstatsclasses "/usr/share/awstats/lib/"
        Alias /awstats-icon/ "/usr/share/awstats/icon/"
        Alias /awstatscss "/usr/share/doc/awstats/examples/css"
        ScriptAlias /awstats/ /usr/lib/cgi-bin/
        Options ExecCGI -MultiViews +SymLinksIfOwnerMatch


        # ---------- mod_wsgi ----------

        # Vaihtoehto 1
        WSGIDaemonProcess a199.myrootshell.com user=mnyman group=mnyman processes=2 threads=15 display-name=%{GROUP}
        WSGIProcessGroup a199.myrootshell.com

        # Vaihtoehto 2
        # dbxml ei pelaa multithreaded asetuksilla ilmeisestikkaan (luo useamman python istunnon joka sotkee asiat)
        #WSGIApplicationGroup %{GLOBAL}
        #WSGIDaemonProcess a199.myrootshell.com threads=1
        #WSGIProcessGroup a199.myrootshell.com

        Alias /rart /home/heli/pub/rockart
        <Directory /home/heli/pub/rockart>
                Order deny,allow
                Allow from all
        </Directory>

        Alias /sumu /home/heli/pub/rockart3
        <Directory /home/heli/pub/rockart3>
                Order deny,allow
                Allow from all
        </Directory>

        Alias /sumu-dev /home/heli/dev/rockart3
        <Directory /home/heli/dev/rockart3>
                Order deny,allow
                Allow from all
        </Directory>

        # ---------- Test deployments ----------
        WSGIScriptAlias /tei /home/mnyman/.virtualenvs/sdpub/staging/SDPublisher/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/sdpub/staging/SDPublisher/apache>
                Order deny,allow
                Allow from all
        </Directory>

        WSGIScriptAlias /chri /home/mnyman/.virtualenvs/chri/staging/chri/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/chri/staging/chri/apache>
                Order deny,allow
                Allow from all
        </Directory>

        WSGIScriptAlias /rock-art /home/mnyman/.virtualenvs/rockart/staging/rockart/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/rockart/staging/rockart/apache>
                Order deny,allow
                Allow from all
        </Directory>

        WSGIScriptAlias /callowaydemo /home/mnyman/.virtualenvs/callowaydemo/staging/callowaydemo/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/callowaydemo/staging/sampleproject/apache>
                Order deny,allow
                Allow from all
        </Directory>

</VirtualHost>

