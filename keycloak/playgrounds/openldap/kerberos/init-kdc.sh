#!/bin/bash
set -e

REALM="${KRB5_REALM:-EXAMPLE.COM}"
KDC_PASSWORD="${KDC_PASSWORD:-adminpassword}"
KDC_USER_PASSWORD="${KDC_USER_PASSWORD:-userpassword}"
KEYCLOAK_HOST="${KEYCLOAK_HOST:-localhost}"

echo "==> Initialising Kerberos KDC for realm: ${REALM}"

# Create the KDC database if it doesn't exist yet
if [ ! -f /var/lib/krb5kdc/principal ]; then
    echo "==> Creating KDC database..."
    kdb5_util create -r "${REALM}" -s -P "${KDC_PASSWORD}"

    echo "==> Adding admin principal..."
    kadmin.local -q "addprinc -pw ${KDC_PASSWORD} admin/admin@${REALM}"

    echo "==> Adding user principal (alice)..."
    kadmin.local -q "addprinc -pw ${KDC_USER_PASSWORD} alice@${REALM}"

    echo "==> Adding HTTP service principal for Keycloak (SPNEGO)..."
    kadmin.local -q "addprinc -randkey HTTP/${KEYCLOAK_HOST}@${REALM}"

    echo "==> Exporting Keycloak keytab..."
    mkdir -p /keytabs
    kadmin.local -q "ktadd -k /keytabs/keycloak.keytab HTTP/${KEYCLOAK_HOST}@${REALM}"
    chmod 644 /keytabs/keycloak.keytab

    echo "==> KDC initialised."
else
    echo "==> KDC database already exists, skipping init."
fi

echo "==> Starting KDC..."
krb5kdc -n &
KDC_PID=$!

echo "==> Starting kadmind..."
kadmind -nofork &
KADMIND_PID=$!

echo "==> KDC and kadmind started."

# Wait for any process to exit
wait -n
