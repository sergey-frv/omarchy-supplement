#!/bin/bash

# Install dotnet LTS
curl -sSL https://dot.net/v1/dotnet-install.sh | bash /dev/stdin -channel LTS
# nvim tool
dotnet tool install -g EasyDotnet

cat << \EOF >> ~/.bash_profile
# Add .NET Core SDK tools
export PATH="$PATH:/home/sf/.dotnet/tools"
EOF
