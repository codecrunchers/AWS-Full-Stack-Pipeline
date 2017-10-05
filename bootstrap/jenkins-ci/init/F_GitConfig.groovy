import jenkins.model.*

//git notifications
def inst = Jenkins.getInstance()
def desc = inst.getDescriptor("hudson.plugins.git.GitSCM")
desc.setGlobalConfigName("Planet9Jenkins")
desc.setGlobalConfigEmail("jenkins@planet9enegry.com")
desc.save()

//Admin Address
def jenkinsLocationConfiguration = JenkinsLocationConfiguration.get()
jenkinsLocationConfiguration.setAdminAddress("Planet9 Jenkins <jenkins@planet9enegry.com>")
jenkinsLocationConfiguration.save()


