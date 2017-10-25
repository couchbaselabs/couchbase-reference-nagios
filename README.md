# Couchbase monitoring reference implementation
This project provides a reference implementation for monitoring [Couchbase](https://www.couchbase.com) with [Nagios](https://www.nagios.org/).

Two Docker images are provided: 
* couchbase/nagios: the Nagios server with preconfigured Couchbase host and service templates
* couchbase/nrpe: the Nagios Remote Plugin Execution (NRPE) server with [check_couchbase](https://github.com/couchbase-partners/nagios-plugin-couchbase) and plugins to monitor the OS

## Building the images

To build the Nagios server:
```bash
docker build docker/nagios -t couchbase/nagios
```

To build tne NRPE server:
```bash
docker build docker/nrpe -t couchbase/nrpe
```
## Running the containers
To run the Nagios container:
```bash
docker run --name nagios -v $(pwd)/etc:/opt/nagios/etc/ -p 8080:80 -p 5668:5668 -it couchbase/nagios
```
The Nagios container should run on your monitoring server.

To run the NRPE container:
```bash
docker run --name nrpe -v /:/mnt/ROOT -p 5666:5666 --net=host -it couchbase/nrpe
```
The NRPE container runs on your Couchbase nodes.

## Connecting to Nagios
Open your browser to http://localhost:8080

The default login credentials are: nagiosadmin:nagios

## Configuring Nagios
The repository contains a top level "etc" directory which houses all of the Nagios config files.  The container mounts this directory, allowing the administrator to change Nagios config without rebuilding the image.  The container is configured to reload Nagios every 30 seconds to pick up new configuration.

The Nagios container runs 3 key services:
* [nagios](https://www.nagios.org/): schedules and executes active checks
* [nsca-ng](http://www.nsca-ng.org/): receives passive checks from the check_couchbase script and passes them to Nagios
* [radar](https://exchange.nagios.org/directory/Addons/Passive-Checks/Radar--2D-add-hosts-and-services-automatically/details): scans the Nagios log for unknown host and service errors and dynamically creates host and service entries for them

### Config layout
* etc: contains the main Nagios and NSCA configuration files
* etc/objects/default: the default templates that ship with Nagios
* etc/objects/commands/common.cfg: command definitions
* etc/objects/hosts/couchbase-servers.cfg: host and hostgroup definitions
* etc/objects/services
  * couchbase-common.cfg: active service definitions that apply to all Couchbase nodes
  * couchbase-data.cfg: active service definitions that apply to Couchbase data nodes
  * couchbase-index.cfg: active service definitions that apply to Couchbase index nodes
  * couchbase-query.cfg: active service definitions that apply to Couchbase query nodes
  * couchbase-passive.cfg: a service template that is used for all passive checks
* etc/dynamic: contains the host and service definitions dynamically generated by Radar

### Minimum configuration
There are two required configurations in order to monitor a couchbase host:
1. You must add your Couchbase node(s) to etc/objects/hosts/couchbase-servers.cfg.  Each node should be configured in the following format: 
```
define host{
        use couchbase-server
        hostgroups +couchbase-data,couchbase-query,couchbase-index
        host_name 192.168.61.102
        address 192.168.61.102
}
```
Note that ```hostgroups``` should reflect the configured services on the node

2. The check_couchbase service in etc/objects/services/couchbase-common.cfg should be updated to use your monitoring host's IP address or hostname (change 127.0.0.1):
```
define service{
	use couchbase-service
	service_description check_couchbase.py
	check_command check_nrpe!check_couchbase!127.0.0.1 localhost
}
```

