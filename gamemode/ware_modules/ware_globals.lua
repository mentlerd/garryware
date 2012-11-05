
ROOM_ANY		= "*"

ROOM_BOXGRID	= "boxgrid"
ROOM_PLAIN		= "plain"

ONCRATE	= "boxtop"
FLOOR	= "floor"
AIR		= "air"
SKY		= "sky"

function IsPlayer( ent )
	return ent and ent:IsPlayer()
end
