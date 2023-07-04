#!/bin/bash
check_zip=$(which unzip 2> /dev/null)
if [[ $check_zip == "" || $check_zip =~ .*"no unzip".* ]]; then
        echo "unzip could not be found. Please install unzip."
        exit 0
fi

if [[ $1 == "" ]]; then
        echo "First argument is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "help" ]]; then
        echo "There is help but more information is available at github.com/ZoLuSs/rmmagent-script"
        echo ""
        echo "List of INSTALL argument (no argument name):"
        echo "Arg 1: 'install'"
        echo "Arg 2: System type 'amd64' 'x86' 'arm64' 'armv6'"
        echo "Arg 3: Mesh agent URL"
        echo "Arg 4: API URL"
        echo "Arg 5: Client ID"
        echo "Arg 6: Site ID"
        echo "Arg 7: Auth Key"
        echo "Arg 8: Agent Type 'server' or 'workstation'"
        echo ""
        echo "List of UPDATE argument (no argument name)"
        echo "Arg 1: 'update'"
        echo "Arg 2: System type 'amd64' 'x86' 'arm64' 'armv6'"
        echo ""
        echo "List of UNINSTALL argument (no argument name):"
        echo "Arg 1: 'uninstall'"
        echo "Arg 2: Mesh agent FQDN (i.e. mesh.domain.com)"
        echo "Arg 3: Mesh agent id (The id needs to have single quotes around it)"
        echo ""
        exit 0
fi

if [[ $1 != "install" && $1 != "update" && $1 != "uninstall" ]]; then
        echo "First argument can only be 'install' or 'update' or 'uninstall' !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $2 == "" ]]; then
        echo "Argument 2 (System type) is empty !"
        echo "Type help for more information"
        exit 1
fi


if [[ $1 == "update" && $2 == "" ]]; then
        echo "Argument 2 (System type) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $2 != "amd64" && $2 != "x86" && $2 != "arm64" && $2 != "armv6" ]]; then
        echo "This argument can only be 'amd64' 'x86' 'arm64' 'armv6' !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $3 == "" ]]; then
        echo "Argument 3 (Mesh agent URL) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $4 == "" ]]; then
        echo "Argument 4 (API URL) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $5 == "" ]]; then
        echo "Argument 5 (Client ID) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $6 == "" ]]; then
        echo "Argument 6 (Site ID) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $7 == "" ]]; then
        echo "Argument 7 (Auth Key) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $8 == "" ]]; then
        echo "Argument 8 (Agent Type) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "install" && $8 != "server" && $8 != "workstation" ]]; then
        echo "First argument can only be 'server' or 'workstation' !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "uninstall" && $2 == "" ]]; then
        echo "Argument 2 (Mesh agent FQDN) is empty !"
        echo "Type help for more information"
        exit 1
fi

if [[ $1 == "uninstall" && $3 == "" ]]; then
        echo "Argument 3 (Mesh agent id) is empty !"
        echo "Type help for more information"
        exit 1
fi

## Setting var for easy scription
system=$2
mesh_url=$3
rmm_url=$4
rmm_client_id=$5
rmm_site_id=$6
rmm_auth=$7
rmm_agent_type=$8
## Uninstall var for easy scription
mesh_fqdn=$2
mesh_id=$3

go_url_amd64="https://go.dev/dl/go1.18.3.linux-amd64.tar.gz"
go_url_x86="https://go.dev/dl/go1.18.3.linux-386.tar.gz"
go_url_arm64="https://go.dev/dl/go1.18.3.linux-arm64.tar.gz"
go_url_armv6="https://go.dev/dl/go1.18.3.linux-armv6l.tar.gz"

function go_install() {
        if ! command -v go &> /dev/null; then
                ## Installing golang
                case $system in
                amd64)
                wget -O /tmp/golang.tar.gz $go_url_amd64
                        ;;
                x86)
                wget -O /tmp/golang.tar.gz $go_url_x86
                ;;
                arm64)
                wget -O /tmp/golang.tar.gz $go_url_arm64
                ;;
                armv6)
                wget -O /tmp/golang.tar.gz $go_url_armv6
                ;;
                esac
                
                tar -xvzf /tmp/golang.tar.gz -C /usr/local/
                rm /tmp/golang.tar.gz
                export GOPATH=/usr/local/go
                export GOCACHE=/root/.cache/go-build

                echo "Golang Install Done !"
        else
                echo "Go is already installed"
        fi
}

