# rmmagent-script
Script for one-line installation and updating of the tacticalRMM agent

We dont provide technical support for this. If you need help, check the tactical RMM community first!

> Scripts are now available for x64, x86, arm64, and armv6. However, only x64 and i386 have been tested on Debian 11 and Debian 10 on bare metal, VMs (Proxmox), and VPS (OVH).
> Tested on raspberry 2B+ with armv7l (chose armv6 on install)

Scripts for other platforms will be available later as we adapt the script to other platforms.
Feel free to adapt the script and submit changes that will contribute!

# Usage

### Tips

Download script with this url: `https://raw.githubusercontent.com/netvolt/LinuxRMM-Script/main/rmmagent-linux.sh`

For Ubuntu systems try: 'wget https://raw.githubusercontent.com/netvolt/LinuxRMM-Script/main/rmmagent-linux.sh'
Make executable after downloading with: 'sudo chmod +x rmmagent-linux.sh'  

### Fix Blank Screen for Ubuntu Workstations (Ubuntu 16+)
Ubuntu uses the Wayland display manager instead of the regular X11 server. This causes MeshCentral to show a blank screen, preventing login, viewing, or controlling the client.
Using the command lines below should solve the problem:
```
sudo sed -i '/WaylandEnable/s/^#//g' /etc/gdm3/custom.conf
sudo systemctl restart gdm
```
This will cause your screen to go blank for a second. You will be able to use remote desktop afterwards.
> If you encounter a 'file not found' error, you are likely using Ubuntu 19 or earlier. On these machines, the config file will be located on /etc/gdm/custom.conf. Modify the command above accordingly. <
Please note that remote desktop features are only installed when you used the workstation agent. You may need to reinstall your mesh agent.

## Install
To install the agent, launch the script with this argument:

```bash
./rmmagent-linux.sh install 'System type' 'Mesh agent' 'API URL' 'Client ID' 'Site ID' 'Auth Key' 'Agent Type'
```
The compiling can be quite long, don't panic and wait few minutes... USE THE 'SINGLE QUOTES' IN ALL FIELDS!

The arguments are:

2. System type

  Type of system. Can be 'amd64' 'x86' 'arm64' 'armv6'  

3. Mesh agent

  The url given by mesh for installing new agent.
  Go to mesh.example.com > Add agent > Installation Executable Linux / BSD / macOS > **Select the good system type**
  Copy **ONLY** the URL with the quote.
  
4. API URL

  Your api URL for agent communication usually https://api.example.com.
  
5. Client ID

  The ID of the client in wich agent will be added.
  Can be viewed by hovering over the name of the client in the dashboard.
  
6. Site ID

  The ID of the site in wich agent will be added.
  Can be viewed by hovering over the name of the site in the dashboard.
  
7. Auth Key

  Authentification key given by dashboard by going to dashboard > Agents > Install agent (Windows) > Select manual and show
  Copy **ONLY** the key after *--auth*.
  
8. Agent Type

  Can be *server* or *workstation* and define the type of agent.
  
### Example
```bash
./rmmagent-linux.sh install 'amd64' 'https://mesh.example.com/meshagents?id=XXXXX&installflags=X&meshinstall=X' 'https://api.example.com' 3 1 'XXXXX' server
```

## Update

Simply launch the script with *update* as argument.

```bash
./rmmagent-linux.sh update
```

## Uninstall
To uninstall the agent, launch the script with this argument:

```bash
./rmmagent-linux.sh uninstall 'Mesh FQDN' 'Mesh ID'
```
Note: Single quotes must be around the Mesh ID for it to uninstall the mesh agent properly

The argument are:

2. Mesh FQDN

  Example of FQDN: mesh.example.com 

3. Mesh ID

  The ID given by mesh for installing new agent.

  Go to mesh.example.com > Add agent > Linux / BSD (Uninstall) > Copy **ONLY** the last value with the single quotes.
  You are looking for a 64 charaters long value of random letter case, numbers, and special characters.

### Example
```bash
./rmmagent-linux.sh uninstall mesh.example.com 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX'
```

### WARNING
- You should **only** attempt this if the agent removal feature on TacticalRMM is not working.
- Running uninstall will **not** remove the connections from the TacticalRMM and MeshCentral Dashboard. You will need to manually remove them. It only forcefully removes the agents from your linux box.
