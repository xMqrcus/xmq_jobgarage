vRP = Proxy.getInterface("vRP")
vRPclient = Tunnel.getInterface("vRP", "xmq_jobgarage")
vRPgt = {}

local active = false

HT = nil
CreateThread(function()
    while HT == nil do
        TriggerEvent('HT_base:getBaseObjects', function(obj) HT = obj end)
        Wait(0)
    end
end)

function drawTxt(text, font, centre, x, y, scale, r, g, b, a)
  SetTextFont(font)
  SetTextProportional(0)
  SetTextScale(scale, scale)
  SetTextColour(r, g, b, a)
  SetTextDropShadow(0, 0, 0, 0, 255)
  SetTextEdge(1, 0, 0, 0, 255)
  SetTextDropShadow()
  SetTextOutline()
  SetTextCentre(centre)
  SetTextEntry("STRING")
  AddTextComponentString(text)
  DrawText(x, y+0.1)
end

function round(num, dec)
	local mult = 10^(dec or 0)
	return math.floor(num * mult + 0.5) / mult
end

function DrawText3Ds(x,y,z, text)
    local onScreen,_x,_y=World3dToScreen2d(x,y,z)
    local px,py,pz=table.unpack(GetGameplayCamCoords())
    SetTextScale(0.35, 0.35)
    SetTextFont(6)
    SetTextProportional(1)
    SetTextColour(255, 255, 255, 215)
    SetTextOutline()
    SetTextEntry("STRING")
    SetTextCentre(1)
    AddTextComponentString(text)
    DrawText(_x,_y)
end

function firstToUpper(str)
  return (str:gsub("^%l", string.upper))
end

function DisplayHelpText(str)
	BeginTextCommandDisplayHelp("STRING")
	AddTextComponentSubstringPlayerName(str)
	EndTextCommandDisplayHelp(0, 0, 1, -1)
end

function formatarNumero(valor)
  local formatado = valor
  while true do  
                                          -- O "." entre "%1" e "%2" é o separador
    formatado, n = string.gsub(formatado, "^(-?%d+)(%d%d%d)", '%1.%2') 
    if ( n ==0 ) then
      break
    end
  end
  return formatado
end

---############ KODE ############---

function distance(x,y,z)
  local dist = #(GetEntityCoords(PlayerPedId()) - vector3(x,y,z))
  return dist
end

CreateThread(function()
  local ped = PlayerPedId()
  while true do
    Wait(1500)
    for i = 1, #garages do
      if garages[i].thread == nil then
        garages[i].thread = false
      end
      local distance = #(GetEntityCoords(ped) - vector3(garages[i].garage[1],garages[i].garage[2],garages[i].garage[3]))
      if distance < 20 then
          if not garages[i].thread == true then
            garages[i].thread = true
            thread(i)
            Wait(250)
          end
      else
          if garages[i].thread == true then
            garages[i].thread = false
            Wait(250)
          end
      end
    end
  end
end)

selecting = false
veh = nil
num = 1

CreateThread(function()
  -- Police
  for i = 1, #garages['vehicles']['police'], 1 do
    RequestModel(garages['vehicles']['police'][i].model)
    while not HasModelLoaded(garages['vehicles']['police'][i].model) do
      Wait(10)
    end
    print("Preloaded "..garages['vehicles']['police'][i].model)
  end

  -- EMS
  for i = 1, #garages['vehicles']['ems'], 1 do
    RequestModel(garages['vehicles']['ems'][i].model)
    while not HasModelLoaded(garages['vehicles']['ems'][i].model) do
      Wait(10)
    end
    print("Preloaded "..garages['vehicles']['ems'][i].model)
  end
end)

