import hudson.model.FreeStyleProject;
import hudson.plugins.git.GitSCM;
import hudson.plugins.git.BranchSpec;
import hudson.triggers.SCMTrigger;
import hudson.util.Secret;
import javaposse.jobdsl.plugin.*;
import jenkins.model.JenkinsLocationConfiguration;
import com.cloudbees.plugins.credentials.domains.Domain;
import jenkins.model.JenkinsLocationConfiguration;

import org.jenkinsci.plugins.workflow.job.WorkflowJob;
import org.jenkinsci.plugins.workflow.cps.CpsScmFlowDefinition;
import jenkins.model.*
import hudson.model.AbstractProject

def giturl = System.getenv("GIT_REPO");
if(giturl == ""){
	println("--------------------------->>> You Must Set a Repo to Build");
	println("--------------------------->>> e.g. --env GIT_REPO=git@github.com:Plnt9/poormans-pipeline.git");
}

def jobName = giturl.split("/")[giturl.split("/").length - 1] - ".git"
def jenkins = Jenkins.instance;

if(!jenkins.getAllItems().collect{it.fullName}.contains(jobName)){
	println("--->Creating Project")
	def scm = new GitSCM(giturl);
	scm.branches = [new BranchSpec("*/master")];
	def workflowJob = new WorkflowJob(jenkins, jobName);
	gitTrigger = new SCMTrigger(" "); //empty, workaround for push over poll model
	workflowJob.addTrigger(gitTrigger);
	workflowJob.definition = new CpsScmFlowDefinition(scm, "Jenkinsfile");
	workflowJob.definition.scm.userRemoteConfigs[0].credentialsId = 'git'
	workflowJob.setConcurrentBuild(false);
	workflowJob.save();
	jenkins.add(workflowJob, workflowJob.name);
	println("---> Adding SSH Key for Project");
	def job = Jenkins.instance.getAllItems().collect{it.fullName == jobName ? it:null}
	job = job[0];	
	job.definition.scm.userRemoteConfigs[0].credentialsId = 'git';
	job.save();
}else {
	println("---> Adding SSH Key for Project");
	def job = Jenkins.instance.getAllItems().collect{it.fullName == jobName ? it:null}
	job = job[0];	
	if(job.definition.scm.userRemoteConfigs[0].credentialsId == 'git') {
		return;
	}
	job.definition.scm.userRemoteConfigs[0].credentialsId = 'git';
	job.save();
}
