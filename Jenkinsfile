import groovy.json.JsonSlurper;
import java.util.*;
import java.io.*;
node ('master'){

    stage 'Feature Branch Creation'
	
	// Getting the project ID from the JIRA API
	load 'propertiesFile'
	sh 'curl -s  $JIRA_API > /var/tmp/json.out'
	def inputFile = new File("/var/tmp/json.out");
	def InputJSON = new  groovy.json.JsonSlurper().parseText(inputFile.text);
	def b = InputJSON.id ;
	println(b);
	Collections.sort(b);
	def STORY_ID=b.last();
	writeFile file: "variable.properties", text: "STORY_ID=$STORY_ID";
	
	// Script execution for branch creation in GITHUB
	
	sh 'cp  $WORKSPACE/variable.properties /var/tmp/variable.properties;$WORKSPACE/gitBranch.sh branchCreation '
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
			
			sh \'$WORKSPACE/gitBranch.sh build \'
			
		}
	stage \'Pull Request Approval\'
	
	// Approval for pull request creation in GITHUB 
	
	def userInput = input(id: \'UserInput\', message: \'Approval for creation of pull request\', parameters: [[$class: \'TextParameterDefinition\', defaultValue: \'Yes\', description: \'Approval for the pull request creation\', name: \'pullRequestCreation\']])
	if (userInput != "Yes") {
            echo "Development is not yet completed"
	        return
    }
        node(\'master\') {
			sh \'$WORKSPACE/gitBranch.sh mergeApproval\'
	}
	
	\'\'\'.stripIndent().trim())  
		}
	}
}'''
    
}
