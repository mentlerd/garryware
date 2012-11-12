
include( "sv_effects.lua" )


local meta = FindMetaTable( "Player" )

AccessorFunc( meta, "_role", "Role" )

function meta:IsWarePlayer()
	return true -- TODO
end



function meta:IsLocked()
	return self._stateLock
end

function meta:GetState()
	return self._state
end

function meta:ApplyWin( lock )
	self:ApplyState( true, true )
end
function meta:ApplyLose( lock )
	self:ApplyState( false, true )
end

function meta:ApplyState( state, lock )
	if ( self:IsLocked() ) then return end
	
	local state = state or false	-- HACK
	
	local ware = GAMEMODE.Ware
	if ( !ware ) then return end
		
	if ( !state and lock and ware.DieOnLose ) then
		self:SimulateDeath()
	end
	
	self._state 		= state
	self._stateLock		= lock
	
	if ( lock ) then
		self._stateSent	= nil	-- Force state update
		
		if ( !ware.HideStates ) then
			GAMEMODE:PlayerStateEffect( self, state )
		
			if ( ware.StripWeapons ) then
				self:StripWeapons()
			end
		end
		
		GAMEMODE:PlayerStateLock( ply, state )
	end
end

function meta:ResetState( default )
	self._stateLock 	= false

	self._state			= default or false
	self._stateSent		= nil
end

util.AddNetworkString( "ware_StateUpdate" )

function GM:UpdatePlayerStates( force )
	if ( !force and ( !self.Ware or self.Ware.HideStates ) ) then return end

	local hasAny = false	
	local states = {}
	
	for _, ply in pairs( self.Ware:GetPlayers() ) do
		local state = ply:GetState()
		
		if ( ply._stateSent != state ) then
			ply._stateSent = state
			
			states[ply] = {
				state	= state,
				lock	= ply:IsLocked()
			}
			
			hasAny = true
		end
	end
	
	if ( hasAny ) then
		net.Start( "ware_StateUpdate" )		
			net.WriteTable( states )
		net.Broadcast()
	end

end



function meta:IsFakeDead()
	return self._isFakingDeath
end

util.AddNetworkString( "ware_PushRagdoll" )

function meta:SimulateDeath( pushVector, pushBone, pushTime )
	if ( self:IsFakeDead() ) then return end
	
	self:CreateRagdoll()
	self:SetColor( Color( 255, 255, 255, 64 ) )
	
	if ( pushVector != false ) then
		if ( !isvector( pushVector ) ) then
			pushVector = self:GetVelocity()
		end
	
		net.Start( "ware_PushRagdoll" )
			net.WriteEntity( self )
			net.WriteVector( pushVector )
			
			net.WriteInt( pushBone or -1, 8 )
			net.WriteInt( pushTime or 20, 8 )
		net.SendPVS( self:GetPos() )
	end
	
	local ware = GAMEMODE.Ware
	if ( ware ) then
		self:SetNoCollideWithTeammates( !ware.DeadShouldCollide )
	end
	
	self._isFakingDeath = true
end

function meta:RestoreDeath()
	if ( !self:IsFakeDead() ) then return end
	
	self:SetColor( Color( 255, 255, 255, 255 ) )
	
	local ragdoll = self:GetRagdollEntity()
	if ( ragdoll and IsValid( ragdoll ) ) then
		ragdoll:Remove()
	end
	
	self:SetNoCollideWithTeammates( false )
	self._isFakingDeath = false
end

util.AddNetworkString( "ware_Popup" )

function meta:SendPopup( text, bgColor, fgColor, life )	
	net.Start( "ware_Popup" )
		net.WriteString( text )
		
		net.WriteType( bgColor )
		net.WriteType( fgColor )
		
		net.WriteType( life )
	net.Send( self )
end