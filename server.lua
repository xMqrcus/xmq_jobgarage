local Tunnel = module("vrp", "lib/Tunnel")
local Proxy = module("vrp", "lib/Proxy")
vRPgc = Tunnel.getInterface("vRP_garages","xmq_garage")

vRP = Proxy.getInterface("vRP", "xmq_garage")
vRPclient = Tunnel.getInterface("vRP","xmq_garage")

HT = nil

TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)

---############ KODE ############---

HT.RegisterServerCallback('xmq:jobGaragePerm', function(source, cb, perm)
  local user_id = vRP.getUserId({source})
  cb(vRP.hasPermission({user_id,perm}))
end)