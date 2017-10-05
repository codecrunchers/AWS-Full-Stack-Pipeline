import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.plugins.sonar.model.*
import static hudson.plugins.sonar.utils.SQServerVersions.SQ_5_3_OR_HIGHER;
println("------->Configuring Sonar")
def inst = Jenkins.instance
def SonarGlobalConfiguration sonar_conf = inst.getDescriptor(SonarGlobalConfiguration.class)
def sonar_inst = new SonarInstallation(
	"Sonar",
	"http://pipeline.planet9energy.io/sonar",
	SQ_5_3_OR_HIGHER,
	"",  //Auth Token
	"", // DB URL
	"", //DB login
	"", // DB Pwd
	"", //Mojo V
	"-Dsonar.sourceEncoding=\"UTF-8\"",
	new TriggersConfig(),
	"sonar",
	"sonar",
	""//additionalAnalysisProperties
)
//do we need to add it
def sonar_installations = sonar_conf.getInstallations()
def sonar_inst_exists = false
sonar_installations.each {
	installation = (SonarInstallation) it
	if (sonar_inst.getName() == installation.getName()) {
		sonar_inst_exists = true
		println("Found existing installation: " + installation.getName())
	}
}

if (!sonar_inst_exists) {
	sonar_installations += sonar_inst
	sonar_conf.setInstallations((SonarInstallation[]) sonar_installations)
	sonar_conf.save()
}


