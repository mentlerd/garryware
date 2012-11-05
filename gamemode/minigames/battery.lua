WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_FRENZY

WARE.Windup	= 1
WARE.Length	= 12

WARE.StripWeapons	= true

WARE.BoxRatio		= 1.4
WARE.BatteryRatio	= 0.8

WARE.PlugRatio		= 0.6


WARE.Models = {
	"models/items/item_item_crate.mdl",
	
	"models/props_lab/tpplugholder_single.mdl",
	"models/items/car_battery01.mdl",
	"models/props_lab/tpplug.mdl",
	
	"models/combine_camera/combine_camera.mdl"
 }

local dirOffset = {
	Vector(  30, -13, -30 ),	Vector(  13,  30, -30 ),
	Vector( -30,  13, -30 ),	Vector( -13, -30, -30 )
}

function WARE:Initialize()
	self:Instruction( "Find a battery and plug it!" )
	
	-- Find player count specific box count, and select spawnpoints for them
	local count 	= self:PlayerRatio( self.BoxRatio, 1, 64 )
	local points	= self:GetRandomFilterBox( count, ONCRATE, IsPlayer, 30 )

	local offset	= Vector( 0, 0, 16 )
	
	local crates = {}
	
	-- Spawn crates
	for index, point in pairs( points ) do
		local prop = point:SpawnProp( self.Models[1], offset )
			prop:RandomYaw()
		
		local phys = prop:GetPhysicsObject()
			phys:ApplyForceCenter( VectorRand() * 256 )
			phys:Wake()
		
		crates[index] = prop
	end

	-- Select actives, based on battery ratio
	for index = 1, count * self.BatteryRatio do
		crates[index].HasBattery = true
	end
	
	-- Find player count specific camera count, and select spawnpoints for them
	local count		= self:PlayerRatio( self.PlugRatio, 1, 64 )
	local points	= self:GetRandomFilterBox( count, ONCRATE, IsValid, 30 )

	-- Spawn sockets, and cameras
	self.Sockets = {}
	
	for index, point in pairs( points ) do
		local socket = point:SpawnProp( self.Models[2] )

		local dir = math.random( 1, 4 )
			socket:SetPos( point + dirOffset[dir] )
			socket:SetAngles( Angle( 0, (dir -1) *90, 0 ) )
	
		socket:SetMoveType( MOVETYPE_NONE )
		socket:SetCollisionGroup( COLLISION_GROUP_WEAPON )
		socket:EnableMotion( false )
		
		local camera = point:MakeEntity( "npc_combine_camera" )
			camera:SetAngles( Angle( 180, dir *90, 0 ) )
			
			camera:SetKeyValue( "spawnflags", 208 ) -- 128 = Inactive, 64 = Ignore Enemies, 16 = Efficient
			camera:SetCollisionGroup(COLLISION_GROUP_WEAPON)
		
			camera:Spawn()
			
		socket.LinkedCamera = camera
		
		self.Sockets[index] = socket
	end
 
	self:GiveAll( "weapon_physcannon" )
	
	self.NextPlugThink = 0
end

function WARE:GravGunOnPickedUp( ply, ent )
	if ( ent.IsBattery ) then 
		ent.BatteryOwner = ply
	end
end

function WARE:PropBreak( ply, prop )
	if ( prop.HasBattery ) then
		local pos = prop:GetPos()
	
		local battery 	= pos:SpawnProp( self.Models[3] )
		local plug 		= pos:SpawnProp( self.Models[4], battery:GetForward() * -8 )
			plug:SetCollisionGroup( COLLISION_GROUP_WORLD )
			plug:SetParent( battery )
			
		local phys = battery:GetPhysicsObject()
			phys:AddAngleVelocity( VectorRand() * 50 )
			phys:ApplyForceCenter( VectorRand() * 64 )
			
		battery:Trail( "trails/physbeam.vmt", Color( 255, 255, 255, 92 ), 0.9, 1.5, 1.2 )
		
		battery.Plug		= plug
		battery.IsBattery 	= true
	end
end

function WARE:PlugBattery( socket, battery )
	battery.GravGunBlocked = true
		
	battery:SetPos( socket:LocalToWorld( Vector( 13, 13, 10 ) ) )
	battery:SetAngles( socket:GetAngles() )

	battery:SetCollisionGroup( COLLISION_GROUP_WORLD )
	battery:EnableMotion( false )
	
	socket.LinkedCamera:Fire( "Enable" )
	socket:EmitSound( "npc/roller/mine/combine_mine_deploy1.wav" )
	
	local data = EffectData()
		data:SetOrigin( battery:GetPos() )
		data:SetNormal( battery:GetForward() )
		data:SetMagnitude( 8 )
		data:SetScale( 1 )
		data:SetRadius( 16 )
	util.Effect( "Sparks", data )
end

function WARE:Think()
	if ( CurTime() < self.NextPlugThink ) then return end

	for key, socket in pairs( self.Sockets ) do
		local pos = socket:GetPos()
	
		for _, ent in pairs( ents.FindInSphere( pos, 24 ) ) do
			if ( ent.IsBattery ) then
				local owner = ent.BatteryOwner
			
				if ( IsValid( owner ) ) then
					table.remove( self.Sockets, key )
					
					owner:ApplyWin()
					
					self:PlugBattery( socket, ent )
				end
			end
		end
	end
	
	self.NextPlugThink = CurTime() + 0.5
end
