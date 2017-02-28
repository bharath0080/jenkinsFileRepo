#!/usr/bin/env groovy

node ('master'){

    stage 'Feature Branch Creation'
	
	// Getting the project ID from the JIRA API
	load '../workspace@script/propertiesFile'
	sh 'mkdir -p output; cp ../workspace@script/gitBranch.sh output/'
	def JIRA=JIRA_API;
	println(JIRA);
	sh "curl -s $JIRA > /var/tmp/json.out";
	sh '''
        STORY_ID=`cat /var/tmp/json.out | awk -v k="id" '{n=split($0,a,","); for (i=1; i<=n; i++) print a[i]}' |  grep -w id | awk -F: '{print $2}' | sed 's/\"//g' | sort | tail -1`;
        echo "STORY_ID=$STORY_ID" > variable.properties;
       ''' 	

	// Script execution for branch creation in GITHUB
	
	sh 'mv  $WORKSPACE/variable.properties /var/tmp/variable.properties;../workspace@script/gitBranch.sh branchCreation '
	def story_id_file = readFile('/var/tmp/variable.properties');
	String[] str = story_id_file.split('=');
	def STORY_ID=str[1].replaceAll("\\s","");
	def jobname=STORY_ID+"_job_setup"
	def branchName=STORY_ID+"_branch"
	stage 'Feature Branch build job and pull request approval creation'
	
	// Job DSL script for creating job with project ID that was created in JIRA
	
    jobDsl scriptText: '''pipelineJob(\''''+jobname+'''\') {
 	triggers {
            scm \'H/5 * * * *\' 
			}
    definition {
    cps {
    script(\'\'\'
		node(\'HANOVER_docker\') {
			stage \'Build for feature branch\'
			git poll: true, url: \''''+GITHUB_URL+'''\', branch: \''''+branchName+'''\'
			
			// Build and test of feature branch code 
			sh "sudo mvn clean install  -Djacoco.skip=true cobertura:cobertura -Dcobertura.report.format=xml sonar:sonar -Dsonar.junit.reportsPath=target/surefire-reports -Dsonar.host.url=${SONAR_URL} -Dsonar.projectName=$JOB_NAME -Dsonar.cobertura.reportPath=target/site/cobertura/coverage.xml -Dsonar.login=${SONAR_USER} -Dsonar.password=${SONAR_PASS}"
			
		}
	stage \'Pull Request Approval\'
	
	// Approval for pull request creation in GITHUB 
	
	def userInput = input(id: \'UserInput\', message: \'Approval for creation of pull request\', parameters: [[$class: \'TextParameterDefinition\', defaultValue: \'Yes\', description: \'Approval for the pull request creation\', name: \'pullRequestCreation\']])
	if (userInput != "Yes") {
            echo "Development is not yet completed"
	        return
    }
        node(\'master\') {
			unstash "snapshot-warfile"
			sh \'outpu/gitBranch.sh mergeApproval\'
	}
	
	\'\'\'.stripIndent().trim())  
		}
	}
}'''
    
}
