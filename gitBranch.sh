#!/bin/bash
. /var/tmp/variable.properties 
export http_proxy=http://600877:Bh%40rath0008@proxy.cognizant.com:6050;
export https_proxy=https://600877:Bh%40rath0008@proxy.cognizant.com:6050;

if [ $1 == "branchCreation" ]
then
	
	SHA_ID=`curl -s  https://api.github.com/repos/Rajeshkumar90/jpetStore/commits/master | grep sha | head -1 | awk -F":" '{print $2}'| sed -e 's/"//g' -e 's/,//g' -e 's/,//g' -e 's/ //g'`;
	curl -X POST -u "Rajeshkumar90:79d7b6002ccca84a36728087a789f043f4ef895e" -d "{\\"ref\\": \\"refs/heads/${STORY_ID}_branch\\",\\"sha\\":\\"$SHA_ID\\"}" "https://api.github.com/repos/Rajeshkumar90/jpetStore/git/refs";

elif [ $1 == "build" ]
then
	echo "Maven build execution for the feature branch";
	sudo mvn clean install  -Djacoco.skip=true cobertura:cobertura -Dcobertura.report.format=xml sonar:sonar -Dsonar.junit.reportsPath=target/surefire-reports -Dsonar.host.url=http://10.242.138.71:9000 -Dsonar.projectName=$JOB_NAME -Dsonar.cobertura.reportPath=target/site/cobertura/coverage.xml -Dsonar.login=admin -Dsonar.password=admin;
	
	
elif [ $1 == "mergeApproval" ]	
then
	echo "Creating the pull request for merging the code from "\\${STORY_ID}\\"_branch to master";
	curl -s -X POST -u Rajeshkumar90:79d7b6002ccca84a36728087a789f043f4ef895e -k -d \'{\\"title\\": "Changes for \'\\"${STORY_ID}\\"\' project feature",\\"head\\": \\"\'\\"${STORY_ID}\\"\'_branch\\",\\"base\\": \\"master\\"}\' \\"https://api.github.com/repos/Rajeshkumar90/jpetStore/pulls\\" ;	

else
	echo "No valid argument is provided";
	echo "Accepted arguments are branchCreation/build/mergeApproval";
	exit 1;
fi
