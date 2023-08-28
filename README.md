# Home assignment 

The playbook installs and Nginx on the host, then creates and copies the necessary files in order to create the monitoring solution.

# Script

Monitor_resources.sh runs as a service acting as following: 
    A new line added to the log file when one or more of the following occures:
    a. CPU reaches 90% utilization
    b. RAM reaches 90% utilization
    c. The webpage (Ngninx default) is unreachable on localhost
    d. The webpage is unreachable via Elastic IP (public)
    e. State of the alert triggered goes back to the normal

In order to act as a monitoring tool, the check is triggered once a second.

*The public IP, used for an external curl request is passed as an environment variable in order to keep it in secret.

# Playbook

In order to keep the Elastic IP in secret, no line is added in inventory and the initial command is performed with the plain address, which is additionally kept in Vault-encrypted secrets.yml
Additionally, stress CLI tool is installed on the host in order to perform stress tests which trigger the loggable activity.