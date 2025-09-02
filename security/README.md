## /nginx/entrypoint.sh
This is the entrypoint of the reverse-proxy docker image. Configurable via ../configs/nginx/.env.
Where we can specify if this is a first deployment, the hostname of the dashboard cluster and address email of the maintainer. 

### First deployment
Set FIRST_RUN to true if it is a first deployment. The script shall user certbot utility to authenticate with letsencrypt and grab importantly the public and private ssl keys.
The FQDN under CERTBOT_DOMAINS should resolve to the host where the cluster is running.

### SSL renewal
On whatever case the script would schedule cron jobs that make:
    - The nginx server reloads let's encrypt's certs.
    - The certbot checks and renew the certs.

## Architecture
The reverse proxy terminates HTTPS endpoints of the dashboard cluster, and stream endpoints of the manager cluster.
Wazuh agents -> wazuh manager communication is already secure.
SSL certs for the upstream are generated with : wazuh/wazuh-certs-generator:0.0.2 

## Trust chain
The repo is private (to do: permissions), only me at this time.
Git operations (e.g. push) can be performed via ssh, which requires an ssl key.
The self-hosted runner was joined using a private token.
All secrets are in the private repo in an encrypted form.
Only the holder of the pgp private key, which SOPS bound to, is able to decrypt the secrets.
Though encrypted, the ssl keys are subject to renewal after a resonable term.

## File access
As the reverse proxy runs a crontab for certbot (cert renewal routine). The folder holding priv/public keys and its content (/configs/nginx/letsencrypt inside the NFS share) is writable by everyone until the user:group of certbot is determind. 

## Secure CD/CI
To avoid pushing sensitive files such as credentials of wazuh application and cryptographic key. Please proceed as follows:
- Ask the administrator to give you the gpg folder `.gnupg` and place under your home directory.
- Add the following script to `.git/hooks/pre-commit`:
```
#!/bin/bash
#
# Git pre-push hook to encrypt sensitive files with SOPS
# Encrypts all *.pem and *secrets.env files in the repo before push
#


PGP_FG="385DF571928CE05D50CF1D115B612ED48CD7EEBB"

# Find target files (only tracked ones to avoid encrypting junk)
FILES=$(git ls-files | grep -E '(\.pem$|secrets\.env$)')

if [[ -z "$FILES" ]]; then
  echo "[pre-push] No .pem or secrets.env files found. Skipping SOPS encryption."
  exit 0
fi

echo "[pre-push] Encrypting sensitive files with SOPS..."

for f in $FILES; do
  if [[ -f "$f" ]]; then
    if grep -q '"sops": {' "$f" || grep -q '^sops:' "$f"; then
      echo "  → Skipping $f (already encrypted)"
    else
      echo "  → Encrypting $f"
      sops --encrypt --pgp "$PGP_FG" --in-place "$f"
      git add "$f"
    fi
  fi
done
echo "[pre-push] All sensitive files encrypted and staged."
exit 0

```
