
surface.CreateFont( "ware_Instruction", {
	font	= "Trebuchet MS",	
	size	= 36,
} )

local PANEL = {}

local CENTER	= TEXT_ALIGN_CENTER

PANEL.AppearDuration	= 0.16
PANEL.RemainDuration	= 5

PANEL.Border	= 4
PANEL.Expand	= 2

PANEL.ColBorder		=	Color( 255, 255, 255, 128 )

function PANEL:Init()
	self:SetText( "Empty" )
end

function PANEL:SetText( text, bgColor, fgColor, life )
	self.Creation	= CurTime()
	self.Text		= text or "-"
	self.Lifetime	= life or 30
	
	self.ColBackground	= bgColor or Color( 100, 200, 100, 192 )
	self.ColForeground	= fgColor or Color( 255, 255, 255, 255 )
	
	surface.SetFont( "ware_Instruction" )
	self.TextW, self.TextH = surface.GetTextSize( self.Text )
	
	local wide	= self.TextW + 40 + self.Border * ( 2 + self.Expand ) * 2
	local tall	= self.TextH + 	 	self.Border * ( 1 + self.Expand ) * 2
	
	self:SetPos( (ScrW() - wide) /2, ScrH() * (10 / 16) - tall /2 )
	self:SetSize( wide, tall )
	
	self:SetVisible( true )
	self:InvalidateLayout()
end

function PANEL:Paint( w, h )
	local life = CurTime() - self.Creation
	
	if ( life > self.Lifetime ) then return false end

	local isOpaque = life > self.AppearDuration
	
	local visRate = isOpaque and ( 1 - (life / self.RemainDuration) ^3 ) or (life / self.AppearDuration)
	local sclSize = isOpaque and 0 or ( (1 - life / self.AppearDuration) * self.Border * self.Expand )
	
	self.ColBorder.a		= 220 * visRate
	self.ColForeground.a	= 255 * ( isOpaque and visRate or 1 )
	self.ColBackground.a	= 255 * visRate
	
	local fOff = ( self.Border * ( 1 + self.Expand ) ) 	- sclSize
	local bOff = ( self.Border * self.Expand ) 			- sclSize

	local fW = ( self.TextW +40 ) 	+ sclSize * self.Expand
	local fH = ( self.TextH +2  )	+ sclSize * self.Expand
	
	local bW = ( fW + self.Border *2 ) + sclSize * self.Expand
	local bH = ( fH + self.Border *2 ) + sclSize * self.Expand
	
	draw.RoundedBox(self.Border, bOff, bOff, bW, bH, self.ColBorder)
	draw.RoundedBox(self.Border, fOff, fOff, fW, fH, self.ColBackground)
	
	draw.SimpleText( self.Text, "ware_Instruction", w/2, h/2, self.ColForeground, CENTER, CENTER )
	
	return true
end

vgui.Register( "WScreenPopup", PANEL, "DPanel" )