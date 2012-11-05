
local refract	= Material( "refract_ring" )

function EFFECT:Init( data )
	local origin	= data:GetOrigin()
	local normal	= data:GetNormal()
	
	local emitter = ParticleEmitter( origin )
	
	for index = 1, 20 do
		local particle = emitter:Add( "effects/yellowflare", origin + normal * 12 )
			particle:SetColor( 255, 192, 255 )
			
			particle:SetSize( math.random(5, 10), 0 )
			particle:SetAlpha( 250, 0 )
			
			particle:SetDieTime( math.random( 0.5, 1.5 ) )
			particle:SetVelocity( normal * 150 + VectorRand() * 100 )
			
			particle:SetBounce( 0.8 )
			particle:SetGravity( Vector( 0, 0, -300 ) )
		
			particle:SetCollide(true)
			particle:SetVelocityScale( true )
			
			particle:SetStartLength( 0.2 )
			particle:SetEndLength( 0 )
	end
	
	local particle = emitter:Add( "effects/yellowflare", origin )
		particle:SetColor(255,192,255)
		
		particle:SetSize( 100, 0 )
		particle:SetAlpha( 128, 0 )
		
		particle:SetDieTime( 0.4 )
		particle:SetBounce( 0 )
		
		particle:SetVelocity( ZERO )
		particle:SetGravity( ZERO )
	
	emitter:Finish()
	
	self.Refract	= 0
	self.Size		= 32
	
	local one = Vector( 1, 1, 1 )
		self:SetRenderBounds( one * -512, one * 512 )
end

function EFFECT:Think()
	self.Refract	= self.Refract + 2.0 * FrameTime()
	self.Size		= 64 * self.Refract ^ 0.2
	
	return self.Refract < 1
end

function EFFECT:Render()
	local pos	= self:GetPos()
	local dist	= ( EyePos() - pos ):Length()
	
	local origin	= pos + ( EyePos() - pos ):GetNormal() * dist * ( self.Refract ^ 0.3 ) * 0.8
	
	refract:SetFloat( "$refractamount", math.sin( self.Refract * math.pi ) * 0.1 )
	
	render.SetMaterial( refract )
	render.UpdateRefractTexture()
	
	render.DrawSprite( origin, self.Size, self.Size )
end
