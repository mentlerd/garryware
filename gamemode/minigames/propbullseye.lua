WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_AIM

WARE.Windup	= 1.5
WARE.Length	= 8

WARE.Models = {
	"models/props_junk/plasticbucket001a.mdl",
	"models/props_junk/metalbucket01a.mdl",
	"models/props_junk/propanecanister001a.mdl",
	"models/props_combine/breenglobe.mdl",
	"models/props_c17/chair_office01a.mdl",
	"models/props_c17/chair_stool01a.mdl",
	"models/props_wasteland/controlroom_chair001a.mdl"
 }
 
WARE.Velocity 	= 128

WARE.Ratio		= 0.3
WARE.PropRatio	= 1.3

function WARE:Initialize()
	self:Instruction( "Hit the bullseye!" )

	self:GiveAll( "weapon_physcannon" )	
end

function WARE:StartAction()	
	local count		= self:PlayerRatio( self.Ratio, 1, 64 )
	local points	= self:GetRandomPoints( count, AIR )
	
	self.Bullseyes = {}
	
	for index, point in pairs( points ) do
		local ent = point:MakeEntity("ware_bullseye")
			ent.Speed = self.Velocity
			ent:Spawn()
		
		self.Bullseyes[index] = ent
		
		local phys = ent:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:ApplyForceCenter(VectorRand() * 16)
			phys:Wake()
		end
	end
	
	local count		= self:PlayerRatio( self.PropRatio, 1, 64 )
	local points	= self:GetRandomPoints( count, ONCRATE )
	
	local offset	= Vector( 0, 0, 30 )
	
	for _, point in ipairs( points ) do	
		local model = table.Random( self.Models )
		
		local prop = point:SpawnProp( table.Random( self.Models ), offset )
			prop:SetAngles( Angle(0, math.random(0,360), 0) )
	end
end

function WARE:GravGunOnPickedUp( ply, ent )
	ent.LastPuntedBy = ply
end

function WARE:TargetCollide( ent, data, physobj )
	local owner = data.HitEntity.LastPuntedBy
	
	if ( IsValid( owner ) ) then
		owner:ApplyWin()
	end
end