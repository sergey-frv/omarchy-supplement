#!/bin/bash

echo "Downloading .NET install script..."
curl -sSL https://dot.net/v1/dotnet-install.sh -o dotnet-install.sh
chmod +x dotnet-install.sh

echo "Installing .NET..."
./dotnet-install.sh --channel LTS

echo "Adding DOTNET_ROOT env to bash_profile..."
DOTNET_ROOT_EXPORT='export DOTNET_ROOT=$HOME/.dotnet'
eval "$DOTNET_ROOT_EXPORT" # for current terminal session

grep -q "$DOTNET_ROOT_EXPORT" ~/.bash_profile
if [ $? -eq 0 ]; then
  echo "DOTNET_ROOT env already added"
else
  echo "# Add .NET Core environment variabe" >>~/.bash_profile
  echo "$DOTNET_ROOT_EXPORT" >>~/.bash_profile
fi

echo "Adding dotnet tools to PATH to bash_profile"
TOOL_PATH_EXPORT='export PATH=$PATH:$DOTNET_ROOT:$DOTNET_ROOT/tools'
eval "$TOOL_PATH_EXPORT" # for current terminal session

grep -q "$TOOL_PATH_EXPORT" ~/.bash_profile
if [ $? -eq 0 ]; then
  echo "Dotnet tools path already added"
else
  echo '# Add .NET Core SDK tools' >>~/.bash_profile
  echo "$TOOL_PATH_EXPORT" >>~/.bash_profile
fi

# Verify installation
dotnet --version
if [ $? -ne 0 ]; then
  echo ".NET installation failed."
  exit 1
fi

# Install nvim tool
echo "Installing EasyDotnet tool..."
dotnet tool install -g EasyDotnet

echo "Installation complete!"
rm -rf dotnet-install.sh
