
util.AddNetworkString( "ware_WareInfo" )

function GM:ReportWareInfo()
	if ( !self.Ware ) then return end
	
	net.Start( "ware_WareInfo" )
		net.WriteInt( self.Ware.Windup, 8 )
	net.Broadcast()
end


util.AddNetworkString( "ware_WarePhase" )

function GM:ReportWarePhase()
	if ( !self.Ware ) then return end

	net.Start( "ware_WarePhase" )
		net.WriteBool( self.Ware.IsPlaying )
		
		net.WriteInt( self.Ware.Phase		or -1, 8 )
		
		if ( self.Ware.NextPhase ) then
			net.WriteInt( self.Ware.NextPhase - CurTime(), 8 )
		else
			net.WriteInt( -1, 8 )
		end
	net.Broadcast()
end
