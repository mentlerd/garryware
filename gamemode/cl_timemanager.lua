
-- TODO: Separate these, as the old code does
GM.Announcers = {
	{	
		Sound( "ware/countdown_ann_sec1.mp3" ),
		Sound( "ware/countdown_ann_sec2.mp3" ),
		Sound( "ware/countdown_ann_sec3.mp3" ),
		Sound( "ware/countdown_ann_sec4.mp3" ),
		Sound( "ware/countdown_ann_sec5.mp3" )
	},
	{
		Sound( "ware/countdown_tick_high.wav" ),
		Sound( "ware/countdown_tick_low.wav"  ),
		Sound( "ware/countdown_tick_high.wav" ),
		Sound( "ware/countdown_tick_low.wav"  ),
		Sound( "ware/countdown_tick_high.wav" )
	}
}

if ( file.Exists( "sound/vo/announcer_begins_1sec.wav", "GAME" ) ) then
	GM.Announcers[1] = {
		Sound( "vo/announcer_begins_1sec.wav" ),
		Sound( "vo/announcer_begins_2sec.wav" ),
		Sound( "vo/announcer_begins_3sec.wav" ),
		Sound( "vo/announcer_begins_4sec.wav" ),
		Sound( "vo/announcer_begins_5sec.wav" )
	}
end


GM.WareIsPlaying	= false
GM.WareInWindup		= false

GM.WarePhases			= {}
GM.WareAnnouncer		= 1

function GM:Think()
	
	if ( self.ClockTime != nil ) then
		local left	= self.ClockEnd - CurTime()
		local sec	= math.ceil( left )
		
		if ( sec <= 0 ) then
			self.ClockTime		= nil
			self.ClockPercent	= 0
		else
			if ( !self.WareInWindup and self.WareAnnouncer > 0 ) then
				if ( sec <= 5 and self.ClockAnnounced != sec ) then
					surface.PlaySound( self.Announcers[self.WareAnnouncer][sec] )
					self.ClockAnnounced = sec
				end
			end
			
			self.ClockPercent = left / self.ClockTime
		end
	end
	
end

function GM:SetClockTime( sec )
	self.ClockTime		= sec

	if ( sec != nil ) then
		self.ClockEnd		= CurTime() + sec
		self.ClockAnnounced	= 0
	end
end

function GM:OnWareReported( windup, phases )
	self.WareWindup		= windup
	self.WarePhases		= phases

	self.WareIsPlaying		= false
	self.WareInWindup		= true
	
	self:SetClockTime( self.WareWindup )
end

function GM:OnPhaseReported( isPlaying, phase )
	if ( self.WareIsPlaying != isPlaying ) then		
		self.WareIsPlaying = isPlaying

		if ( isPlaying ) then
			self.WareInWindup	= false
			
			-- TODO SOUND
		else
			-- TODO SOUND
		end
	end
	
	self:SetClockTime( self.WarePhases[phase +1] )
end

net.Receive( "ware_WareInfo", function()
	GAMEMODE:OnWareReported( net.ReadInt( 8 ), net.ReadTable() )
end )

net.Receive( "ware_WarePhase", function()
	GAMEMODE:OnPhaseReported( net.ReadBool(), net.ReadInt( 8 ) )
end )
