class udeploy::agent::install::puppet (
  $jh,
  $ud_artifact_filename,
  $destination_dir,
  $server_host,
  $agent_port,
  $agent_user,
  $agent_group,
  $start_service,
  $agent_name,
  ) {
    if ! ($osfamily in ['RedHat']) {
        fail("udeploy::agent::install::puppet does not support osfamily $osfamily, it can be used only on RedHat osfamily.")
    }

    if ($jh == "") {
        fail("udeploy::agent::install::puppet requires Java(JRE or JDK) and JAVA_HOME for uDeploy installation.")
    }

    file { "$destination_dir/$ud_artifact_filename":
        owner => 'root',
        group => 'root',
        mode => 0644,
        source => "puppet:///files/$ud_artifact_filename",
    }

    exec { "unzip-udeploy-agent":
        command => "unzip $destination_dir/$ud_artifact_filename",
        cwd => "$destination_dir",
        path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
        require => File["$destination_dir/$ud_artifact_filename"],
        onlyif => "test ! -d $destination_dir/udeploy-agent-install",
    }

    file { "agent.install.properties":
        path    => "$destination_dir/udeploy-agent-install/agent.install.properties",
        owner   => root,
        group   => root,
        mode    => 644,
        require => Exec["unzip-udeploy-agent"],
        content => template("udeploy/agent.install.properties.erb"),
    }

    exec { "install-udeploy-agent":
        command => "bash -c 'JAVA_HOME=$jh; $destination_dir/udeploy-agent-install/install-agent-from-file.sh agent.install.properties'",
        cwd => "$destination_dir/udeploy-agent-install",
        path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
        require => File["agent.install.properties"],
        onlyif => "test ! -d $destination_dir/urbancode/udagent",
    }

    if ($start_service) {
        group { $agent_group:
            ensure => "present",
            require => Exec["install-udeploy-agent"]
        }

        user { $agent_user:
            ensure => "present",
            gid => $agent_group,
            managehome => true,
            shell => "/bin/bash",
            require => Group[$agent_group]
        }

        exec { "change-udeployagent-ownership":
            command => "chown -R $agent_user /$destination_dir/urbancode",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => User[$agent_user]
        }

        exec { "copy-init-script":
            command => "cp $destination_dir/urbancode/udagent/bin/init/udagent /etc/init.d/",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => Exec["change-udeployagent-ownership"]
        }

        exec { "tokenize-init-script":
            command => "sed \"s/AGENT_USER=/AGENT_USER=$agent_user/\" -i /etc/init.d/udagent; sed \"s/AGENT_GROUP=/AGENT_GROUP=$agent_group/\" -i /etc/init.d/udagent",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => Exec["copy-init-script"]
        }

        exec { "add-init-script":
            command => "chkconfig --add udagent",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => Exec["tokenize-init-script"]
        }

        exec { "turn-on-init-script":
            command => "chkconfig udagent on",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => Exec["add-init-script"]
        }

        exec { "start-udeployagent-service":
            command => "/etc/init.d/udagent start",
            cwd => "/etc/init.d",
            path => ["/bin", "/sbin", "/usr/bin", "/usr/sbin"],
            require => Exec["turn-on-init-script"]
        }
    }
}

