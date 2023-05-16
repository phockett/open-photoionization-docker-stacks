#!/bin/bash

# Configure some Jupyter options.
# 25/10/22
# 15/05/23 - version for Luna builds. Note password config not working in testing?
#             Also reverted to sed > copy otherwise modified files are blank?
#
# Mainly sets open IP for connection. This shouldn't be necessary in Docker, but can sometimes get repeated "Replacing stale connection" and kernel disconnects without, may be an Nginx issue.
# See https://discourse.jupyter.org/t/troubleshoot-terminal-hangs-on-launch-docker-image-fails-in-linux-works-in-macos/2829/4
# And https://github.com/jupyter/notebook/issues/625
#
# Optional:
# - Set a hashed password here.
# - Config any other options.
#
# To set a hashed password in IPython:
#    from jupyter_server.auth import passwd
#    passwd()


# Set Jupyter server options
jupyter server --generate-config -y
sed -e "s/# c.ServerApp.ip = 'localhost'/c.ServerApp.ip = '*'/" /home/jovyan/.jupyter/jupyter_server_config.py > /home/jovyan/.jupyter/jupyter_server_config-2.py
# sed -e "s/# c.ServerApp.password = ''/c.ServerApp.password = 'u'<set a hashed password here>'/" /home/jovyan/.jupyter/jupyter_server_config.py.test > /home/jovyan/.jupyter/jupyter_server_config.py.test2

# Password = luna
sed -e "s/# c.ServerApp.password = ''/c.ServerApp.password = 'u'sha1:6ecaa8840a35:6fa4330da99acc8d97c47c9ca604ddc856511dde'/" /home/jovyan/.jupyter/jupyter_server_config-2.py > /home/jovyan/.jupyter/jupyter_server_config-3.py
mv /home/jovyan/.jupyter/jupyter_server_config-3.py /home/jovyan/.jupyter/jupyter_server_config.py
# 15/05/23 - this no longer seems to work, Jupyter throws error with password line on start. But looks identical to case set in login screen?
# Rebuild needed?


# Set Jupyter notebook options
jupyter notebook --generate-config -y
sed -e "s/# c.NotebookApp.allow_origin = ''/c.NotebookApp.allow_origin =  '*'/" /home/jovyan/.jupyter/jupyter_notebook_config.py > /home/jovyan/.jupyter/jupyter_notebook_config-2.py
mv /home/jovyan/.jupyter/jupyter_notebook_config-2.py /home/jovyan/.jupyter/jupyter_notebook_config.py

# Copy reference settings
cp -r /home/jovyan/.jupyter /home/jovyan/.jupyter_ref-build
