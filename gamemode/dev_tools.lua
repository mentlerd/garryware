
timer.Simple( 10, function()
	timer.Remove( "CheckHookTimes" )

	for _, ply in pairs( player.GetAll() ) do
		ply:SendLua( [[ timer.Remove( "CheckHookTimes" ) ]] )
	end
end )

concommand.Add( "ware_debug_fastforward", function()
	if ( GAMEMODE.Ware ) then
		GAMEMODE.Ware:ForceEnd()
	end
end )

concommand.Add( "ware_debug_reinit", function()
	GAMEMODE:InitPostEntity()
	GAMEMODE.IsGameEnd = false
end )

local flags = { FCVAR_ARCHIVE }

GM.VarDebug			= CreateConVar( "ware_debug", 0, flags ) 
GM.VarDebugName		= CreateConVar( "ware_debugname", "", flags )

GM.VarDebugReload	= CreateConVar( "ware_debugreload", 0, flags )

function GM:PollNextWare()

	if ( self.VarDebug:GetBool() ) then
	
		local debugID = self.VarDebugName:GetString()
	
		if ( debugID != "" ) then
			
			if ( self.VarDebugReload:GetBool() ) then
				local path	= "../" .. self.Folder .. "/gamemode/" .. self.WarePath .. "/"
					
				WARE = {}
				include( path .. debugID .. ".lua" )
			
				if ( WARE.Room and ( WARE.Room == "*" or self:FindRoomFor( WARE.Room, WARE.MinPlayers ) ) ) then
					ware_manager.Register( debugID, WARE )		
				end
			end
			
			local ware = ware_manager.NewInstance( debugID )
			
			if ( !ware ) then
				self:Warning( "Minigame '" .. debugID .. "' not found. ware_debugname earsed!" )
				RunConsoleCommand( "ware_debugname", "" )
			else			
				return ware
			end

		end
	end

	return table.remove( self.WareSequence )
end
