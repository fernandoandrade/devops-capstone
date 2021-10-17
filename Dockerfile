# Pull base image 
FROM tomcat:9-jre9

# Maintainer 
MAINTAINER "nandocandrade80@gmail.com"

# Copy artifacet from the Jenkins target folder into the directory of the tomcat docker conatiner.
COPY ./target/*.war /usr/local/tomcat/webapps/bsafe.war
