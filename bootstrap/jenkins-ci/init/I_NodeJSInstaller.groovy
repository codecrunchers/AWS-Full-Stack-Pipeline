import jenkins.model.*
import hudson.model.*
import jenkins.plugins.nodejs.tools.*
import hudson.tools.*

def inst = Jenkins.getInstance();
def desc = inst.getDescriptor("jenkins.plugins.nodejs.tools.NodeJSInstallation");

println("------> NodeJS Desc ${desc}")
def installations = []
def versions = [
	"node-default": "6.10.0",
	"nodejs-6.x": "6.10.3",
	"nodejs-8.4": "8.4.0",
]

try {
	for (v in versions) {
		def installer = new NodeJSInstaller(v.value, "yarn@~0.275 npm", 100L);

		def installerProps = new InstallSourceProperty([installer]);
		def installation = new NodeJSInstallation(v.key, "" , [installerProps]);
		installations.push(installation);
	}
	desc.setInstallations(installations.toArray(new NodeJSInstallation[0]))
	desc.save() 
}catch(e){
	println("---->");
	println("Error: ${e}");
	println("---->");

}
