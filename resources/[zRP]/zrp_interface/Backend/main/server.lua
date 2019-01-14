Proxy = module("zrp", "lib/Proxy")
Tunnel = module("zrp", "lib/Tunnel")

zRP = Proxy.getInterface("zRP", "zrp_inteface")
zRPclient = Tunnel.getInterface("zRP", "zrp_inteface")

zRPIclient = Tunnel.getInterface("zrp_interface", "zrp_interface")

tzRPI = {}

Tunnel.bindInterface("zrp_interface", tzRPI)
