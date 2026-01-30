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

### zshenv host configuration
echo "Setting up zshenv host configuration..."

hosts_dir="${dst_dir}/.zshenv.hosts"
hosts_template_src="${src_dir}/zshenv/host-template.zsh"
hosts_template_dst="${hosts_dir}/HOSTNAME.zsh"

if [ ! -d "${hosts_dir}" ]; then
    echo "Creating ${hosts_dir}..."
    mkdir -p "${hosts_dir}"
fi

if [ ! -f "${hosts_template_dst}" ]; then
    echo "Creating host template ${hosts_template_dst}..."
    cp "${hosts_template_src}" "${hosts_template_dst}"
else
    echo "Host template already exists"
fi

echo "Zshenv host setup complete!"
