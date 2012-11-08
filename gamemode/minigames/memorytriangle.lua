WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_PLAIN
WARE.Award	= AWARD_IQ_WIN

WARE.Windup	= 5
WARE.Phases	= { 2, 3.5 }

WARE.NoAnnouncer	= true
WARE.StripWeapons	= true

WARE.Colors = {
	{ "red", 	Color(220,0,0,255) },
	{ "green", 	Color(0,220,0,255) },
	{ "blue", 	Color(64,64,255,255) },
}

WARE.Models = { 
	"models/props_junk/wood_crate001a.mdl"
}

function WARE:Initialize()
	self:Instruction( "Memorize!" )
	
	local count	 = #self.Colors
	
	local points = self:GetRandomPoints( count, AIR )
	local offset = Vector( 0, 0, -32 )
	
	self.Numbers	= {}
	self.Crates		= {}

	local number = 0
	
	for index, point in pairs( points ) do
		local prop = point:MakeEntity( "ware_text", offset )
			prop:SetHealth( 100000 )
			
			prop:EnableMotion( false )
			prop:Spawn()
		
		number = number + math.random(1, 31)
		
		prop:SetText( number )
		prop:SetTextColor( self.Colors[index][2] )
		
		self.Numbers[index]	= number
		self.Crates[index]	= prop
	end
end

function WARE:StartAction()
	for index, prop in pairs( self.Crates ) do
		prop:SetHidden( true )
	
		local phys = prop:GetPhysicsObject()
		
		if ( IsValid( phys ) ) then
			phys:EnableMotion( true )
			
			phys:ApplyForceCenter( VectorRand() * 512 * phys:GetMass() )
			phys:Wake()
		end
	end
end

function WARE:StartPhase( phase )
	self:GiveAll( "ware_pistol" )
	
	local winner = math.random( 1, #self.Colors )
	
	self.Crates[winner].IsGoal = true
	
	if ( math.random( 0, 1 ) == 1 ) then
		self:Instruction( "Shoot the " .. self.Colors[winner][1] .." one!", self.Colors[winner][2] )
	else
		self:Instruction( "Shoot the " .. self.Numbers[winner] .. " one!" )
	end
end

function WARE:EndAction()
	for _, prop in pairs( self.Crates ) do
		prop:SetHidden( false )
	end
end

function WARE:EntityTakeDamage( prop, dmginfo )
	if ( !dmginfo:IsBulletDamage() ) then return end
	
	local att = dmginfo:GetAttacker()
	
	if ( !att:IsPlayer() ) then return end
	
	att:ApplyState( prop.IsGoal, true )
	
	for index, prop in pairs( self.Crates ) do
		prop:SetHidden( false, att )
	end
end
