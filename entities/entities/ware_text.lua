
AddCSLuaFile()

ENT.Base	= "base_anim"

function ENT:SetupDataTables()
	self:NetworkVar( "String", 0, "Text" )
	self:NetworkVar( "Vector", 0, "DefaultColor" )
end

if ( SERVER ) then
	
	function ENT:Initialize()
		self:SetModel( "models/props_junk/wood_crate001a.mdl" )
		
		self:PhysicsInit( SOLID_VPHYSICS )
		self:SetMoveType( MOVETYPE_VPHYSICS )
		self:SetSolid( SOLID_VPHYSICS )
		
		self:SetHealth( 100000 )
	
		local phys = self:GetPhysicsObject()
		if ( IsValid( phys ) ) then
			phys:EnableMotion( false )
			phys:Wake()
		end
	end

	util.AddNetworkString( "ware_TextColor" )
	util.AddNetworkString( "ware_TextHide" )
	
	function ENT:SetTextColor( color )
		self:SetNWVector( "DefaultColor", Vector( color.r, color.g, color.b ) )
	end
	
	function ENT:SendTextColor( ply, color )
		net.Start( "ware_TextColor" )
			net.WriteEntity( self )
			net.WriteTable( color )
		net.Send( ply )
	end
		
	function ENT:SetHidden( hide, ply )
		net.Start( "ware_TextHide" )
			net.WriteEntity( self )
			net.WriteBool( hide )
			
		if ( ply ) then
			net.Send( ply )
		else
			net.Broadcast()
		end
	end
	
else
		
	surface.CreateFont( "WareText_48", {
		font	= "coolvetica",
		size 	= 48,
		weight	= 400,
	} )

	local DARK 				= Color( 10, 10, 10 )
	local WHITE_VEC			= Vector( 255, 255, 255 )
	
	local TextCache			= {}
	local TextCacheIsDirty	= false
	
	ENT.RenderGroup		= RENDERGROUP_TRANSLUCENT
	ENT.TextColor		= Color( 255, 255, 255 )

	function ENT:Initialize()
		TextCacheIsDirty  = true
	end
	
	function ENT:DrawTranslucent()
		if ( !self.IsHidden ) then
			render.SetBlend( 0.8 )
				self:DrawModel()
			render.SetBlend( 1 )
		else
			self:DrawModel()
		end
	end
	
	function ENT:DrawOnScreen()
		if ( self.IsHidden ) then return end

		local pos	= self:GetPos():ToScreen()
		local color	= self.ColorOverride or self:GetNWVector( "DefaultColor", WHITE_VEC ):ToColor()
	
		draw.SimpleTextOutlined( self:GetText(), "WareText_48",	pos.x, pos.y, color, TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER, 2, DARK )
	end
	
	net.Receive( "ware_TextColor", function()
		local ent = net.ReadEntity()

		if ( IsValid( ent ) ) then
			ent.ColorOverride = net.ReadTable()
		end
	end )
	
	net.Receive( "ware_TextHide", function()
		local ent = net.ReadEntity()
		
		if ( IsValid( ent ) ) then
			ent.IsHidden = net.ReadBool()
		end
	end )
	
	hook.Add( "HUDPaint", "WareText_Overlay", function()
		if ( TextCacheIsDirty ) then
			TextCache			= ents.FindByClass( "ware_text" )
			TextCacheIsDirty 	= false
		end
	
		for key, ent in pairs( TextCache ) do
			if ( IsValid( ent ) ) then
				ent:DrawOnScreen()
			else
				table.remove( TextCache, key )
			end
		end
	end )

end
