
local plyWin	= Sound("ware/other_exo_won1.wav")
local plyLose	= Sound("ware/other_lose1.wav")

local colWin	= Color( 0, 164, 237, 192 )
local colLose	= Color( 255, 87, 87, 192 )

function GM:PlayerStateEffect( ply, state )
	if ( !self.Ware ) then return end

	local bool = math.random(0, 1) != 0
	local pos = ply:GetPos()
	
	if ( state ) then
		pos:Effect( "ware_good" )
		ply:EmitSound( plyWin, 100, 100 )
		
		ply:SendPopup( "Success!", colWin )
		
		local anim = bool and ACT_SIGNAL_FORWARD or ACT_SIGNAL_HALT
			self:DoAnimationEvent( ply, anim )
	else
		pos:Effect( "ware_bad" )
		ply:EmitSound( plyLose, 100, 100 )
	
		ply:SendPopup( "FAIL", colLose )
	
		local anim = bool and ACT_ITEM_THROW or ACT_ITEM_DROP
			self:DoAnimationEvent( ply, anim )
	end
end
