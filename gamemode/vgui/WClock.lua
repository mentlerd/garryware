
local PANEL = {}

PANEL.MatClock		= Material( "ware/interface/clock.png",			MAT_SMOOTH )
PANEL.MatShade		= Material( "ware/interface/clock_shade.png",	MAT_SMOOTH )
PANEL.MatTrotter	= Material( "ware/interface/clock_trotter.png", MAT_SMOOTH )

PANEL.StartAngle	= 15

PANEL.ColorPreRound 	= Color( 255, 255, 255 )
PANEL.ColorWarmup		= Color( 255, 245, 165 )

PANEL.ColorStateHidden	= Color( 166, 225, 225 )

PANEL.ColorWinPending	= Color( 170, 235, 255 )
PANEL.ColorWin			= Color(  60, 180, 244 )

PANEL.ColorLosePending	= Color( 250, 213, 213 )
PANEL.ColorLose			= Color( 255, 155, 155 )

PANEL.ColorFallback		= Color( 0, 255, 0 )

function PANEL:GetStatusColor()
	local ply = LocalPlayer()
	
	local state	= ply:GetState()
	local lock	= ply:IsLocked()
	
	if ( false ) then	-- CurTime() < gws_NextgameStart		TODO
		return self.ColorPreRound
	elseif ( false ) then	-- CurTime() < gws_NextwarmupEnd		TODO
		return self.ColorWarmup
	elseif ( state == nil ) then
		return self.ColorStateHidden
	end
		
	if ( state ) then
		if ( lock ) then
			return self.ColorWin
		else
			return self.ColorWinPending
		end
	else
		if ( lock ) then
			return self.ColorLose
		else
			return self.ColorLosePending
		end
	end
	
	return self.ColorFallback
end

function PANEL:PerformLayout()
	self:SetSize( 256, 256 )
	self:SetPos( ScrW() * 0.05 -128, ScrH() * 0.95 -128 )
end

function PANEL:Paint( w, h )	
	surface.SetDrawColor( self:GetStatusColor() )

	surface.SetMaterial( self.MatClock )
	surface.DrawTexturedRectRotated( 128, 128, 256, 256, self.StartAngle )
	
	surface.SetDrawColor( 255, 255, 255, 128 )
	
	surface.SetMaterial( self.MatShade )
	surface.DrawTexturedRectRotated( 128, 128, 256, 256, self.StartAngle )

	local angle = ( 360 * 0 )
	
	surface.SetDrawColor( 255, 255, 255, 255 )
	
	surface.SetMaterial( self.MatTrotter )
	surface.DrawTexturedRectRotated( 128, 128, 256, 256, angle + self.StartAngle + 90 )	
end

vgui.Register( "WClock", PANEL, "DPanel" )