
include( "ware_modules/ware_manager.lua" )


GM.WarePath	= "minigames"

--[[
	= Ware Loading =
]]--

function GM:LoadWareGames()
	local base	= self.Folder .. "/gamemode/" .. self.WarePath .. "/"
	local games = file.Find( base .. "*", "GAME" )
		
	MsgN( "Loading minigames..." )
	for _, game in pairs( games ) do
		WARE = {}

		include( "../" .. base .. game )
		
		local id = game:StripExtension()
			Msg( " - " .. id .. "\t" )

		if ( WARE.Room and ( WARE.Room == "*" or self:FindRoomFor( WARE.Room, WARE.MinPlayers ) ) ) then
			ware_manager.Register( game:StripExtension(), WARE )		
			MsgN( "OK!" )
		else
			MsgN( "Incompatible map! ( Missing room '" .. tostring( WARE.Room ) .. "' )" )
		end
	end
end

function GM:BuildPrecacheHash()
	self.ModelPrecacheHash	= {}

	for _, game in pairs( ware_manager.GetAll() ) do
		if ( game.Models ) then
			
			for _, mdl in pairs( game.Models ) do
				self.ModelPrecacheHash[mdl] = true
			end
		end
	end
	
	for mdl, _ in pairs( self.ModelPrecacheHash ) do
		util.PrecacheModel( mdl )
	end
end

--[[
	Initialization
]]--

function GM:StartGameSequence()
	self:BuildPrecacheHash()

	self.WareSequence 	= ware_manager.GenerateSequence()
		table.insert( self.WareSequence, ware_manager.NewInstance( "intro" ) )
	
	self.NextWareStart	= CurTime() + 4
end

--[[
	Game Loop
]]--

SetGlobalBool( "IsGameEnd", false )

function GM:PollNextWare()
	return table.remove( self.WareSequence )
end

function GM:WareThink()
	if ( GetGlobalBool( "IsGameEnd", false ) ) then return end
	
	if ( self.Ware ) then
		if ( !self.Ware.IsPlaying ) then	
			self.LastWare 	= self.Ware
			self.Ware		= nil
			
			self.NextWareStart = CurTime() + 4
		else
			self.Ware:InternalThink()
		end
	else
		if ( !self.WareSequence ) then return end
	
		if ( self.NextWareStart < CurTime() ) then
			
			if ( self.LastWare ) then
				self.LastWare:Cleanup()
				self.LastWare = nil
				return
			end

			while( !self.Ware ) do		
				self.Ware = self:PollNextWare()
				
				if ( !self.Ware ) then
					MsgN( "No wares left, game ended" )
					
					SetGlobalBool( "IsGameEnd", true )
					return
				end
				
				if ( !self.Ware:Setup() ) then
					self:Warning( self.Ware.ID .. " failed to initialize!" )
					self.Ware = nil
					
					self.NextWareStart = CurTime() +4
					return
				end
			end
			
		end
	end
end

function GM:PlayerStateLock( ply, state )
	for _, ply in pairs( self.Ware:GetPlayers() ) do
		if ( !ply:IsLocked() ) then return end
	end

	self.Ware:ForceEnd()
end

--[[
	Utilities
]]--

function GM:AddToTrash( ent )
	local ware = self.Ware or self.LastWare

	if ( ware ) then
		ware:AddToTrash( ent )
	end
end

