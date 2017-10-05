import jenkins.*;
import jenkins.model.*;
import hudson.model.*;

// disabled CLI access over TCP listener (separate port)
def p = AgentProtocol.all()
    p.each { x ->
        if (x.name.contains("CLI")) {
            p.remove(x)
                println("Removed CLI Access");
        }
    }

// disable CLI access over /cli URL
def removal = { lst ->
    lst.each { x -> if (x.getClass().name.contains("CLIAction")) {
        println("Removed CLI Access");

        lst.remove(x) 
    }
    }
}

def j = Jenkins.instance;
    removal(j.getExtensionList(RootAction.class))
removal(j.actions)


    //https://wiki.jenkins-ci.org/display/JENKINS/Slave+To+Master+Access+Control

    def rule = Jenkins.instance.getExtensionList(jenkins.security.s2m.MasterKillSwitchConfiguration.class)[0].rule
    if(!rule.getMasterKillSwitch()) {
        rule.setMasterKillSwitch(true)
            println 'Disabled agent -> master security for cobertura.'
    }
else {
    println 'Nothing changed.  Agent -> master security already disabled.'
}

    Jenkins.instance.getExtensionList(jenkins.security.s2m.MasterKillSwitchWarning.class)[0].disable(true)
Jenkins.instance.save()


