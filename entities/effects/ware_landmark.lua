

function EFFECT:Init( data )
	local origin = data:GetOrigin( ) 
	
	local emitter = ParticleEmitter( origin )
	
	for index = 1, 50 do
		local particle = emitter:Add( "effects/yellowflare", origin + VectorRand() * 5)
		
		particle:SetColor( 119, 199, 255 )
		
		particle:SetAlpha( 250, 0 )
		particle:SetSize( math.random(5, 12), 0 )
		
		particle:SetDieTime( 2.7 )
		particle:SetVelocity( VectorRand() * math.random(64, 92) )
		
		particle:SetRoll( (math.random(0, 1) * 2 - 1) * math.random(20, 40) )
		
		particle:SetStartLength( 164 )
		particle:SetEndLength( 128 )
		
	end
	
	emitter:Finish( )
	
end

function EFFECT:Think( )
	return false
end

function EFFECT:Render( )

end
