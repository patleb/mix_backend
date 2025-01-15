sun.update
sun.install "nodejs"
sun.install "npm"

npm install -g corepack
corepack enable

sudo su - deployer << 'EOF'
  yarn_version=<%= sun.yarn_version || 'stable' %>

  yes | yarn set version $yarn_version
  yarn --version
EOF
