
local isIntroPlayed = false

WARE.Author		= "MDave"
WARE.Room		= ROOM_BOXGRID

WARE.Windup		= 4
WARE.Phases		= { 3.5, 3.5, 5 }

WARE.OccurencesPerCycle = 0

WARE.InitialState	= false
WARE.HideStates		= true

function WARE:IsPlayable( num )
	return !isIntroPlayed
end

function WARE:Initialize()	
	self:Instruction( "A new GarryWare game stars!" )
	
	self.BoxTop = self:GetPoints( ONCRATE )
end

local function spawnModel( model, id )
	local point = GAMEMODE.Ware:GetRandomPoints( 1, AIR )[1]
	
	local prop = point:MakeEntity( "prop_physics_override" )
	
	prop:SetModel( model )
	
	prop:SetAngles( AngleRand() )
	prop:SetCollisionGroup( COLLISION_GROUP_DEBRIS )

	prop:Spawn()
	
	local phys = prop:GetPhysicsObject()
	if ( IsValid( phys ) ) then
		phys:ApplyForceCenter( VectorRand() * math.random( 256, 468 ) * phys:GetMass() )
		phys:Wake()
	else
		prop:Remove()
	end
end

function WARE:StartAction()
	self:Instruction( "Rules are easy : Do what it tells you to do!" )
	self:GiveAll( "weapon_physcannon" )
	
	if ( GAMEMODE.ModelPrecacheHash ) then
		local delay = 0
		
		for model, _ in pairs( GAMEMODE.ModelPrecacheHash ) do
			timer.Simple( delay, function()
				spawnModel( model )
			end )
			
			delay = delay + 0.3	-- TODO: UNRELYABLE!
		end
	end
end

function WARE:StartPhase( id )
	if ( id == 1 ) then
		self:Instruction( "To get on a box, jump then press crouch while in the air!" )
	elseif ( id == 2 ) then
		self:Instruction( "Try to get on a box!" )
	end
end

function WARE:EndAction()
	isIntroPlayed = true

	self:Instruction( "Game begins now! Have fun!" )
end

function WARE:Think( phase )
	if ( phase < 2 ) then return end

	for _, block in pairs( self.BoxTop ) do
		local box = block:FindInBox( Vector(-30,-30,0), Vector(30,30,64) )
		
		for _, target in pairs( box ) do
			if ( target:IsPlayer() ) then
				target:ApplyWin()
			end
		end
	end
end