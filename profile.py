"""Install frps.
"""
import os
# Import the Portal object.
import geni.portal as portal
# Emulab specific extensions.
import geni.rspec.emulab as emulab
# Import the ProtoGENI library.
import geni.rspec.pg as rspec


# Create a portal context, needed to defined parameters
pc = portal.Context()
#
# This is a git repo with my dot files and junk I like.
#
# URL = "https://gitlab.flux.utah.edu/stoller/dots/-/raw/master/dots.tar.gz"


imageList = [('urn:publicid:IDN+emulab.net+image+Super-Fuzzing:vm-with-mac', 'UBUNTU 18.04 with packages'),
#     ('urn:publicid:IDN+clemson.cloudlab.us+image+emulab-ops:UBUNTU20-PPC-OSCP-U', '20.04 PPC'),
    ('urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD', 'UBUNTU 18.04'),
    ('urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU20-64-STD', 'UBUNTU 20.04')]

pc.defineParameter("osImage", "Select OS image",
                   portal.ParameterType.IMAGE,
                   imageList[0], imageList,
                   longDescription="")

# urn:publicid:IDN+utah.cloudlab.us:super-fuzzing-pg0+ltdataset+DataStorage
pc.defineParameter("DATASET", "URN of your dataset",
                   portal.ParameterType.STRING,
                   "urn:publicid:IDN+utah.cloudlab.us:super-fuzzing-pg0+ltdataset+DataStorage")

pc.defineParameter("MPOINT", "Mountpoint for file system",
                   portal.ParameterType.STRING, "/mydata")

params = pc.bindParameters()

USER = os.environ["USER"]

CHMOD = "chmod 700 /local/repository/*.sh"
OQINSTALL = "sudo bash /local/repository/os-ins.sh"
MNT = "sudo mkdir -p /mnt/extra"
MNT_1 = "sudo mkfs.ext4 /dev/nvme0n1p4"
MNT_2 = "sudo mount /dev/nvme0n1p4 /mnt/extra"
DOCKERINSTALL = "sudo bash /local/repository/install-docker.sh"

UNTAR = "sudo -u {} nohup python3 /local/repository/sine.py > /dev/null &"
UNTAR = UNTAR.format(USER)
PKG_UPDATE = "sudo apt update"
INSTALL_PKG = "sudo apt install byobu build-essential vim dmg2img -y"
ADDGRP = "sudo usermod -aG docker {}"
ADDGRP = ADDGRP.format(USER)

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()


# Add a raw PC to the request.
node = request.RawPC("node")
node.hardware_type = "xl170"
node.hardware_type = "c6620"
# node.hardware_type = "m510"
iface = node.addInterface()
node.disk_image = params.osImage
fsnode = request.RemoteBlockstore("bs", params.MPOINT)
fsnode.dataset = params.DATASET

# bs0 = node.Blockstore('bs', '/mnt/extra/data')

fslink = request.Link("fslink")
fslink.addInterface(iface)
fslink.addInterface(fsnode.interface)

# Special attributes for this link that we must use.
fslink.best_effort = True
fslink.vlan_tagging = True


# Install
node.addService(rspec.Execute(shell="bash", command=PKG_UPDATE))
node.addService(rspec.Execute(shell="bash", command=INSTALL_PKG))
# node.addService(rspec.Execute(shell="bash", command=MNT))
# node.addService(rspec.Execute(shell="bash", command=MNT_1))
# node.addService(rspec.Execute(shell="bash", command=MNT_2))
node.addService(rspec.Execute(shell="bash", command=CHMOD))
node.addService(rspec.Execute(shell="bash", command=OQINSTALL))
node.addService(rspec.Execute(shell="bash", command=UNTAR))
node.addService(rspec.Execute(shell="bash", command=DOCKERINSTALL))
node.addService(rspec.Execute(shell="bash", command=ADDGRP))
node.addService(rspec.Execute(shell="sh", command="sh /local/repository/setup-grow-rootfs.sh 0"))

portal.context.printRequestRSpec()

