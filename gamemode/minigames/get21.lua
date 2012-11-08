WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_IQ_WIN

WARE.Windup	= 1
WARE.Length	= 8

WARE.StripWeapons	= true

WARE.Models = {
	"models/props_junk/wood_crate001a.mdl"
 }

WARE.Solutions = {
	{ 6, 7, 8 },	{ 5, 7, 9 },	{ 5, 6, 10 },	{ 4, 8, 9 },
	{ 4, 7, 10 },	{ 4, 6, 11 },	{ 3, 8, 10 },	{ 3, 7, 11 },
	{ 2, 9, 10 },	{ 2, 8, 11 },	{ 1, 9, 11 },
	
	{ 3, 5, 6, 7 },		{ 3, 4, 6, 8 },		{ 3, 4, 5, 9 }, 	{ 2, 5, 6, 8 },
	{ 2, 4, 7, 8 }, 	{ 2, 4, 6, 9 },		{ 2, 4, 5, 10 },	{ 2, 3, 7, 9 },
	{ 2, 3, 6, 10 },	{ 2, 3, 5, 11 },	{ 1, 5, 7, 8 },		{ 1, 5, 6, 9 },
	{ 1, 4, 7, 9 },		{ 1, 4, 6, 10 },	{ 1, 4, 5, 11 },	{ 1, 3, 8, 9 },
	{ 1, 3, 7, 10 },	{ 1, 3, 6, 11 },	{ 1, 2, 8, 10 }, 	{ 1, 2, 7, 11 },
	
	{ 2, 3, 4, 5, 7 },	{ 1, 3, 4, 6, 7 },	{ 1, 3, 4, 5, 8 },
	{ 1, 2, 5, 6, 7 },	{ 1, 2, 4, 6, 8 },	{ 1, 2, 4, 5, 9 },
	{ 1, 2, 3, 7, 8 },	{ 1, 2, 3, 6, 9 },	{ 1, 2, 3, 5, 10 },
	{ 1, 2, 3, 4, 11 }
}

WARE.CardCount	= 6
 
WARE.Progress	= Color( 255, 255, 20 )
WARE.Inactive	= Color( 64, 64, 64 )
 
WARE.Correct 	= Color( 20, 255, 20 )
WARE.Wrong		= Color( 255, 20, 20 )

function WARE:Initialize()
	self:Instruction( "Get 21!" )
	
	self.Solution = table.Random( self.Solutions )
	
	local cards	= table.Copy( self.Solution )
	local faux	= self.CardCount - #cards
	
	for index = 1, faux do
		local start = math.random( 1, 21 )
	
		for num = 1, 11 do	
			if ( !table.HasValue( cards, num ) ) then
				table.insert( cards, num )
				break
			end
		end
	end
	
	local points = self:GetRandomPoints( self.CardCount, AIR )
	
	self.Crates = {}
	
	for index, point in pairs( points ) do
		local prop = point:MakeEntity( "ware_text" )
			prop:SetText( tostring( cards[index] ) )
			prop.Value	= cards[index]
			
			prop:Spawn()
	
		self.Crates[index] = prop
	end
	
	self.PlayerSum 		= {}
	self.PlayerCrates	= {}
	
	for _, ply in pairs( self:GetPlayers() ) do
		self.PlayerCrates[ply] = {}
	end
end

function WARE:StartAction()
	self:GiveAll( "ware_pistol" )
end

function WARE:EntityTakeDamage( prop, dmginfo )
	local ply = dmginfo:GetAttacker()
	
	if ( !IsValid( ply ) or !ply:IsPlayer() ) then return end
	if ( !prop.Value ) then return end
	
	local value = prop.Value
		
	if ( self.PlayerCrates[ply][value] ) then return end
		self.PlayerCrates[ply][value] = true

	prop:SendTextColor( ply, self.Progress )
	prop:GetPos():Effect( "ware_appear" )
	
	local sum = ( self.PlayerSum[ply] or 0 ) + value
		self.PlayerSum[ply] = sum
		
	if ( sum >= 21 ) then
		local isWin = ( sum == 21 )
		local color	= isWin and self.Correct or self.Wrong
		
		ply:ApplyState( isWin, true )
		
		for _, prop in pairs( self.Crates ) do
			if ( self.PlayerCrates[ply][ prop.Value ] ) then
				prop:SendTextColor( ply, color )
			else
				prop:SendTextColor( ply, self.Inactive )
			end
		end
	end

end

function WARE:EndAction()
	local solution = string.Implode( " + ", self.Solution )

	self:Instruction( "A possible combination was ".. solution .."!", self.Correct )
end
