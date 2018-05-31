FROM bpatterson/centos7-jdk8:latest

LABEL name="CentOS7 with Apache Tomcat 8"

ENV APACHE_TOMCAT_DOWNLOAD_URL https://www-us.apache.org/dist/tomcat/tomcat-8/v8.5.31/bin/apache-tomcat-8.5.31.tar.gz
ENV APACHE_TOMCAT_INSTALL_DIR /usr/local/apache-tomcat-8.5.31

RUN curl \
	-L \
	-v \
	"${APACHE_TOMCAT_DOWNLOAD_URL}" \
	| tar -xz -C /usr/local

# Modify default config to use well-known paths

RUN cat ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml | \
	sed 's/appBase="webapps"/appBase="\/tomcat\/webapps"/' | \
	sed 's/directory="logs"/directory="\/tomcat\/logs"/' > \
	/tmp/server.xml

RUN cp /tmp/server.xml ${APACHE_TOMCAT_INSTALL_DIR}/conf/server.xml
RUN rm /tmp/server.xml

RUN wget https://bitbucket.org/ariya/phantomjs/downloads/phantomjs-2.1.1-linux-i686.tar.bz2 -P install
RUN tar -jxf install/phantomjs-2.1.1-linux-i686.tar.bz2 -C /opt \
    && ln -s /opt/phantomjs-2.1.1-linux-i686 /opt/phantomjs-2.1.1

# install Chinese font
RUN yum install -y bitmap-fonts bitmap-fonts-cjk

# phantomjs requirements
RUN yum install -y glibc.i686 zlib.i686 fontconfig freetype freetype-devel fontconfig-devel libstdc++ libfreetype.so.6 libfontconfig.so.1 libstdc++.so.6

RUN mkdir -p /tomcat/webapps/
RUN mkdir -p /tomcat/logs/

COPY entrypoint.sh /

EXPOSE 8080 8009
VOLUME ["/tomcat/webapps", "/tomcat/logs"]
CMD ["/entrypoint.sh"]
