echo "****** Tomcat Startup ******"
export PATH="$PATH:/opt/confd/bin"
export AWS_REGION="ap-southeast-2"
confd -onetime -backend=ssm --prefix /dev -node "https://ssm.ap-southeast-2.amazonaws.com"