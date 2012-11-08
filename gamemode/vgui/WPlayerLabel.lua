
local BLACK			= Color( 0, 0, 0 )
local WHITE			= Color( 255, 255, 255 )

surface.CreateFont( "WareText_16", {
		font	= "Trebuchet MS",
		size 	= 20,
		weight	= 400,
} )

do
	local matArrowInner	= Material( "ware/interface/arrow_inner.png", MAT_SMOOTH )
	local matArrowOuter	= Material( "ware/interface/arrow_outer.png", MAT_SMOOTH )
	
	local CENTER		= TEXT_ALIGN_CENTER
	
	function surface.DrawArrow( x, y, h, inner, outer, text )
		local w = h/64 * 100
		
		if ( outer ) then
			surface.SetDrawColor( outer )
		
			surface.SetMaterial( matArrowOuter )
			surface.DrawTexturedRect( x, y, w, h )
		end
		
		surface.SetDrawColor( inner or WHITE )
	
		surface.SetMaterial( matArrowInner )
		surface.DrawTexturedRect( x, y, w, h )
		
		if ( text ) then
			draw.SimpleText( text, "WareText_16", x + w/2, y + h/2, outer or WHITE, CENTER, CENTER )
		end		
	end
end

local PANEL = {}

local matWinner		= Material( "icon16/award_star_gold_1.png", MAT_SMOOTH )

PANEL.ColorWin		= Color(   0, 165, 238 )
PANEL.ColorFail		= Color( 255,  88,  88 )
PANEL.ColorMystery	= Color(  90, 220, 220 )

PANEL.ColorStreak	= Color( 255, 165,  90 )

PANEL.ColorLocked	= Color( 255, 255, 255, 192 )
PANEL.ColorUnLocked	= Color( 0, 0, 0, 128 )

function PANEL:Init()
	self.Label	= vgui.Create( "DLabel", self )
		self.Label:SetColor( WHITE )
		self.Label:SetFont( "WareText_16" )

	self.Avatar	= vgui.Create( "AvatarImage", self )
	
	self.Color			= self.ColorWin
	self.BorderColor	= WHITE
	
	self:SetMinimumSize( 200, 32 )
end

function PANEL:SetPlayer( ply )
	if ( !IsValid( ply ) ) then return end

	self.Avatar:SetPlayer( ply, 32 )
	self.Label:SetText( ply:GetName() )
	
	self.Player = ply

	self:RefreshPlayerState()
end

function PANEL:RefreshPlayerState()
	if ( !IsValid( self.Player ) ) then return end

	local state = self.Player:GetState()
	local lock	= self.Player:IsLocked()
	
	if ( state == nil ) then
		self.Color	= self.ColorMystery
	else
		self.Color	= state and self.ColorWin or self.ColorFail
	end
	
	self.BorderColor = lock and BLACK or WHITE
end

function PANEL:PerformLayout()
	local w, h = self:GetSize()
	
	self.Avatar:SetPos( 2, 1 )
	self.Avatar:SetSize( h -2, h -2 )

	self.Label:SetPos( h + 8, 0 )
	self.Label:SetSize( w, h )
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox(4, 0, 0, w, h, self.BorderColor)
	draw.RoundedBox(4, h +2, 2, w -h -4, h -4, self.Color)
	
	if ( false ) then	-- TODO: First?
		surface.SetDrawColor( WHITE )
		surface.SetMaterial( matWinner )
		
		surface.DrawTexturedRect( w - 130, 2, 20, 20 )
	end
	
	surface.DrawArrow( w -110, 0, h, self.ColorWin,		WHITE, 10 )
	surface.DrawArrow( w -80,  0, h, self.ColorFail,	WHITE, 1 )
	surface.DrawArrow( w -50,  0, h, self.ColorStreak,	WHITE, 4 )
			
	return true
end

vgui.Register( "WPlayerLabel", PANEL, "DPanel" )
