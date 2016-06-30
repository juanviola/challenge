FROM tactivos/devops-challenge:0.0.1
ADD health-check.sh /tmp/health-check.sh 
ADD starter.sh /tmp/starter.sh
RUN /bin/chmod 755 /tmp/health-check.sh
RUN /bin/chmod 755 /tmp/starter.sh
CMD ["/bin/bash", "/tmp/starter.sh"]