function thread(i)
  CreateThread(function()
    while garages[i].thread == true do
      Wait(1)
      if distance(garages[i].garage[1],garages[i].garage[2],garages[i].garage[3]) < 10 and selecting == false then
        DrawMarker(36, garages[i].garage[1],garages[i].garage[2],garages[i].garage[3]-0.5, 0,0,0,0,0,0, 1.5, 1.5, 1.5001, garages[i].rgb[1],garages[i].rgb[2],garages[i].rgb[3], 200, 0, 1, 0, 50)
      end
      if distance(garages[i].garage[1],garages[i].garage[2],garages[i].garage[3]) < 1.7 and selecting == false then
        DrawText3Ds(garages[i].garage[1],garages[i].garage[2],garages[i].garage[3], "[~r~E~w~] ".. garages[i].garagetype .." - "..garages[i].name)
        if IsControlJustPressed(0,38) then
          local args = garages[i].permission
          HT.TriggerServerCallback("xmq:jobGaragePerm", function(result)
            if result then
              num = 1
              cx = garages[i].tp[1]
              cy = garages[i].tp[2]
              cz = garages[i].tp[3]
              ch = garages[i].tp[4]
              currx = garages[i].garage[1]
              curry = garages[i].garage[2]
              currz = garages[i].garage[3]
              currh = GetEntityHeading(PlayerPedId())
              usedg = garages[i].garageused
              currModel = garages.vehicles[usedg][1].model
              selecting = true
              spawnVehicle(cx,cy,cz,ch,currModel,false)
              Wait(10)
              FreezeEntityPosition(veh,true)
              SetPlayerInvincible(PlayerPedId(),true)
              SetEntityVisible(PlayerPedId(),false,0)
            elseif result == false then
              TriggerEvent('mythic_notify:client:SendAlert', { type = "error", text = "Ingen adgang", length = 2000})
            else
              TriggerEvent('mythic_notify:client:SendAlert', { type = "error", text = "Fejl: Kontakt udvikler", length = 5000})
            end
          end, args)
          Wait(10)
        end
      elseif distance(garages[i].tp[1],garages[i].tp[2],garages[i].tp[3]) < 2 and selecting == true then
        if IsControlJustPressed(0,177) then
          DeleteEntity(veh)
          veh = nil
          FreezeEntityPosition(PlayerPedId(),false)
          SetPlayerInvincible(PlayerPedId(),false)
          SetEntityVisible(PlayerPedId(),true,0)
          FreezeEntityPosition(veh,false)
          selecting = false
          SetEntityCoords(PlayerPedId(),currx,curry,currz-0.95)
          SetEntityHeading(PlayerPedId(),currh)
        end
      end
      if distance(garages[i].parker[1],garages[i].parker[2],garages[i].parker[3]) < 10.0 then
        if IsPedInVehicle(PlayerPedId(), GetVehiclePedIsIn(PlayerPedId(), false), false) then
          DrawMarker(1, garages[i].parker[1],garages[i].parker[2],garages[i].parker[3]-1, 0,0,0,0,0,0, 3.0,3.0,1.0,255,255,255, 200,false,false,0,false)
          if distance(garages[i].parker[1],garages[i].parker[2],garages[i].parker[3]) < 3.0 then
            DrawText3Ds(garages[i].parker[1],garages[i].parker[2],garages[i].parker[3], "[~r~E~w~] Parker køretøj")
            SetHornEnabled(GetVehiclePedIsIn(PlayerPedId(),false),false)
            if IsControlJustPressed(0,38) then
              DeleteEntity(GetVehiclePedIsIn(PlayerPedId(),false))
              TriggerEvent('mythic_notify:client:SendAlert', { type = "inform", text = "Parkerede køretøj", length = 2000})
            end
          end
        end
      end
      if selecting == true then
        if IsControlJustPressed(0,189) then
          if num > 1 then
            num = num-1
            currModel = garages.vehicles[usedg][num].model
          elseif num <= 1 then
            num = #garages.vehicles[usedg]
            currModel = garages.vehicles[usedg][num].model
          end
          spawnVehicle(cx,cy,cz,ch,currModel,false)
        end

        if IsControlJustPressed(0,190) then
          if num == #garages.vehicles[usedg] then
            num = 1
            currModel = garages.vehicles[usedg][num].model
          elseif num < #garages.vehicles[usedg] then
            num = num+1
            currModel = garages.vehicles[usedg][num].model
          end

          spawnVehicle(cx,cy,cz,ch,currModel,false)
        end

        drawTxt("~r~Model: ~w~"..garages.vehicles[usedg][num].name,4, 0, 0.4, 0.77, 0.5, 200, 0, 55, 255)
        drawTxt("~r~Estimeret topfart: ~w~"..round(math.floor(GetVehicleModelEstimatedMaxSpeed(GetHashKey(garages.vehicles[usedg][num].model))*4),1).." KMT",4, 0, 0.4, 0.8, 0.5, 200, 0, 55, 255)
        DisplayHelpTextThisFrame([[~r~[G]~w~ Vælg køretøj
~r~[←- -→]~w~ Skift køretøj
~r~[BACKSPACE]~w~ Luk menu]], 0)
        if IsControlJustPressed(0,47) then
          spawnVehicle(cx,cy,cz,ch,currModel,true)
          freezeveh = false
          FreezeEntityPosition(PlayerPedId(),false)
          SetPlayerInvincible(PlayerPedId(),false)
          SetEntityVisible(PlayerPedId(),true,0)
          FreezeEntityPosition(veh,false)
          selecting = false
          TriggerEvent('mythic_notify:client:SendAlert', { type = "success", text = "God tur", length = 5000})
        end
      end
    end
    if freezeveh == true then
      FreezeEntityPosition(veh,true)
    end
  end)
end

function spawnVehicle(x,y,z,h,vmodel,nw)
  hkey = GetHashKey(vmodel)
  RequestModel(hkey)
	while not HasModelLoaded(hkey) do
		Wait(5)
	end
  if veh == nil then
      veh = CreateVehicle(hkey,x,y,z,h,nw,false)
      FreezeEntityPosition(veh,true)
      Wait(10)
      TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1)
  else
      DeleteEntity(veh)
      SetModelAsNoLongerNeeded(veh)
      Wait(20)
      veh = CreateVehicle(hkey,x,y,z,h,nw,false)
      SetEntityAsMissionEntity(veh,false,false)
      FreezeEntityPosition(veh,true)
      TaskWarpPedIntoVehicle(PlayerPedId(),veh,-1)
  end
end

