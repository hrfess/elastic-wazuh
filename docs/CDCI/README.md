# Trivy scan
Push and pull request to main implies a trivy scan on a self-hosted runner on every used docker image.
The github actions' job would fail on high/ critical vulnerability.
However, you can make it end with success if the vulnerabilities are with no impact. This can be done by setting the value of the repo's configuration variable `ACCEPT_RISK_TRIVY` to true. To do it:
- Go to repo's settings
- Secrets and variables -> Actions
- Select Variables section
# Yamllint scan
As errors in yaml files can be harmless (trailing spaces for example).
There is a repo-level configuration variables to ommit that such errors break the pipeline.
