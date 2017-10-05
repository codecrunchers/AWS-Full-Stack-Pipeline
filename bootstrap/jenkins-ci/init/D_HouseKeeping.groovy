import jenkins.model.*
import jenkins.model.JenkinsLocationConfiguration;
//set url for this instance
configuration = JenkinsLocationConfiguration.get();
configuration.setUrl(System.getenv("JENKINS_URL"));
configuration.save();





