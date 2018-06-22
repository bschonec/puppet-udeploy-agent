# == Classes: udeploy::agent::install, udeploy::agent::install::with_java
# version 1.0.1
#
# udeploy::agent::install installs uDeploy Agent and it tries to use existing JAVA_HOME
#     for agent installation and running. Agent artifact comes from Puppetmaster fileserver.
#     Works for RedHat, CentOS and Fedora.
#
# udeploy::agent::install::with_java installs uDeploy Agent and Oracle's Java from
#     from artifacts stored in Puppetmaster fileserver. 
#     Works for RedHat, CentOS and Fedora.
#
# === Parameters
#
# udeploy::agent::install:
#  [*ud_artifact_filename*]   - udeploy zip to be installed
#  [*destination_dir*]        - destination directory where uDeploy will be installed
#  [*server_host*]            - uDeploy server hostname
#  [*agent_port*]             - port to which uDeploy agent will connect
#  [*agent_user*]             - user name under uDeploy agent will be running in operation system
#  [*agent_group*]            - group name under uDeploy agent will be running in operation system
#  [*start_service*]          - true if we need uDeploy agent is running as daemon and started
#  [*agent_name*]             - agent name
#
#
# udeploy::agent::install::with_java:
#  [*java_artifact_filename*] - java binary name (JRE or JDK) to be installed (should be rpm.bin from Oracle)
#  [*ud_artifact_filename*]   - udeploy zip to be installed
#  [*destination_dir*]        - destination directory where uDeploy will be installed
#  [*server_host*]            - uDeploy server hostname
#  [*agent_port*]             - port to which uDeploy agent will connect
#  [*agent_user*]             - user name under uDeploy agent will be running in operation system
#  [*agent_group*]            - group name under uDeploy agent will be running in operation system
#  [*start_service*]          - true if we need uDeploy agent is running as daemon and started
#  [*agent_name*]             - agent name
#
# === Variables
#
# === Examples
#
# class { 'udeploy::agent::install::with_java':
#     java_artifact_filename => 'jre-6u37-linux-i586-rpm.bin',
#     ud_artifact_filename => 'udeploy-agent-4.7.2.290425.zip',
#     start_service => true
# }
#
# class { 'udeploy::agent::install':
#     server_host => 'udeploy2.demo.urbancode.com',
#     start_service => true,
#     agent_name => 'my-agent-name'
# }
#  
# === Authors
#
# Author Name <kak@urbancode.com>
#  


class udeploy::agent::install (
    $ud_artifact_filename   = "udeploy-agent-4.7.2.290425.zip",
    $destination_dir        = "/opt",
    $server_host            = "udeploy2.demo.urbancode.com",
    $agent_port             = "7918",
    $agent_user             = "udeploy",
    $agent_group            = "udeploy",
    $start_service          = false,
    $agent_name             = $fqdn,
    ) {

    if ! ($osfamily in ['RedHat']) {
        fail("udeploy::agent::install does not support osfamily $osfamily, it can be used only on RedHat osfamily.")
    }

    $jh = $env_java_home
    if ($jh == "") {
        fail("udeploy::agent::install requires Java(JRE or JDK) and JAVA_HOME for uDeploy installation.")
    }

    class { 'udeploy::agent::install::puppet':
        jh => $jh,
        ud_artifact_filename => $ud_artifact_filename,
        destination_dir => $destination_dir,
        server_host => $server_host,
        agent_port => $agent_port,
        agent_user => $agent_user,
        agent_group => $agent_group,
       start_service => $start_service,
       agent_name => $agent_name
    }
}

class udeploy::agent::install::with_java (
    $java_artifact_filename,
    $ud_artifact_filename   = "udeploy-agent-4.7.2.290425.zip",
    $destination_dir        = "/opt",
    $server_host            = "udeploy2.demo.urbancode.com",
    $agent_port             = "7918",
    $agent_user       	  = "udeploy",
    $agent_group            = "udeploy",
    $start_service          = false,
    $agent_name             = $fqdn,
    ) {

    if ! ($osfamily in ['RedHat']) {
       fail("udeploy::agent::install::with_java does not support osfamily $osfamily, it can be used only on RedHat osfamily.")
    }

    if ! ($java_artifact_filename == "") {
        file { "/opt/java":
            ensure => "directory",
        }
        file { "/opt/java/$java_artifact_filename":
            mode => 0755,
            owner => root,
            group => root,
            source => "puppet:///files/$java_artifact_filename",
            require => File["/opt/java"],
        }
        exec { "install-java":
            command => "bash -c '/opt/java/$java_artifact_filename >/dev/null < <(echo y) >/dev/null < <(echo y)'",
            cwd => "/opt/java",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => File["/opt/java/$java_artifact_filename"],
        }
        $jh = "/usr/java/latest"
    }
    else {
        fail("udeploy::agent::install::with_java requires Java(JRE or JDK) and JAVA_HOME for uDeploy installation.")
    }

    class { 'udeploy::agent::install::puppet':
        jh => $jh,
        ud_artifact_filename => $ud_artifact_filename,
        destination_dir => $destination_dir,
        server_host => $server_host,
        agent_port => $agent_port,
        agent_user => $agent_user,
        agent_group => $agent_group,
        start_service => $start_service,
        agent_name => $agent_name
    }
}

