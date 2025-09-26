nginx

varnishd -a :8081 \
         -T :6082 \
         -f /etc/varnish/default.vcl \
         -s malloc,256m \
         -S /etc/varnish/secret \
         -n /var/lib/varnish