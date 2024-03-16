"""two c220g5 client nodes and one server running ubuntu 20.04

Instructions:
su sudo for root access"""

#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

import os
# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()
# urn:publicid:IDN+utah.cloudlab.us:super-fuzzing-pg0+ltdataset+DataStorage
pc.defineParameter("DATASET", "URN of your dataset",
                   portal.ParameterType.STRING,
                   "urn:publicid:IDN+utah.cloudlab.us:super-fuzzing-pg0+ltdataset+DataStorage")

pc.defineParameter("MPOINT", "Mountpoint for file system",
                   portal.ParameterType.STRING, "/data")

params = pc.bindParameters()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

USER = os.environ["USER"]
OQINSTALL = "sudo bash /local/repository/install-docker.sh"
SINEPY = "sudo -u {} nohup python3 /local/repository/sine.py > /dev/null &"
SINEPY = SINEPY.format(USER)
ADDGRP = "sudo usermod -aG docker {}"
ADDGRP = ADDGRP.format(USER)
CHOWN_DATA = "sudo chown -R {} /mydata"
CHOWN_DATA = CHOWN_DATA.format(USER)
MKDIR_DATA = "sudo -u {} mkdir /mydata/data"
MKDIR_DATA = MKDIR_DATA.format(USER)
URN2204 = "urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU22-64-STD"

# Node server
node_server = request.RawPC('server')
node_server.hardware_type = 'c220g5'
#node_server.hardware_type = 'd6515'
# node_server.hardware_type = 'sm110p'
node_server.disk_image = URN2204
iface0 = node_server.addInterface('interface-0')
bs0 = node_server.Blockstore('bs', '/mydata')
node_server.addService(pg.Execute(shell="bash", command=OQINSTALL))
node_server.addService(pg.Execute(shell="bash", command=SINEPY))
node_server.addService(pg.Execute(shell="bash", command=ADDGRP))

# Node client 1
node_client_1 = request.RawPC('client1')
node_client_1.hardware_type = 'c220g5'
#node_client_1.hardware_type = 'd6515'
#node_client_1.hardware_type = 'sm110p'
node_client_1.disk_image = URN2204
iface1 = node_client_1.addInterface('interface-1')
bs1 = node_client_1.Blockstore('bs1', '/mydata')
node_client_1.addService(pg.Execute(shell="bash", command=OQINSTALL))
node_client_1.addService(pg.Execute(shell="bash", command=SINEPY))
node_client_1.addService(pg.Execute(shell="bash", command=ADDGRP))

# Node client 2
node_client_2 = request.RawPC('client2')
node_client_2.hardware_type = 'c220g5'
#node_client_2.hardware_type = 'd6515'
#node_client_2.hardware_type = 'sm110p'
node_client_2.disk_image = URN2204
iface2 = node_client_2.addInterface('interface-2')
bs2 = node_client_2.Blockstore('bs2', '/mydata')
node_client_2.addService(pg.Execute(shell="bash", command=OQINSTALL))
node_client_2.addService(pg.Execute(shell="bash", command=SINEPY))
node_client_2.addService(pg.Execute(shell="bash", command=ADDGRP))

# Link link-0
link_0 = request.Link('link-0')
link_0.Site('undefined')
link_0.addInterface(iface0)
link_0.addInterface(iface1)
link_0.addInterface(iface2)

# Print the generated rspec
pc.printRequestRSpec(request)
