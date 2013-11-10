# Salt become available after quantal.
FROM ubuntu:quantal
RUN echo "deb http://www.apache.org/dist/cassandra/debian 11x main" > /etc/apt/sources.list
RUN echo "deb-src http://www.apache.org/dist/cassandra/debian 11x main" >> /etc/apt/sources.list
RUN echo "deb http://free.nchc.org.tw/ubuntu/ quantal main restricted" >> /etc/apt/sources.list
RUN echo "deb-src http://free.nchc.org.tw/ubuntu/ quantal main restricted" >> /etc/apt/sources.list
RUN echo "deb http://free.nchc.org.tw/ubuntu/ quantal universe" >> /etc/apt/sources.list
RUN echo "deb-src http://free.nchc.org.tw/ubuntu/ quantal universe" >> /etc/apt/sources.list
RUN bash -c "gpg --keyserver pgp.mit.edu --recv-keys F758CE318D77295D"
RUN bash -c "gpg --export --armor F758CE318D77295D | apt-key add -"
RUN bash -c "gpg --keyserver pgp.mit.edu --recv-keys 2B5C1B00"
RUN bash -c "gpg --export --armor 2B5C1B00 | apt-key add -"
RUN echo "deb http://www.duinsoft.nl/pkg debs all" >> /etc/apt/sources.list
RUN apt-key adv --keyserver keys.gnupg.net --recv-keys 5CB26B26
RUN apt-get update
RUN apt-get install -y --no-install-recommends update-sun-jre 
RUN apt-get install -y --no-install-recommends cassandra libjna-java

# Salt installer need these.
RUN apt-get install -y --no-install-recommends ca-certificates software-properties-common

# To solve https://github.com/dotcloud/docker/issues/1024
RUN dpkg-divert --local --rename --add /sbin/initctl
RUN ln -s /bin/true /sbin/initctl

# Install Salt from origin to avoid version conflicts between masters and minions.
# DEBUG: pardon me... I can't fix the script not written by me...
#        It will installed perfectly but can't run as it thought in the container.
RUN sh -c "wget -O - http://bootstrap.saltstack.org | sed 's/exit 1/exit 0/g'| sh"
 
# Patch the Xss issue, see: http://stackoverflow.com/questions/11901421/cannot-start-cassandra-db-using-bin-cassandra
RUN bash -c "sed -i 's/$JVM_OPTS -Xss[0-9]\{3\}k/$JVM_OPTS -Xss256k/g' /etc/cassandra/cassandra-env.sh"

# For the JNA
RUN ln -s /usr/share/java/jna.jar /usr/share/cassandra/lib

EXPOSE 7199 7000 7001 9160 9042
#CMD ["/usr/sbin/cassandra", "-f"]
CMD /usr/bin/salt-minion -l debug
