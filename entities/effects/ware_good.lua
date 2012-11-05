

function EFFECT:Init( data )
	local origin = data:GetOrigin()
	
	local emitter = ParticleEmitter( origin )
	
	for index = 1, 20 do
		local particle = emitter:Add( "effects/yellowflare", origin + VectorRand() * 5)
		
		particle:SetColor( 0, 170, 0 )
		
		particle:SetAlpha( 250, 0 )
		particle:SetSize( math.random(5, 10), 0 )
	
		particle:SetDieTime( math.random(1, 3) )
		particle:SetVelocity( VectorRand() * 100 + Vector(0,0,50) )
		
		particle:SetBounce( 2 )
		particle:SetGravity( Vector(0, 0, -150) )

		particle:SetCollide( true )
	end
	
	local particle = emitter:Add( "effects/yellowflare", origin )
	
	particle:SetColor( 0, 170, 0 )
	
	particle:SetAlpha( 250, 0 )
	particle:SetSize( 100, 0 )
	
	particle:SetDieTime( 2 )
	particle:SetVelocity( ZERO )

	particle:SetBounce( 0 )
	particle:SetGravity( ZERO )
	
	emitter:Finish()
end

function EFFECT:Think( )
	return false	
end

function EFFECT:Render()	
end