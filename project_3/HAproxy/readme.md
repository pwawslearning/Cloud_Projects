# After running terraform codes haproxy.cfg file automatically create

## Creating key and certificates for SSL

- $ cd haproxy
- $ openssl req -new -x509 -days 365 -nodes -newkey rsa:2048 -keyout haproxy.key -out haproxy.crt -subj "/CN=localhost1"
- $ cat haproxy.crt | openssl x509 --noout --text 
- $ cd ..
- $ bash -c 'cat haproxy.crt haproxy.key >> haproxy.pem'
