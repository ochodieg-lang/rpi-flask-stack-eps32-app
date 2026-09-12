#!/bin/bash
# production-deploy.sh - automated Lab-App env replication script
set -e

echo "=== Creating isolated linux application user ==="
if ! id "lab_app_user" &>/dev/null; then
    sudo useradd -r -s /bin/false -M lab_app_user
    echo "✔ lab_app_user created successfully!"
else
    echo "- lab_app_user already exists."
fi

echo "=== Structuring persistent sys runtime socket location ==="
echo "=== NOT RUNNING IN tempfs YET ==="
sudo mkdir -p /var/www/run/uwsgi/lab_app
sudo chown -R root:www-data /var/www/run
sudo chown lab_app_user:www-data /var/www/run/uwsgi/lab_app
sudo chmod 755 /var/www/run
sudo chmod 750 /var/www/run/uwsgi/lab_app
echo "✔ persistent runtime environment built!"

echo "=== Structuring Dedicated sysLog footprint ==="
sudo mkdir -p /var/log/uwsgi
sudo touch /var/log/uwsgi/lab_app_uwsgi.log
sudo chown root:root /var/log/uwsgi
sudo chmod 755 /var/log/uwsgi
sudo chown lab_app_user:www-data /var/log/uwsgi/lab_app_uwsgi.log
sudo chmod 640 /var/log/uwsgi/lab_app_uwsgi.log
echo "✔ Logging channels initialized!"

echo "=== Constructing standalone physical venv ==="
cd /var/www/lab_app
rm -rf .venv
python3 -m venv --copies .venv
echo "✔ Standalone physical env compiled!"

echo "=== Syncing app deps natively ==="
# Using uv sync to pull exact snapshots out of the tracked uv.lock file
uv sync --link-mode=copy
echo "✔ Application environment fully populated via uv."

echo "=== Applying final Hardened permissions sweep ==="
sudo chown -R lab_app_user:www-data /var/www/lab_app
sudo find /var/www/lab_app -type d -exec chmod 750 {} +
sudo find /var/www/lab_app -type f -exec chmod 640 {} +
sudo find /var/www/lab_app/static -type d -exec chmod 755 {} +
sudo find /var/www/lab_app/static -type f -exec chmod 644 {} +
sudo chmod 770 /var/www/lab_app/.venv/bin/uwsgi
echo "✔ Permissions sweep complete! Security profile locked down!"

echo "=== Provisioning system integration configs ==="
sudo cp /var/www/lab_app/lab_app_nginx.conf /etc/nginx/sites-available/lab_app.conf
sudo chown root:root /etc/nginx/sites-available/lab_app.conf
sudo chmod 644 /etc/nginx/sites-available/lab_app.conf
sudo ln -sf /etc/nginx/sites-available/lab_app.conf /etc/nginx/sites-enabled/

echo "=== DEPLOYMENT COMPLETED SUCCESSFULLY ==="
echo "Reload systemd, place your systemd unit file into /etc/systemd/system/, and fire up the app!"
