<#############
    This was really difficult to figure out, 
    but here's a snippet that will allow you to modify DCOM ACLs.
    Easily modified to touch other properties in DCOM ACL-land.
#############>

# get the Object based on the AppId. This example AppID belongs to the Linux Subsystem DCOM object
$wmi = (Get-WmiObject -Class Win32_DCOMApplicationSetting -Filter "AppId='{e82567ae-2ea4-4dbc-bc68-8b0a0526d8d5}'" -EnableAllPrivileges)

# get the Launch Descriptor object and store
$descL = $wmi.GetLaunchSecurityDescriptor().descriptor

# create a special object to hold trustee related information. set trustee we want to apply as the default "Administrators" group
$trusteeObj = ([wmiclass]'Win32_Trustee').psbase.CreateInstance()
$trusteeObj.Domain = "BUILTIN"
$trusteeObj.Name = "Administrators"

# create a special object to store ACL stuffs
$ace = ([wmiclass]'Win32_ACE').psbase.CreateInstance()

# set the access mask we desire (Launch & Local Activation allowed).
$ace.AccessMask = 11

# Set Trustee to what we created earlier then _append_ this to the existing ACL configuration.
$ace.Trustee = $trusteeObj
$descL.DACL += [System.Management.ManagementBaseObject]$ace

# finally, use the SetLaunchSecurityDescriptor method to set all the stuff we created and appended in stone
$wmi.SetLaunchSecurityDescriptor($descL)