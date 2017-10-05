import jenkins.model.* 
import hudson.security.SecurityRealm
import org.jenkinsci.plugins.GithubSecurityRealm

String gitClientId = System.getenv("GITHUB_APP_CLIENT_ID")?:null;
String gitClientSecret = System.getenv("GITHUB_APP_CLIENT_SECRET")?:null;


if( (gitClientSecret && gitClientId) ){
	String githubWebUri = 'https://github.com'
	String githubApiUri = 'https://api.github.com'
	String oauthScopes = 'read:org'
	SecurityRealm github_realm = new GithubSecurityRealm(githubWebUri, githubApiUri, gitClientId, gitClientSecret, oauthScopes)
	Jenkins.instance.setSecurityRealm(github_realm)
	Jenkins.instance.save()
}else{
	println("No GitHub Auth Details Provided - see README")	
	return;
}

