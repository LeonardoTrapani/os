#!/bin/bash

# Create .ssh directory if it doesn't exist
mkdir -p ~/.ssh

# Backup existing config file if it exists
if [ -f ~/.ssh/config ]; then
    cp ~/.ssh/config ~/.ssh/config.bak
    echo "Existing SSH config backed up to ~/.ssh/config.bak"
fi

# Create the SSH config file
cat > ~/.ssh/config << 'EOF'
Host *
  IdentityAgent ~/.1password/agent.sock
EOF

echo "SSH config file created at ~/.ssh/config"