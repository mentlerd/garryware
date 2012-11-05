
AddCSLuaFile()

ZERO = Vector(0,0,0)

function net.ReadBool()
	return net.ReadBit() == 1
end

function net.WriteBool( bool )
	return net.WriteBit( bool )
end	

function net.ReadAny()
	return net.ReadType( net.ReadUInt( 8 ) )
end

if ( CLIENT ) then
	local meta = FindMetaTable( "CLuaParticle" )

	function meta:SetAlpha( a, b )
		self:SetStartAlpha( a )
		self:SetEndAlpha( b )
	end

	function meta:SetSize( a, b )
		self:SetStartSize( a )
		self:SetEndSize( b )
	end

else
	local meta = FindMetaTable( "Entity" )
	
	function meta:RandomYaw()
		self:SetAngles( Angle( 0, math.random( 0, 360 ), 0 ) )
	end
	
	function meta:EnableMotion( state )
		local phys = self:GetPhysicsObject()
	
		if ( IsValid( phys ) ) then
			phys:EnableMotion( state )
		end
	end
	
	function meta:Trail( mat, color, sW, eW, life, additive, att )
		return util.SpriteTrail( self, att or 0, color, additive, sW, eW, life, 2 / (sW + eW), mat )
	end
	
end
