# Custom images
There is only one custom image inside /docker. This image implements a reverse proxy that generates and handles renwal of let's encrypt certs.
# Stack 
At this release there is only one replica per task. Edit the deploy block according to your needs.
The following restart policy would be added in the next release:
```
update_config:
        parallelism: 1                  # update one task at a time
        delay: 10s                      # wait between updates
        order: start-first              # start new before stopping old
        monitor: 30s                    # time to monitor before considering update successful
        failure_action: rollback        # automatic rollback if update fails
        max_failure_ratio: 0.2          # threshold for acceptable failures
```
# Data, Configs and Security
/configs and /security automatically get cloned to an NFS share by ansible. Containers on a distributed stack can consume their configs and secrets.
Volumes defined on the stack are based on mounted points of NFS share. This allows for a persistent and shared access to realtime data. Again the procees of arranging to such setup is automated via ansible.

