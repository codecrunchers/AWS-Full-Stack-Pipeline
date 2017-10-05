import jenkins.model.*
import java.util.logging.Level
import java.util.logging.Logger

def instance = Jenkins.getInstance();
def pm = instance.getPluginManager();
def uc =instance.getUpdateCenter();
def updateCount=0

try {
	if(!Jenkins.instance.isQuietingDown()) {

		uc.updateAllSites()
		uc.getUpdates().each { plugin->
			println("--->Updating " + plugin.name + "@" + plugin.version)
			plugin.deploy() 
			updateCount++
		}

		if(updateCount>0){
			println("---RELOAD REQD---->> Reload Due to Plugin Updates  " + updateCount + " plugins, scheduling restart----")
        	Jenkins.instance.doQuietDown();
		}
	}
}
catch(e){
	println("!!!!!!!!!!  !!!!!!   !!! Error ! - ${e}")
    return -1;
}


