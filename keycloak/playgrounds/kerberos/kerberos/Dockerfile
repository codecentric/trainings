FROM debian:bookworm-slim

RUN apt-get update && apt-get install -y --no-install-recommends \
    krb5-kdc \
    krb5-admin-server \
    krb5-user \
    && rm -rf /var/lib/apt/lists/*

COPY krb5.conf /etc/krb5.conf
COPY kdc.conf /etc/krb5kdc/kdc.conf
COPY kadm5.acl /etc/krb5kdc/kadm5.acl
COPY init-kdc.sh /init-kdc.sh

RUN chmod +x /init-kdc.sh

EXPOSE 88/udp 88/tcp 749/tcp 464/udp 464/tcp

CMD ["/init-kdc.sh"]
