WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_FRENZY

WARE.Windup	= 0.7
WARE.Length	= 7.5

WARE.Models = { 
	"models/props_junk/wood_crate001a.mdl",
	"models/props_junk/wood_crate002a.mdl" 
}

function WARE:Initialize()
	self:Instruction( "Punt the biggest crate!" )
end

function WARE:StartAction()
	
	local points = self:GetPoints( AIR )
	local big 	 = math.random( 1, #points )
	
	for index, point in pairs( points ) do
		if ( index != big ) then
			local prop = point:SpawnProp( self.Models[1] )
				prop:RandomYaw()
		end
	end
	
	local goal = points[big]:SpawnProp( self.Models[2] )
		goal:SetHealth( 10000 )
		goal:RandomYaw()

	goal.IsGoal = true
	
	self:GiveAll( "weapon_physcannon" )
end

function WARE:GravGunPunt( ply, target )
	ply:ApplyState( target.IsGoal, true )
end

function WARE:GravGunPickupAllowed( ply, target )
	return !target.IsGoal
end
