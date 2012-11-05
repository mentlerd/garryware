
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
	
	if ( lock and !ware.HideStates ) then
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

	self._state			= default	
	self._stateSent		= nil
end

util.AddNetworkString( "ware_StateLock" )
util.AddNetworkString( "ware_StateUpdate" )

function GM:SendStates( state, global, hide )
	if ( !self.Ware ) then return end
	
	net.Start( "ware_StateUpdate" )
		net.WriteBool( global )
	
		if ( global ) then
			net.WriteBool( state )
			net.WriteBool( hide )
		else
			net.WriteTable( state )
		end		
	net.Broadcast()
	
	if ( global ) then
		for _, ply in pairs( self.Ware:GetPlayers() ) do
			ply._stateSent = state
			
			if ( ply:IsLocked() ) then
				net.Start( "ware_StateLock" )
				net.Send( ply )
			end
		end
	else
		for ply, state in pairs( state ) do
			ply._stateSent = state
			
			if ( ply:IsLocked() ) then
				net.Start( "ware_StateLock" )
				net.Send( ply )
			end
		end
	end
end

function GM:UpdatePlayerStates( force )
	if ( !force and ( !self.Ware or self.Ware.HideStates ) ) then return end
	
	local change = {}
	local hasAny = false
	
	for _, ply in pairs( self.Ware:GetPlayers() ) do
		local state = ply._state
		
		if ( ply._stateSent != state ) then
			change[ ply ] 	= state
			hasAny = true
		end
	end
	
	if ( hasAny ) then
		self:SendStates( change )
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