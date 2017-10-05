import jenkins.model.*
import hudson.plugins.sonar.*
import hudson.tools.*

println("------->Configuring Sonar Runner")

def inst = Jenkins.getInstance()
def desc = inst.getDescriptor("hudson.plugins.sonar.SonarRunnerInstallation")
def installer = new SonarRunnerInstaller("3.0.3.778")
def prop = new InstallSourceProperty([installer])
def sinst = new SonarRunnerInstallation("default-sonar", "", [prop])
desc.setInstallations(sinst)
desc.save()


