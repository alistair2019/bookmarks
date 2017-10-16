server {
	listen  80;

    server_name local.manage.airpush.com;
	error_log /tmp/manage.airpush.com.err.log debug;
	
	location / {
                root /home/alistair/github2/airpush22/public;
                index index.html index.php;
                try_files $uri $uri/ /index.php?$args;
	}

    rewrite ^/docs/(.*)$ http://docs.airpush.com/$1 permanent;

	location ~ \.php$ {
#        root /home/alistair/github2/airpush22/public;
#		#fastcgi_pass   127.0.0.1:9000;
#		fastcgi_index  index.php;
#        fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
#		#include        fastcgi.conf;

        root /home/alistair/github2/airpush22/public;
        fastcgi_split_path_info ^(.+\.php)(/.+)$;
        fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
        fastcgi_index index.php;
        fastcgi_read_timeout 9000;
        include fastcgi_params;
        fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
	}

	location ~ /\.ht {
		deny  all;
	}
	
	location ~ /\.svn {
                deny  all;
        }
}

server {
    listen               443;
 
    server_name          local.manage.airpush.com;

    ssl                  on;
    ssl_certificate      /home/alistair/github2/local.manage.airpush.com.crt;
    ssl_certificate_key  /home/alistair/github2/local.manage.airpush.com.key;
 
    ssl_session_timeout  5m;
 
    ssl_protocols        SSLv2 SSLv3 TLSv1;
    ssl_ciphers          HIGH:!aNULL:!MD5;
    ssl_prefer_server_ciphers   on;

    error_log            /tmp/local.manage.airpush.com.log;

    location / {
	root /home/alistair/github2/airpush22/public;
    
	index index.html index.php;
	try_files $uri $uri/ /index.php?$args;
	proxy_ssl_session_reuse off;
    }

    location ~ \.php$ {
#	root /home/alistair/github2/airpush22/public;
#	#fastcgi_pass   127.0.0.1:9000;
#    fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
#	fastcgi_index  index.php;
#	#include        fastcgi.conf;
#	fastcgi_param HTTPS on;

    root /home/alistair/github2/airpush22/public;
    fastcgi_split_path_info ^(.+\.php)(/.+)$;
    fastcgi_pass unix:/var/run/php/php5.6-fpm.sock;
    fastcgi_index index.php;
    fastcgi_read_timeout 9000;
    include fastcgi_params;
    fastcgi_param HTTPS on;
    fastcgi_param SCRIPT_FILENAME $document_root$fastcgi_script_name;
    }

    location ~ /\.ht {
	deny  all;
    }
	
    location ~ /\.svn {
        deny  all;
    } 
}
