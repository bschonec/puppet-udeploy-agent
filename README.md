# uDeploy agent module for Puppet

This module manages a uDeploy agent.  uDeploy agents are needed on uDeploy target boxes.

## Description

The uDeploy installation requires Java 1.6.

## Usage

### udeploy::agent::install
Installs the uDeploy agent.

    class { 'udeploy::agent::install': }

### udeploy::agent::install::with_java
Installs a JDK and the uDeploy agent.  Here is the minimum set of information that needs to be specified:

    class { 'udeploy::agent::install':
        jdk_artifact_filename: ""
    }

### Parameters

udeploy::agent::install:
  [*ud_artifact_filename*]   - udeploy zip to be installed
  [*destination_dir*]        - destination directory where uDeploy will be installed
  [*server_host*]            - uDeploy server hostname
  [*agent_port*]             - port to which uDeploy agent will connect
  [*agent_user*]             - user name under uDeploy agent will be running in operation system
  [*agent_group*]            - group name under uDeploy agent will be running in operation system
  [*start_service*]          - true if we need uDeploy agent is running as daemon and started
  [*agent_name*]             - agent name

udeploy::agent::install::with_java:
  [*java_artifact_filename*] - java binary name (JRE or JDK) to be installed (should be rpm.bin from Oracle)
  [*ud_artifact_filename*]   - udeploy zip to be installed
  [*destination_dir*]        - destination directory where uDeploy will be installed
  [*server_host*]            - uDeploy server hostname
  [*agent_port*]             - port to which uDeploy agent will connect
  [*agent_user*]             - user name under uDeploy agent will be running in operation system
  [*agent_group*]            - group name under uDeploy agent will be running in operation system
  [*start_service*]          - true if we need uDeploy agent is running as daemon and started
  [*agent_name*]             - agent name

#### Other examples

    class { 'udeploy::agent::install::with_java':
        java_artifact_filename => 'jre-6u37-linux-i586-rpm.bin',
        ud_artifact_filename => 'udeploy-agent-4.7.2.290425.zip',
        start_service => true
    }

    class { 'udeploy::agent::install':
        server_host => 'udeploy2.demo.urbancode.com',
        start_service => true,
        agent_name => 'my-agent-name'
    }
