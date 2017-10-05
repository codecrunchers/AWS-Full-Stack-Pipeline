# Jenkins Build Server

[https://jenkins.io/solutions/pipeline/

## To Build and Run that image
* `docker build -t planet9/jenkins .` or `docker build --no-cache -t planet9/jenkins .`

* Build lightweight devel image   `docker build  -t planet9/jenkins --file ./DockerfileLite .`


* `docker run -d 
	--env GIT_REPO=git@github.com:Plnt9/poormans-pipeline.git 
	--env GITHUB_APP_CLIENT_ID=<git client id> 
	--env GITHUB_APP_CLIENT_SECRET=<git app secret>
	-p 18080:8080 planet9/jenkins`

## To Pull from P9 ECR (Docker Reg)
eval $(aws --profile="<YP>" ecr get-login --region eu-west-1) (YP = Your AWS Profile)
docker pull 492333042402.dkr.ecr.eu-west-1.amazonaws.com/pipeline/jenkins:latest
docker run -d --env GIT_REPO=git@github.com:Plnt9/standing-data-api.git 
	--env GIT_REPO=git@github.com:Plnt9/poormans-pipeline.git 
	--env GITHUB_APP_CLIENT_ID=<git client id>
	--end GITHUB_APP_CLIENT_SECRET=<git app secret>
	-p 18080:8080 
	 <account>.dkr.ecr.eu-west-1.amazonaws.com/pipeline/jenkins:latest

## To Test
### Linux
Install python etc locally - or use a docker image to not pollute your local env
* `apt install -y python3-pip && /usr/bin/pip3 install --upgrade pip && /usr/bin/pip3 install pytest`
* `python3 -m pytest spec`

Leave GITHUB_APP_CLIENT_ID && GITHUB_APP_CLIENT_SECRET blank for local access, using admin/admin
 

## Access 
* Ask Alan - for now
* GitHub Auth

# Env Vars
# Repo to Listen to and Build
* GIT_REPO, e.g. git@github.com:Plnt9/poormans-pipeline.git
## Auth
GITHUB_APP_CLIENT_ID
GITHUB_APP_CLIENT_SECRET
*
*
*
 



