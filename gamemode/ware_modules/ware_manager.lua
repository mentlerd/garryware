
--[[
	Static Info:
		WARE.Author
		WARE.Name
		
		WARE.Room			= "plain"
		WARE.Type			= "generic"
		
		WARE.PrecacheModels	= {}
		
		WARE.MinPlayers		= 1
		WARE.MaxPlayers		= -1
		
		WARE.DefaultRole	= -1
		WARE.DieOnLose		= false
		
		WARE.InitialState	= false
		WARE.HideStates		= false
		
		WARE.Windup			= 6
		WARE.Phases			= { 10, 10, 30 }
		
	Functions
		WARE:ForceNoAnnouncer()
	
		WARE:ForceNextPhase()
		WARE:GetPhase()
		
		WARE:Instruction( text, [bgColor], [fgColor] [filter] )
		WARE:RoleInstruction( text, role, [bgColor], [fgColor] )
		
		Player:IsWarePlayer()
		
		Player:ApplyWin( noLock )
		Player:ApplyLose( noLock )
		
		Player:SetLocked()
		Player:IsLocked()
		
		Player:SetRole( id )
		Player:GetRole()
	
		Player:IsFakingDeath()
	
		Player:SimulateDeath()
		Player:RestoreDeath()
	
	Callbacks:
		WARE:IsPlayable()
		
		WARE:Initialize()
		
		WARE:StartAction()
		
		WARE:PhaseStart( id )
		WARE:PhaseEnds( id )

		WARE:EndAction()
		
		WARE:Think( phase, remain )
]]--

module( "ware_manager", package.seeall )

local minigames = {}

local meta	= {}
	
	--meta.__metatable 	= true
	meta.__index 		= function( self, index )
		local value = rawget( meta, index )
	
		if ( value == nil ) then
			return rawget( self, index )
		end

		return value
	end

_G.BASE = meta
	include( "ware_base.lua" )
	include( "ware_utils.lua" )
	include( "ware_globals.lua" )
_G.BASE = nil

function Register( name, ware )
	ware.Name = ware.Name or name
	ware.ID	  = name
				
	if ( !ware.Initialize ) then
		ErrorNoHalt( "Invalid minigame '" .. ware.Name .. "' ! Missing Initialize!" )
		return
	end
	
	if ( !ware.Phases ) then
		ware.Phases = { ware.Length }
	end
	
	minigames[ware.Name] = ware
	
	return ware
end

function GetAll()
	return minigames
end

function NewInstance( name )
	if ( !minigames[name] ) then return nil end
	
	local game = table.Copy( minigames[name] )
		setmetatable( game, meta )
		
	return game	
end

function GenerateSequence()
	local names = {}
	
	for name, _ in pairs( minigames ) do
		table.insert( names, name )
	end

	local count = #names

	local occurs	= {}	
	local sequence	= {}
	
	while( count > 0 ) do
		local wareID = math.random( 1, count )
		local name = names[wareID]

		local maxReps = minigames[name].OccurencesPerCycle
		
		if ( maxReps ) then			
			occurs[name] = ( occurs[name] or 0 ) +1
		
			if ( maxReps <= occurs[name] ) then
				count = count -1
				table.remove( names, wareID )
			end
			
			if ( maxReps <= 0 ) then
				continue
			end
		else
			count = count -1
			table.remove( names, wareID )
		end
		
		table.insert( sequence, NewInstance( name ) )
	end

	return sequence
end
