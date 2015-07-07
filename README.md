# check_esxi_lun_iostats
Nagios check for pulling per LUN esxtop counters from VMWare ESXi host

Requirements
============
- VMware-vSphere-CLI
- VMWare vCenter
- 
Usage
=====
- Put the script along with the esxtop.conf file in the Nagios plugins folder
- Change VCHOST to the correct vCenter server ip address inside the script
- Put the correct username and password in USER and PASS variables inside the script. The user must be an existing vCenter user with a role having Global/Service managers permission assigned
- Define Nagios check command:
~~~
define command{
        command_name                    check_esxi_lun_iostats
        command_line                    $USER1$/check_esxi_lun_iostats.sh $HOSTADDRESS$ $ARG1$
}
~~~
- Define Nagios service (replace the argument to the correct device name):
~~~
define service{
        hostgroup_name                  ESXi
        service_description             ESXi IO stats
        _SERVICE_ID                     273
        use                             generic-service
        check_command                   check_esxi_lun_iostats!"naa.89019b90c32f1b3212a6dcded7c1a8e8"
        retry_check_interval            3
        notification_options            u,c,r
}
~~~
- Reload Nagios configs
- 
Notes
=====
- The device name can be looked up in the vSphere Client on Configuration/Storage Adapters/Details page on the Devices tab in the Name column inside the parenthesis
- Without device name specified, the script returns counters of the 1st local device in the list. This works for Dell servers only (see line 20 in the script).
- No warning/critical alerts supported yet
- Modify FIELDS variable inside the script for adding/removing device counters
- Check https://communities.vmware.com/docs/DOC-9279 for the counters description
 
List of available per LUN counters
==================================
~~~
Device Q Depth
World Q Depth
Active Commands
Queued Commands
% Used
Load
Commands/sec
Reads/sec
Writes/sec
MBytes Read/sec
MBytes Written/sec
Average Driver MilliSec/Command
Average Kernel MilliSec/Command
Average Guest MilliSec/Command
Average Queue MilliSec/Command
Average Driver MilliSec/Read
Average Kernel MilliSec/Read
Average Guest MilliSec/Read
Average Queue MilliSec/Read
Average Driver MilliSec/Write
Average Kernel MilliSec/Write
Average Guest MilliSec/Write
Average Queue MilliSec/Write
Failed Commands/sec
Failed Reads/sec
Failed Writes/sec
Failed Bytes Read/sec
Failed Bytes Written/sec
Failed Reserves/sec
Aborts/sec
Resets/sec
~~~
