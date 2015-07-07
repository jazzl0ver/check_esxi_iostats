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
- Without device name specified, the script returns counters of the 1st device in the list. This works for Dell servers only (see line 20 in the script).
- No warning/critical alerts supported yet
