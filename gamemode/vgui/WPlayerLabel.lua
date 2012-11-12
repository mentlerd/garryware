
local BLACK			= Color( 0, 0, 0 )
local WHITE			= Color( 255, 255, 255 )

local CENTER		= TEXT_ALIGN_CENTER

surface.CreateFont( "WareText_16", {
		font	= "Trebuchet MS",
		size 	= 16,
		weight	= 600,
		
		outline = true,
		antialias = false
} )

local default	= Material( "vgui/avatar_default" )
local avatar	= Material( "ware/interface/avatar_default.png" )
	default:SetTexture( "$basetexture", avatar:GetTexture( "$basetexture" ) )
	
/*
do
	local matArrowInner	= Material( "ware/interface/arrow_inner.png", MAT_SMOOTH )
	local matArrowOuter	= Material( "ware/interface/arrow_outer.png", MAT_SMOOTH )
	
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
*/

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
		self.Label:SetFont( "WareText_16" )
		self.Label:SetTextInset( 1,0 )

		self.Label:SetColor( WHITE )
		
	self.Avatar	= vgui.Create( "AvatarImage", self )
	
	self.Color			= self.ColorWin
	self.BorderColor	= WHITE
	
	self:SetMinimumSize( 200, 20 )
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
	
	self.Avatar:SetSize( h, h )

	self.Label:SetPos( h + 10, 1 )
	self.Label:SetSize( w, h )
end

function PANEL:Paint( w, h )
	
	draw.RoundedBox(4, h +4, 2, w -h -4, h -4, self.BorderColor)
	draw.RoundedBox(2, h +5, 3, w -h -6, h -6, self.Color)
	
	local x = w -100

	if ( self.first ) then	-- TODO: This should be told by the server!
		draw.RoundedBox( 4, x -22, 0, 20, 20, self.BorderColor )
		draw.RoundedBox( 4, x -21, 1, 18, 18, self.Color )
		
		surface.SetDrawColor( WHITE )
		surface.SetMaterial( matWinner )
		surface.DrawTexturedRect( x -20, 2, 16, 16 )
	end

	draw.RoundedBox( 4, x, 0, 92, h, self.BorderColor )
	
	draw.RoundedBox( 4, x +1,  1, 45, h -2, self.ColorWin )
	draw.RoundedBox( 4, x +46, 1, 45, h -2, self.ColorStreak )
	
	surface.SetDrawColor( self.ColorFail )
	surface.DrawRect( x +32, 1, 30, h -2 )
	
	surface.SetDrawColor( self.BorderColor )
	surface.DrawLine( x +31, 0, x +32, h )
	surface.DrawLine( x +61, 0, x +62, h )
	
	draw.SimpleText( "99", "WareText_16", x+17, h/2 +1, WHITE, CENTER, CENTER )
	draw.SimpleText( "99", "WareText_16", x+47, h/2 +1, WHITE, CENTER, CENTER )
	draw.SimpleText( "99", "WareText_16", x+77, h/2 +1, WHITE, CENTER, CENTER )
	
	return true
end

vgui.Register( "WPlayerLabel", PANEL, "DPanel" )

