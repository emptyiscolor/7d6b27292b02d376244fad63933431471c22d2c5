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


imageList = [('urn:publicid:IDN+emulab.net+image+emulab-ops:UBUNTU18-64-STD', 'UBUNTU 18.04'),
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
OQINSTALL = "sudo bash /local/repository/bootstrap.sh"
MNT = "sudo mkdir -p /mnt/sdb"
MNT_1 = "sudo mkfs.ext4 /dev/sdb"
MNT_2 = "sudo mount /dev/sdb /mnt/sdb"

UNTAR = "sudo -u {} nohup python3 /local/repository/sine.py > /dev/null &"
UNTAR = UNTAR.format(USER)
PKG_UPDATE = "sudo apt update"
INSTALL_PKG = "sudo apt install byobu build-essential vim dmg2img xfce4 xfce4-goodies tightvncserver tesseract-ocr tesseract-ocr-eng -y"

# Create a Request object to start building the RSpec.
request = portal.context.makeRequestRSpec()


# Add a raw PC to the request.
node = request.RawPC("node")
node.hardware_type = "d430"
# node.hardware_type = "d750"
# node.hardware_type = "ibm8335"
# node.hardware_type = "c240g5"
iface = node.addInterface()
node.disk_image = params.osImage
# fsnode = request.RemoteBlockstore("bs", params.MPOINT)
# fsnode.dataset = params.DATASET

# fslink = request.Link("fslink")
# fslink.addInterface(iface)
# fslink.addInterface(fsnode.interface)

# Special attributes for this link that we must use.
# fslink.best_effort = True
# fslink.vlan_tagging = True


# Install
node.addService(rspec.Execute(shell="bash", command=PKG_UPDATE))
node.addService(rspec.Execute(shell="bash", command=INSTALL_PKG))
node.addService(rspec.Execute(shell="bash", command=MNT))
node.addService(rspec.Execute(shell="bash", command=MNT_1))
node.addService(rspec.Execute(shell="bash", command=MNT_2))
node.addService(rspec.Execute(shell="bash", command=CHMOD))
node.addService(rspec.Execute(shell="bash", command=OQINSTALL))
node.addService(rspec.Execute(shell="bash", command=UNTAR))


portal.context.printRequestRSpec()
