
include( "shared.lua" )

AddCSLuaFile( "cl_player_extension.lua" )
AddCSLuaFile( "cl_mapdecoration.lua" )

include( "sv_player_extension.lua" )

include( "sv_network.lua" )

include( "sv_room_manager.lua" )
include( "sv_ware_manager.lua" )

include( "dev_tools.lua" )

function GM:InitPostEntity( )
	self.BaseClass:InitPostEntity()
	
	self:ReadMapRooms()
	self:LoadWareGames()

	self:StartGameSequence()
end

function GM:Think()
	self:WareThink()
	
	self:UpdatePlayerStates()
end

function GM:GravGunPickupAllowed( ply, ent )
	return !ent.GravGunBlocked
end

function GM:GravGunPunt( ply, ent )
	return !ent.GravGunBlocked
end


_HookCall = _HookCall or hook.Call

function hook.Call( name, gm, ... )
	local ware = GAMEMODE.Ware
	
	if ( ware and name != "Think" and ware[name] ) then
		local succ, override = ware:SafeCall( ware[name], ... )
	
		if ( succ and override != nil ) then 
			return override
		end
	end
	
	return _HookCall( name, gm, ... )
end