function agent_compile() {
        ## Compiling and installing tactical agent from github
        echo "Agent Compile begin"
        wget -O /tmp/rmmagent.zip "https://github.com/amidaware/rmmagent/archive/refs/heads/master.zip"
        unzip /tmp/rmmagent -d /tmp/
        rm /tmp/rmmagent.zip
        cd /tmp/rmmagent-master
        case $system in
        amd64)
          env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o /tmp/temp_rmmagent
        ;;
        x86)
          env CGO_ENABLED=0 GOOS=linux GOARCH=386 go build -ldflags "-s -w" -o /tmp/temp_rmmagent
        ;;
        arm64)
          env CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags "-s -w" -o /tmp/temp_rmmagent
        ;;
        armv6)
          env CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags "-s -w" -o /tmp/temp_rmmagent
        ;;
        esac
        
        cd /tmp
        rm -R /tmp/rmmagent-master
}

function update_agent() {
        systemctl stop tacticalagent

        cp /tmp/temp_rmmagent /usr/local/bin/rmmagent
        rm /tmp/temp_rmmagent

        systemctl start tacticalagent
}
function install_agent() {
        cp /tmp/temp_rmmagent /usr/local/bin/rmmagent
        /tmp/temp_rmmagent -m install -api $rmm_url -client-id $rmm_client_id -site-id $rmm_site_id -agent-type $rmm_agent_type -auth $rmm_auth
        rm /tmp/temp_rmmagent

        cat << "EOF" > /etc/systemd/system/tacticalagent.service
[Unit]
Description=Tactical RMM Linux Agent
[Service]
Type=simple
ExecStart=/usr/local/bin/rmmagent -m svc
User=root
Group=root
Restart=always
RestartSec=5s
LimitNOFILE=1000000
KillMode=process
[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable --now tacticalagent
  systemctl start tacticalagent
}

function install_mesh() {
  ## Installing mesh agent
  wget -O /tmp/meshagent $mesh_url
  chmod +x /tmp/meshagent
  mkdir /opt/tacticalmesh
  /tmp/meshagent -install --installPath="/opt/tacticalmesh"
  rm /tmp/meshagent
  rm /tmp/meshagent.msh
}

function check_profile () {
        source /etc/environment
        profile_file="/root/.profile"
        path_count=$(cat $profile_file | grep -o "export PATH=/usr/local/go/bin" | wc -l)
        if [[ $path_count -ne 0 ]]; then
                echo "Removing incorrect \$PATH variable\(s\)"
                sed -i "/export\ PATH\=\/usr\/local\/go\/bin/d" $profile_file
        fi

        path_count=$(cat $profile_file | grep -o "export PATH=\$PATH:/usr/local/go/bin" | wc -l)
        if [[ $path_count -ne 1 ]]; then
                echo "Fixing \$PATH Variable"
                sed -i "/export\ PATH\=\$PATH\:\/usr\/local\/go\/bin/d" $profile_file
                echo "export PATH=\$PATH:/usr/local/go/bin" >> $profile_file
        fi
        source $profile_file
}

function uninstall_agent() {
        systemctl stop tacticalagent
        systemctl disable tacticalagent
        rm /etc/systemd/system/tacticalagent.service
        systemctl daemon-reload
        rm /usr/local/bin/rmmagent
        rm /etc/tacticalagent
        sed -i "/export\ PATH\=\$PATH\:\/usr\/local\/go\/bin/d" /root/.profile
}

function uninstall_mesh() {
        (wget "https://$mesh_fqdn/meshagents?script=1" -O /tmp/meshinstall.sh || wget "https://$mesh_fqdn/meshagents?script=1" --no-proxy -O /tmp/meshinstall.sh)
        chmod 755 /tmp/meshinstall.sh
        (/tmp/meshinstall.sh uninstall https://$mesh_fqdn $mesh_id || /tmp/meshinstall.sh uninstall uninstall uninstall https://$mesh_fqdn $mesh_id)
        rm /tmp/meshinstall.sh
        rm meshagent
        rm meshagent.msh
}

case $1 in
install)
        check_profile
        go_install
        install_mesh
        agent_compile
        install_agent
        echo "Tactical Agent Install is done"
        exit 0;;
update)
        check_profile
        go_install
        agent_compile
        update_agent
        echo "Tactical Agent Update is done"
        exit 0;;
uninstall)
        check_profile
        uninstall_agent
        uninstall_mesh
        echo "Tactical Agent Uninstall is done"
        echo "You may need to manually remove the agents orphaned connections on TacticalRMM and MeshCentral"
        exit 0;;
esac
