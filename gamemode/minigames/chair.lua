WARE.Author = "Hurricaaane (Ha3)"

WARE.Award	= AWARD_FRENZY
WARE.Room	= ROOM_BOXGRID

WARE.Windup	= 0.7
WARE.Length	= 6

WARE.Ratio	= 0.3

WARE.Models = {
	"models/props_c17/furniturechair001a.mdl",
	
	"models/props_c17/chair_office01a.mdl",
	"models/props_c17/chair_stool01a.mdl",
	"models/props_wasteland/controlroom_chair001a.mdl"
 }

function WARE:Initialize()
	self:Instruction( "Break a chair!" )
end

function WARE:StartAction()
	local crates = self:GetPointCount( ONCRATE )
	
	local realCount	= self:PlayerRatio( self.Ratio, 1, 64 )
	local fauxCount = math.Clamp( math.ceil( crates * 0.3 ), realCount, 64 )
	
	local points = self:GetRandomFilterBox( realCount + fauxCount, ONCRATE, IsPlayer, 30 ) 
	local offset = Vector( 0, 0, 30 )
	
	for index = 1, realCount do
		local prop = points[index]:SpawnProp( self.Models[1], offset )
			prop:RandomYaw()
			prop:SetHealth( 15 )
			
			prop.IsGoal = true
	end
	
	for index = 1, fauxCount do
		local model = self.Models[ math.random( 2, #self.Models ) ]

		local prop = points[index + realCount]:SpawnProp( model, offset )
			prop:RandomYaw()
			prop:SetHealth( 10000 )
	end

	if ( math.random(0,1) > 0 ) then
		self:GiveAll( "ware_pistol" )
	else
		self:GiveAll( "weapon_crowbar" )
	end
end

function WARE:PropBreak( killer, prop)
	if ( !prop.IsGoal ) then return end
	
	if ( killer:IsPlayer() ) then
		killer:ApplyWin()
	end
end
