
-- TODO: Separate these, as the old code does
-- TODO: Multiple announcer support, ability to disable the announcer

GM.TickHigh	= Sound( "ware/countdown_tick_high.wav" )
GM.TickLow	= Sound( "ware/countdown_tick_low.wav" )

GM.Announcer = {
	Sound( "ware/countdown_ann_sec1.mp3" ),
	Sound( "ware/countdown_ann_sec2.mp3" ),
	Sound( "ware/countdown_ann_sec3.mp3" )
}

if ( file.Exists( "sound/vo/announcer_begins_1sec.wav", "GAME" ) ) then
	GM.Announcer = {
		Sound( "vo/announcer_begins_1sec.wav" ),
		Sound( "vo/announcer_begins_2sec.wav" ),
		Sound( "vo/announcer_begins_3sec.wav" )
	}
end

GM.WareIsPlaying	= false
GM.WareInWindup		= false

function GM:Think()
	
	if ( self.ClockTime != nil ) then
		local left	= self.ClockEnd - CurTime()
		
		if ( left <= 0 ) then
			self.ClockTime		= nil
			self.ClockPercent	= 0
		else
			self.ClockPercent = left / self.ClockTime
		
			if ( !self.WareInWindup ) then
				local tick = math.ceil( left *3 )
				
				if ( tick < self.ClockLastTick ) then
					self.ClockLastTick = tick
				
					if ( left < 3 and tick % 3 == 0 ) then
						surface.PlaySound( self.Announcer[tick / 3] )
					end
					
					if ( left < 5 ) then
						surface.PlaySound( (tick % 2 == 0 ) and self.TickHigh or self.TickLow )
					end

				end
			end	
		end
	end
	
end

function GM:SetClockTime( sec )
	self.ClockTime		= sec

	if ( sec != nil ) then
		self.ClockEnd		= CurTime() + sec
		self.ClockLastTick	= 100
	end
end

function GM:OnWareReported( windup, phases )
	self.WareWindup		= windup
	self.WarePhases		= phases

	self.WareIsPlaying		= false
	self.WareInWindup		= true
	
	self:SetClockTime( self.WareWindup )
end

function GM:OnPhaseReported( isPlaying, phase, length )
	if ( self.WareIsPlaying != isPlaying ) then		
		self.WareIsPlaying = isPlaying

		if ( isPlaying ) then
			self.WareInWindup	= false
			
			-- TODO SOUND
		else
			-- TODO SOUND
		end
	end
	
	if ( length != -1 ) then
		self:SetClockTime( length )
	end
end

net.Receive( "ware_WareInfo", function()
	GAMEMODE:OnWareReported( net.ReadInt( 8 ) )
end )

net.Receive( "ware_WarePhase", function()
	GAMEMODE:OnPhaseReported( net.ReadBool(), net.ReadInt( 8 ), net.ReadInt( 8 ) )
end )
