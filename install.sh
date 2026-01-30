#!/usr/bin/env bash

# Get the directory where this script is located
src_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
dst_dir="$HOME"

# Function to create symlinks
create_symlink() {
    local src_path="$1"
    local dst_path="$2"
    local name="$3"
    
    # Create parent directory if it doesn't exist
    local dst_parent="$(dirname "${dst_path}")"
    if [ ! -d "${dst_parent}" ]; then
        echo "Creating directory ${dst_parent}..."
        mkdir -p "${dst_parent}"
    fi
    
    # Create symlink if it doesn't exist
    if [ ! -e "${dst_path}/${name}" ]; then
        echo "Creating ${name} symlink..."
        ln -s "${src_path}/${name}" "${dst_path}/${name}"
    else
        echo "${name} already exists"
    fi
}

### vim configuration
echo "Setting up vim configuration..."

create_symlink "${src_dir}" "${dst_dir}" ".vimrc"
create_symlink "${src_dir}" "${dst_dir}" ".vim"

echo "Vim setup complete!"
