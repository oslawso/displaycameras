#!/bin/bash

# install-NEW.sh - Installation script for displaycameras-NEW
# Version: 1.0.0
#
# Usage:
#   sudo ./install-NEW.sh           # Fresh install
#   sudo ./install-NEW.sh upgrade   # Upgrade (preserve configs)
#   sudo ./install-NEW.sh remove    # Remove installation

set -e

# Exit if not root
if [[ $EUID -ne 0 ]]; then
   echo "This script must be run as root"
   exit 1
fi

DIR=$(dirname "$(readlink -f "$0")")

install_dependencies() {
    echo "Installing dependencies..."
    apt-get update
    apt-get install -y mpv socat

    # Optional: fbi for screen blanking
    if apt-get install -y fbi 2>/dev/null; then
        echo "fbi installed for screen blanking support"
    else
        echo "Note: fbi not available (screen blanking will not work)"
    fi
}

install_scripts() {
    echo "Installing scripts to /usr/bin/..."
    cp -f "$DIR/displaycameras-NEW" /usr/bin/
    chmod 755 /usr/bin/displaycameras-NEW

    cp -f "$DIR/mpv_control" /usr/bin/
    chmod 755 /usr/bin/mpv_control

    cp -f "$DIR/rotatedisplays-NEW" /usr/bin/
    chmod 755 /usr/bin/rotatedisplays-NEW

    # Copy black.png if it exists
    if [ -f "$DIR/black.png" ]; then
        cp -f "$DIR/black.png" /usr/bin/
    elif [ -f "$DIR/../black.png" ]; then
        cp -f "$DIR/../black.png" /usr/bin/
    fi
}

install_configs() {
    echo "Installing configuration files to /etc/displaycameras-NEW/..."
    mkdir -p /etc/displaycameras-NEW

    cp -f "$DIR/displaycameras-NEW.conf" /etc/displaycameras-NEW/
    cp -f "$DIR/layout.conf.default" /etc/displaycameras-NEW/

    # Copy example layouts if they exist
    if [ -d "$DIR/example_layouts" ]; then
        cp -f "$DIR/example_layouts/"* /etc/displaycameras-NEW/ 2>/dev/null || true
    fi

    echo ""
    echo "IMPORTANT: Edit your configuration files:"
    echo "  /etc/displaycameras-NEW/displaycameras-NEW.conf  (global settings)"
    echo "  /etc/displaycameras-NEW/layout.conf.default      (camera layout)"
}

install_service() {
    echo "Installing systemd service..."
    cp -f "$DIR/displaycameras-NEW.service" /etc/systemd/system/
    chmod 644 /etc/systemd/system/displaycameras-NEW.service
    systemctl daemon-reload

    # Install cron job
    echo "Installing cron job for automatic repair..."
    cp -f "$DIR/repaircameras-NEW.cron" /etc/cron.d/repaircameras-NEW
    chmod 644 /etc/cron.d/repaircameras-NEW
}

enable_service() {
    echo "Enabling displaycameras-NEW service..."
    systemctl enable displaycameras-NEW
    echo ""
    echo "Service enabled. Start with: sudo systemctl start displaycameras-NEW"
}

backup_configs() {
    if [ -d /etc/displaycameras-NEW ]; then
        echo "Backing up existing configuration..."
        mkdir -p /etc/displaycameras-NEW/bak
        cp -f /etc/displaycameras-NEW/*.conf /etc/displaycameras-NEW/bak/ 2>/dev/null || true
    fi
}

remove_installation() {
    echo "Removing displaycameras-NEW..."

    # Stop service if running
    systemctl stop displaycameras-NEW 2>/dev/null || true
    systemctl disable displaycameras-NEW 2>/dev/null || true

    # Remove files
    rm -f /usr/bin/displaycameras-NEW
    rm -f /usr/bin/mpv_control
    rm -f /usr/bin/rotatedisplays-NEW
    rm -f /etc/systemd/system/displaycameras-NEW.service
    rm -f /etc/cron.d/repaircameras-NEW

    systemctl daemon-reload

    echo ""
    echo "Scripts and service removed."
    echo "Configuration files preserved in /etc/displaycameras-NEW/"
    echo "To remove configs: rm -rf /etc/displaycameras-NEW"
}

case "${1:-install}" in
install)
    echo "=========================================="
    echo "Installing displaycameras-NEW"
    echo "=========================================="
    echo ""

    install_dependencies
    install_scripts
    install_configs
    install_service
    enable_service

    echo ""
    echo "=========================================="
    echo "Installation complete!"
    echo "=========================================="
    echo ""
    echo "Next steps:"
    echo "1. Edit /etc/displaycameras-NEW/layout.conf.default with your camera feeds"
    echo "2. Optionally edit /etc/displaycameras-NEW/displaycameras-NEW.conf"
    echo "3. Start the service: sudo systemctl start displaycameras-NEW"
    echo ""
    echo "Commands:"
    echo "  sudo displaycameras-NEW start    - Start displaying cameras"
    echo "  sudo displaycameras-NEW stop     - Stop displaying cameras"
    echo "  sudo displaycameras-NEW status   - Show feed status"
    echo "  sudo systemctl status displaycameras-NEW  - Show service status"
    ;;

upgrade)
    echo "=========================================="
    echo "Upgrading displaycameras-NEW"
    echo "=========================================="
    echo ""

    # Stop service first
    systemctl stop displaycameras-NEW 2>/dev/null || true

    backup_configs
    install_dependencies
    install_scripts
    install_service

    # Restart if it was running
    systemctl start displaycameras-NEW 2>/dev/null || true

    echo ""
    echo "=========================================="
    echo "Upgrade complete!"
    echo "=========================================="
    echo "Configuration files preserved."
    ;;

remove|uninstall)
    remove_installation
    ;;

*)
    echo "Usage: $0 [install|upgrade|remove]"
    echo ""
    echo "  install  - Fresh installation (default)"
    echo "  upgrade  - Upgrade scripts, preserve configs"
    echo "  remove   - Remove installation"
    exit 1
    ;;
esac
