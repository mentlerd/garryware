WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_REFLEX

WARE.Windup	= 0.7
WARE.Length	= 4

WARE.StripWeapons	= true

WARE.Colors = {
	{ "black", 	Color(0,0,0,255) },
	{ "grey", 	Color(138,138,138,255), Color(255,255,255,255) },
	{ "white", 	Color(255,255,255,255), Color(0,0,0,255) },
	{ "red", 	Color(220,0,0,255) },
	{ "green", 	Color(0,220,0,255) },
	{ "blue", 	Color(64,64,255,255) },
	{ "pink", 	Color(255,0,255,255) }
}

WARE.Models = {
	"models/props_c17/furniturewashingmachine001a.mdl"
}

WARE.Ratio	= 0.5

function WARE:Initialize()

	local count	 = self:PlayerRatio( self.Ratio, 4, #self.Colors )
	local points = self:GetRandomPoints( count, AIR )

	local colors  = table.RandomSet( self.Colors, count )
	local correct = math.random( 1, count )
	
	self:Instruction( "Shoot the ".. colors[correct][1] .." prop!" , colors[correct][2], colors[correct][3] )
	
	for index, point in pairs( points ) do
		local prop = point:SpawnProp( self.Models[1] )
			prop:RandomYaw()
			prop:EnableMotion( false )

		prop:SetColor( colors[index][2] )
		prop.IsGoal = ( index == correct )	
	end	
end

function WARE:StartAction()
	self:GiveAll("ware_pistol")	
end

function WARE:EntityTakeDamage( prop, dmginfo )
	if ( !dmginfo:IsBulletDamage() ) then return end
	
	local att = dmginfo:GetAttacker()
	
	if ( att:IsPlayer() ) then
		att:ApplyState( prop.IsGoal, true )
	end
end
