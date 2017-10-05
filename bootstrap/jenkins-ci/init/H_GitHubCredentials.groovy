import jenkins.model.*
import com.cloudbees.plugins.credentials.*
import com.cloudbees.plugins.credentials.common.*
import com.cloudbees.plugins.credentials.domains.*
import com.cloudbees.jenkins.plugins.sshcredentials.impl.*
import hudson.plugins.sshslaves.*;

def global_domain = Domain.global();

def credentials_store = Jenkins.instance.getExtensionList(
		'com.cloudbees.plugins.credentials.SystemCredentialsProvider'
		)[0].getStore();

if(credentials_store.getCredentials().size() == 0){
	println("-->Adding ssh keys from ~/.ssh")

	def credentials = new BasicSSHUserPrivateKey(
			CredentialsScope.GLOBAL,
			"git",
			"git",
			new BasicSSHUserPrivateKey.UsersPrivateKeySource(),
			"",
			"Key for Accessing GitHub"
			);


	credentials_store.addCredentials(global_domain, credentials)
}
