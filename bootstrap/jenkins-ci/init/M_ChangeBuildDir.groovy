println("-------> Point Build and Workspace at Host Disk instead of EFS")
import hudson.Util;
import jenkins.model.Jenkins;
import java.io.File;
import java.io.IOException;

String storedConfig = Util.loadFile(new File(Jenkins.getInstance().getRootDir(),"config.xml"));

