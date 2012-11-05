
util.AddNetworkString( "ware_WareTimes" )

function GM:ReportWareTimes()
	if ( !self.Ware ) then return end
	
	net.Start( "ware_WareTimes" )
		net.WriteInt( self.Ware.Windup, 8 )
		net.WriteTable( self.Ware.Phases )
	net.Broadcast()
end


util.AddNetworkString( "ware_WarePhase" )

function GM:ReportWarePhase()
	if ( !self.Ware ) then return end

	net.Start( "ware_WarePhase" )
		net.WriteBool( self.Ware.IsPlaying )
		net.WriteInt( self.Ware.Phase or -1, 8 )
	net.Broadcast()
end
