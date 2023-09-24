# rmmagent-script
Script for one-line installing and update of tacticalRMM agent

> Now x64, x86, arm64 and armv6 scripts are available but only x64 and i386 tested on Debian 11 and Debian 10 on baremetal, VM (Proxmox) and VPS(OVH)
> Tested on raspberry 2B+ with armv7l (chose armv6 on install)

Script for other platform will be available futher as I adapt script on other platform.
Feel free to adapt script and submit me !

# Usage
Download the script that match your configuration

### Tips

Download script with this url: `https://raw.githubusercontent.com/netvolt/LinuxRMM-Script/main/rmmagent-linux.sh`

### Fix Blank Screen for Ubuntu Workstations (Ubuntu 16+)
Ubuntu uses the wayland display manager instead of the regular x11 server. This causes MeshCentral to show a blank screen when trying to access the remote desktop feature. You can't login, view or control the client. There is a neat fix for this, so don't worry:
```
sudo sed -i '/WaylandEnable/s/^#//g' /etc/gdm3/custom.conf
sudo systemctl restart gdm
```
This will cause your screen to go blank for a second. You will be able to use remote desktop afterwards.
> If you get an error like "file not found", you are probably still using Ubuntu 19 or below. On these machines, the config file will be located on /etc/gdm/custom.conf. Modify the command above accordingly.
Please note that remote desktop features are only installed when you used the workstation agent. You may need to reinstall your mesh agent.

## Install
To install agent launch the script with this arguement:

```bash
./rmmagent-linux.sh install 'System type' 'Mesh agent' 'API URL' 'Client ID' 'Site ID' 'Auth Key' 'Agent Type'
```
The compiling can be quite long, don't panic and wait few minutes... USE THE 'SINGLE QUOTES' IN ALL FIELDS!

The argument are:

2. System type

  Type of system. Can be 'amd64' 'x86' 'arm64' 'armv6'  

3. Mesh agent

  The url given by mesh for installing new agent.
  Go to mesh.fqdn.com > Add agent > Installation Executable Linux / BSD / macOS > **Select the good system type**
  Copy **ONLY** the URL with the quote.
  
4. API URL

  Your api URL for agent communication usually https://api.fqdn.com.
  
5. Client ID

  The ID of the client in wich agent will be added.
  Can be view by hovering the name of the client in the dashboard.
  
6. Site ID

  The ID of the site in wich agent will be added.
  Can be view by hovering the name of the site in the dashboard.
  
7. Auth Key

  Authentification key given by dashboard by going to dashboard > Agents > Install agent (Windows) > Select manual and show
  Copy **ONLY** the key after *--auth*.
  
8. Agent Type

  Can be *server* or *workstation* and define the type of agent.
  
### Example
```bash
./rmmagent-linux.sh install amd64 "https://mesh.fqdn.com/meshagents?id=XXXXX&installflags=X&meshinstall=X" "https://api.fqdn.com" 3 1 "XXXXX" server
```

## Update

Simply launch the script that match your system with *update* as argument.

```bash
./rmmagent-linux.sh update
```

## Uninstall
To uninstall agent launch the script with this arguement:

```bash
./rmmagent-linux.sh uninstall 'Mesh FQDN' 'Mesh ID'
```
Note: Single quotes must be around the Mesh ID for it to uninstall the mesh agent properly

The argument are:

2. Mesh FQDN

  Example of FQDN: mesh.fqdn.com 

3. Mesh ID

  The ID given by mesh for installing new agent.
  Go to mesh.fqdn.com > Add agent > Linux / BSD (Uninstall) > Copy **ONLY** the last value with the single quotes.
  You are looking for a 64 charaters long value of random letter case, numbers, and special characters.

### Example
```bash
./rmmagent-linux.sh uninstall mesh.fqdn.com 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

### WARNING
- You should **only** attempt this if the agent removal feaure on TacticalRMM is not working.
- Running uninstall will **not** remove the connections from the TacticalRMM and MeshCentral Dashboard. You will need to manually remove them. It only forcefully removes the agents from your linux box.
