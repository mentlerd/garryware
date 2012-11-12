
local meta = FindMetaTable( "Player" )

function meta:PushRagdoll( vector, bone )	
	local ragdoll = self:GetRagdollEntity()
	if ( !IsValid( ragdoll ) ) then return end
	
	local phys = ragdoll:GetPhysicsObject()
		
	if ( bone >= 0 ) then
		phys = ragdoll:GetPhysicsObjectNum( bone )
	end
	
	if ( IsValid( phys ) ) then
		phys:SetVelocity( vector )
		phys:Wake()
	end
end

net.Receive( "ware_PushRagdoll", function()
	local ply = net.ReadEntity()
	local dir = net.ReadVector()
	
	local bone = net.ReadInt( 8 )

	timer.Create( "ware_PushRagdoll_" .. ply:Nick(), 0, net.ReadInt( 8 ), function()
		if ( IsValid( ply ) ) then
			ply:PushRagdoll( dir, bone )
		end
	end )
end )



function meta:IsWarePlayer()
	return true -- TODO
end

function meta:GetState()
	return self._state
end

net.Receive( "ware_StateUpdate", function()
	local states = net.ReadTable()
	
	for ply, state in pairs( states ) do
		ply._state 	= state.state
		ply._lock	= state.lock

		if ( state.lock ) then
			ply._time	= CurTime() 	-- TODO
		end
	end
	
	g_ScoreBoard:PerformScoreLayout()
end )

function meta:IsLocked()
	return self._lock
end

net.Receive( "ware_Popup", function()
	local text = net.ReadString()
	
	local bgColor = net.ReadAny()
	local fgColor = net.ReadAny()

	local life = net.ReadAny()

	g_ScreenPopup:SetText( text, bgColor, fgColor, life )
end )
