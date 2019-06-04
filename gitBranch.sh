#!/bin/bash
. /var/tmp/variable.properties
export http_proxy=<proxyName>
export https_proxy=<proxyName>

if [ $1 == "branchCreation" ]
then

        SHA_ID=`curl -s  https://api.github.com/repos/Rajeshkumar90/jpetStore/commits/master | grep sha | head -1 | awk -F":" '{print $2}'| sed -e 's/"//g' -e 's/,//g' -e 's/,//g' -e 's/ //g'`;
        curl -X POST -u "Rajeshkumar90:arun00bala@" -d "{\"ref\": \"refs/heads/${STORY_ID}_branch\",\"sha\":\"$SHA_ID\"}" "https://api.github.com/repos/Rajeshkumar90/jpetStore/git/refs"

elif [ $1 == "mergeApproval" ]
then
        echo "Creating the pull request for merging the code from ${STORY_ID}_branch to master";
        curl -X POST -u Rajeshkumar90:arun00bala@ -k -d '{"title": "Changes for '"${STORY_ID}"' project feature","head": "'"${STORY_ID}"'_branch","base": "master"}' "https://api.github.com/repos/Rajeshkumar90/jpetStore/pulls"

else
        echo "No valid argument is provided";
        echo "Accepted arguments are branchCreation/mergeApproval";
        exit 1; 
fi
