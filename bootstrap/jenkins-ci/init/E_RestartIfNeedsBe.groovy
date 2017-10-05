import jenkins.model.* 
import hudson.model.RestartListener
import java.util.logging.Level
import java.io.File 

import java.util.logging.Logger

def JENKINS_HOME = System.getenv("JENKINS_HOME");


def firstRunFile = new File("${JENKINS_HOME}/FIRSTRUN.txt" as String);

if(firstRunFile.exists()){
  println("Restarting - FR Found")
	doManagedRestart();
	firstRunFile.delete();
}

void doManagedRestart(){  

	Logger logger = Logger.getLogger('jenkins.instance.restart')
	//start a background thread
	def thread = Thread.start {
		logger.log(Level.INFO, "Jenkins safe restart initiated.")
		while(true) {
			if(Jenkins.instance.isQuietingDown()) {
				if(RestartListener.isAllReady()) {
					println "A safe restart has been requested.  See the Jenkins logs for restart status updates."
					Jenkins.instance.restart();
				}
				logger.log(Level.INFO, "Jenkins jobs are not idle.  Waiting 20 seconds before next restart attempt.")
				sleep(20*1000)
			}
			else {
				logger.log(Level.INFO, "Shutdown mode not enabled.  Jenkins restart aborted.")
				break
			}
		}
	}

}


