"""two c6525-25g client nodes and one server running ubuntu 20.04

Instructions:
su sudo for root access"""

#
# NOTE: This code was machine converted. An actual human would not
#       write code like this!
#

# Import the Portal object.
import geni.portal as portal
# Import the ProtoGENI library.
import geni.rspec.pg as pg
# Import the Emulab specific extensions.
import geni.rspec.emulab as emulab

# Create a portal object,
pc = portal.Context()

# Create a Request object to start building the RSpec.
request = pc.makeRequestRSpec()

OQINSTALL = "sudo bash /local/repository/install-docker.sh"

# Node server
node_server = request.RawPC('server')
node_server.hardware_type = 'c6525-25g'
node_server.disk_image = 'urn:publicid:IDN+emulab.net+image+emulab-ops//UBUNTU20-64-STD'
iface0 = node_server.addInterface('interface-0')
bs0 = node_server.Blockstore('bs', '/mydata')
node_server.addService(pg.Execute(shell="bash", command=OQINSTALL))

# Node client 1
node_client_1 = request.RawPC('client1')
node_client_1.hardware_type = 'c6525-25g'
node_client_1.disk_image = 'urn:publicid:IDN+utah.cloudlab.us+image+emulab-ops//UBUNTU20-64-STD'
iface1 = node_client_1.addInterface('interface-1')
bs1 = node_client_1.Blockstore('bs1', '/mydata')
node_client_1.addService(pg.Execute(shell="bash", command=OQINSTALL))

# Node client 2
node_client_2 = request.RawPC('client2')
node_client_2.hardware_type = 'c6525-25g'
node_client_2.disk_image = 'urn:publicid:IDN+utah.cloudlab.us+image+emulab-ops//UBUNTU20-64-STD'
iface2 = node_client_2.addInterface('interface-2')
bs2 = node_client_2.Blockstore('bs2', '/mydata')
node_client_2.addService(pg.Execute(shell="bash", command=OQINSTALL))

# Link link-0
link_0 = request.Link('link-0')
link_0.Site('undefined')
link_0.addInterface(iface0)
link_0.addInterface(iface1)
link_0.addInterface(iface2)

# Print the generated rspec
pc.printRequestRSpec(request)
