#!/bin/bash

/etc/init.d/frps stop

mkdir -p /etc/frp/

echo IyBbY29tbW9uXSBpcyBpbnRlZ3JhbCBzZWN0aW9uCltjb21tb25dCiMgQSBsaXRlcmFsIGFkZHJlc3Mgb3IgaG9zdCBuYW1lIGZvciBJUHY2IG11c3QgYmUgZW5jbG9zZWQKIyBpbiBzcXVhcmUgYnJhY2tldHMsIGFzIGluICJbOjoxXTo4MCIsICJbaXB2Ni1ob3N0XTpodHRwIiBvciAiW2lwdjYtaG9zdCV6b25lXTo4MCIKYmluZF9hZGRyID0gMC4wLjAuMApiaW5kX3BvcnQgPSA1NDQzCiMgdWRwIHBvcnQgdXNlZCBmb3Iga2NwIHByb3RvY29sLCBpdCBjYW4gYmUgc2FtZSB3aXRoICdiaW5kX3BvcnQnCiMgaWYgbm90IHNldCwga2NwIGlzIGRpc2FibGVkIGluIGZycHMKa2NwX2JpbmRfcG9ydCA9IDU0NDMKIyBpZiB5b3Ugd2FudCB0byBjb25maWd1cmUgb3IgcmVsb2FkIGZycHMgYnkgZGFzaGJvYXJkLCBkYXNoYm9hcmRfcG9ydCBtdXN0IGJlIHNldApkYXNoYm9hcmRfcG9ydCA9IDY0NDMKIyBkYXNoYm9hcmQgYXNzZXRzIGRpcmVjdG9yeShvbmx5IGZvciBkZWJ1ZyBtb2RlKQpkYXNoYm9hcmRfdXNlciA9IGFkbWluCmRhc2hib2FyZF9wd2QgPSBNUEVRcllxQgojIGFzc2V0c19kaXIgPSAuL3N0YXRpYwp2aG9zdF9odHRwX3BvcnQgPSA4MAp2aG9zdF9odHRwc19wb3J0ID0gNDQzCiMgY29uc29sZSBvciByZWFsIGxvZ0ZpbGUgcGF0aCBsaWtlIC4vZnJwcy5sb2cKbG9nX2ZpbGUgPSAuL2ZycHMubG9nCiMgZGVidWcsIGluZm8sIHdhcm4sIGVycm9yCmxvZ19sZXZlbCA9IGluZm8KbG9nX21heF9kYXlzID0gMwojIGF1dGggdG9rZW4KdG9rZW4gPSBsWm9hRmVZYXN0MTdrU1g2CiMgSXQgaXMgY29udmVuaWVudCB0byB1c2Ugc3ViZG9tYWluIGNvbmZpZ3VyZSBmb3IgaHR0cOOAgWh0dHBzIHR5cGUgd2hlbiBtYW55IHBlb3BsZSB1c2Ugb25lIGZycHMgc2VydmVyIHRvZ2V0aGVyLgpzdWJkb21haW5faG9zdCA9IGxvY2FsaG9zdAojIG9ubHkgYWxsb3cgZnJwYyB0byBiaW5kIHBvcnRzIHlvdSBsaXN0LCBpZiB5b3Ugc2V0IG5vdGhpbmcsIHRoZXJlIHdvbid0IGJlIGFueSBsaW1pdAojYWxsb3dfcG9ydHMgPSAxLTY1NTM1CiMgcG9vbF9jb3VudCBpbiBlYWNoIHByb3h5IHdpbGwgY2hhbmdlIHRvIG1heF9wb29sX2NvdW50IGlmIHRoZXkgZXhjZWVkIHRoZSBtYXhpbXVtIHZhbHVlCm1heF9wb29sX2NvdW50ID0gNTAKIyBpZiB0Y3Agc3RyZWFtIG11bHRpcGxleGluZyBpcyB1c2VkLCBkZWZhdWx0IGlzIHRydWUKdGNwX211eCA9IHRydWUK | base64 -d > /usr/local/frps/frps.ini

sudo sed -i 's/frps\.toml/frps\.ini/g' /etc/init.d/frps

