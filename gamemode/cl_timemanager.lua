
GM.Announcers = {
	{
		"ware/countdown_dos_sec1.mp3",
		"ware/countdown_dos_sec2.mp3",
		"ware/countdown_dos_sec3.mp3",
		"ware/countdown_dos_sec4.mp3",
		"ware/countdown_dos_sec5.mp3"
	},
	{	-- TF2 Rulz		TODO: Fallback, and multiple announcer support!
		"vo/announcer_begins_1sec.wav",
		"vo/announcer_begins_2sec.wav",
		"vo/announcer_begins_3sec.wav",
		"vo/announcer_begins_4sec.wav",
		"vo/announcer_begins_5sec.wav"
	},
}

GM.WareIsPlaying	= false
GM.WareInWindup		= false

GM.WarePhases			= {}
GM.WareHasAnnouncer		= true

function GM:Think()
	
	if ( self.ClockTime != nil ) then
		local left	= self.ClockEnd - CurTime()
		local sec	= math.ceil( left )
		
		if ( sec <= 0 ) then
			self.ClockTime		= nil
			self.ClockPercent	= 0
		else
			if ( !self.WareInWindup and self.WareHasAnnouncer ) then
				if ( sec <= 5 and self.ClockAnnounced != sec ) then
					surface.PlaySound( self.Announcers[2][sec] )	-- TODO: Fallback and multiple announcer support
				
					self.ClockAnnounced = sec
				end
			end
			
			self.ClockPercent = left / self.ClockTime
		end
	end
	
end

function GM:SetClockTime( sec )
	self.ClockTime		= sec

	MsgN( "ClockTime = " .. tostring( sec ) )
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
	
	self:SetClockTime( windup )
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
