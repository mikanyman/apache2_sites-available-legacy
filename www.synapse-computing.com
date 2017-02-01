<VirtualHost *:80>

        ServerName www.synapse-computing.com
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


        # ---------- SendmailAnalyzer ----------
        Alias /sareport /usr/local/sendmailanalyzer/www

        <Directory /usr/local/sendmailanalyzer/www>
                Options ExecCGI
                AddHandler cgi-script .cgi
                DirectoryIndex sa_report.cgi
                Order deny,allow
                Deny from all
                Allow from 127.0.0.1 88.115.116.99
                Allow from ::1
                # Allow from .example.com
        </Directory>


        # ---------- AWStats ----------
        Alias /awstatsclasses "/usr/share/awstats/lib/"
        Alias /awstats-icon/ "/usr/share/awstats/icon/"
        Alias /awstatscss "/usr/share/doc/awstats/examples/css"
        ScriptAlias /awstats/ /usr/lib/cgi-bin/
        Options ExecCGI -MultiViews +SymLinksIfOwnerMatch


        # ---------- Trac ----------
        WSGIScriptAlias /trac /home/mnyman/.virtualenvs/synapse/trac/sites/synapse/cgi-bin/trac.wsgi
        <Directory /home/mnyman/.virtualenvs/synapse/trac/sites/synapse/cgi-bin>
                WSGIApplicationGroup %{GLOBAL}
                Order deny,allow
                Allow from all
        </Directory>

        <Location "/trac/login">
                AuthType Basic
                AuthName "Trac"
                AuthUserFile /home/mnyman/.virtualenvs/synapse/trac/sites/synapse/conf/trac.htpasswd
                Require valid-user
        </Location>

        WSGIDaemonProcess www.synapse-computing.com user=mnyman group=mnyman processes=2 threads=15 display-name=%{GROUP}
        WSGIProcessGroup www.synapse-computing.com

        WSGIScriptAlias / /home/mnyman/.virtualenvs/synapse/staging/synapse/apache/django.wsgi
        <Directory /home/mnyman/.virtualenvs/synapse/staging/synapse/apache>
                Order deny,allow
                Allow from all
        </Directory>

</VirtualHost>
