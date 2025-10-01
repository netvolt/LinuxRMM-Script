#!/bin/bash
insecure_flag=false
filtered_args=()
for arg in "$@"; do
    if [[ $arg == "--insecure" ]]; then
        insecure_flag=true
    else
        filtered_args+=("$arg")
    fi
done
set -- "${filtered_args[@]}"

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
        echo "Arg 2: Mesh agent URL"
        echo "Arg 3: API URL"
        echo "Arg 4: Client ID"
        echo "Arg 5: Site ID"
        echo "Arg 6: Auth Key"
        echo "Arg 7: Agent Type 'server' or 'workstation'"
        echo ""
        echo "List of UPDATE argument (no argument name)"
        echo "Arg 1: 'update'"
        echo ""
        echo "List of UNINSTALL argument (no argument name):"
        echo "Arg 1: 'uninstall'"
        echo "Arg 2: Mesh agent FQDN (i.e. mesh.example.com)"
        echo "Arg 3: Mesh agent id (The id needs to have single quotes around it)"
        echo ""
        echo "Optional: Add '--insecure' to bypass certificate checks for Tactical RMM and Mesh connections"
        echo ""
        exit 0
fi

if [[ $1 != "install" && $1 != "update" && $1 != "uninstall" ]]; then
        echo "First argument can only be 'install' or 'update' or 'uninstall' !"
        echo "Type help for more information"
        exit 1
fi

## Automatically detect system architecture
system=$(uname -m)
case $system in
    x86_64)
        system="amd64"
        ;;
    i386|i686)
        system="x86"
        ;;
    aarch64)
        system="arm64"
        ;;
    armv6l)
        system="armv6"
        ;;
    *)
        echo "Unsupported architecture: $system"
        exit 1
        ;;
esac

## Setting variables
mesh_url=$2
rmm_url=$3
rmm_client_id=$4
rmm_site_id=$5
rmm_auth=$6
rmm_agent_type=$7
mesh_fqdn=$2
mesh_id=$3

agent_service_args="-m svc"
agent_install_insecure="false"
mesh_wget_opts=()

if [[ $insecure_flag == true ]]; then
        agent_service_args="-insecure -m svc"
        agent_install_insecure="true"
        mesh_wget_opts+=(--no-check-certificate)
fi

go_version="1.21.6"
go_url_amd64="https://go.dev/dl/go$go_version.linux-amd64.tar.gz"
go_url_x86="https://go.dev/dl/go$go_version.linux-386.tar.gz"
go_url_arm64="https://go.dev/dl/go$go_version.linux-arm64.tar.gz"
go_url_armv6="https://go.dev/dl/go$go_version.linux-armv6l.tar.gz"

function go_install() {
    if ! command -v go &> /dev/null; then
        case $system in
        amd64) wget -O /tmp/golang.tar.gz "$go_url_amd64" ;;
        x86) wget -O /tmp/golang.tar.gz "$go_url_x86" ;;
        arm64) wget -O /tmp/golang.tar.gz "$go_url_arm64" ;;
        armv6) wget -O /tmp/golang.tar.gz "$go_url_armv6" ;;
        esac
        rm -rf /usr/local/go/
        tar -xvzf /tmp/golang.tar.gz -C /usr/local/
        rm /tmp/golang.tar.gz
        export PATH=$PATH:/usr/local/go/bin
        echo "Go is installed."
    fi
}

function agent_compile() {
        echo "Agent Compile begin"
        wget -O /tmp/rmmagent.tar.gz "https://github.com/amidaware/rmmagent/archive/refs/heads/master.tar.gz"
        tar -xf /tmp/rmmagent.tar.gz -C /tmp/
        rm /tmp/rmmagent.tar.gz
        cd /tmp/rmmagent-master
        case $system in
        amd64) env CGO_ENABLED=0 GOOS=linux GOARCH=amd64 go build -ldflags "-s -w" -o /tmp/temp_rmmagent ;;
        x86) env CGO_ENABLED=0 GOOS=linux GOARCH=386 go build -ldflags "-s -w" -o /tmp/temp_rmmagent ;;
        arm64) env CGO_ENABLED=0 GOOS=linux GOARCH=arm64 go build -ldflags "-s -w" -o /tmp/temp_rmmagent ;;
        armv6) env CGO_ENABLED=0 GOOS=linux GOARCH=arm go build -ldflags "-s -w" -o /tmp/temp_rmmagent ;;
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
        local -a install_cmd=(/tmp/temp_rmmagent)

        if [[ $agent_install_insecure == "true" ]]; then
                install_cmd+=(-insecure)
        fi

        install_cmd+=(-m install -api "$rmm_url" -client-id "$rmm_client_id" -site-id "$rmm_site_id" -agent-type "$rmm_agent_type" -auth "$rmm_auth")

        "${install_cmd[@]}"
        rm /tmp/temp_rmmagent
        cat <<EOF > /etc/systemd/system/tacticalagent.service
[Unit]
Description=Tactical RMM Linux Agent
[Service]
Type=simple
ExecStart=/usr/local/bin/rmmagent $agent_service_args
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
        wget "${mesh_wget_opts[@]}" -O /tmp/meshagent "$mesh_url"
        chmod +x /tmp/meshagent
        mkdir -p /opt/tacticalmesh
        /tmp/meshagent -install --installPath="/opt/tacticalmesh"
        rm /tmp/meshagent
        rm -f /tmp/meshagent.msh
}

function uninstall_agent() {
        systemctl stop tacticalagent
        systemctl disable tacticalagent
        rm /etc/systemd/system/tacticalagent.service
        systemctl daemon-reload
        rm /usr/local/bin/rmmagent
        rm -rf /etc/tacticalagent
}

function uninstall_mesh() {
        local url="https://$mesh_fqdn/meshagents?script=1"
        local -a wget_opts=("${mesh_wget_opts[@]}")

        if ! wget "${wget_opts[@]}" -O /tmp/meshinstall.sh "$url"; then
                wget "${wget_opts[@]}" --no-proxy -O /tmp/meshinstall.sh "$url"
        fi
        chmod 755 /tmp/meshinstall.sh
        if ! /tmp/meshinstall.sh uninstall "https://$mesh_fqdn" "$mesh_id"; then
                /tmp/meshinstall.sh uninstall uninstall uninstall "https://$mesh_fqdn" "$mesh_id"
        fi
        rm /tmp/meshinstall.sh
}

case $1 in
install)
        go_install
        install_mesh
        agent_compile
        install_agent
        echo "Tactical Agent Install is done"
        exit 0;;
update)
        go_install
        agent_compile
        update_agent
        echo "Tactical Agent Update is done"
        exit 0;;
uninstall)
        uninstall_agent
        uninstall_mesh
        echo "Tactical Agent Uninstall is done"
        exit 0;;
esac
