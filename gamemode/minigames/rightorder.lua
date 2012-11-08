WARE.Author = "Hurricaaane (Ha3)"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_IQ_WIN

WARE.NoAnnouncer	= true
WARE.StripWeapons	= true

WARE.Windup	= 2
WARE.Length	= 2

WARE.TimeHard	= 2.3
WARE.TimeEasy	= 1.6

WARE.Correct 	= Color( 0, 192, 0 )
WARE.Wrong		= Color( 255, 0, 0 )

WARE.Target		= Color( 96, 96, 96 )

function WARE:Initialize()

	self.Numbers = math.random( 4, 7 )
	
	self:SetPhaseTime( self.Numbers * 0.4 )
	self:Instruction("Shoot in the right order!" )
	
	self.IsDesc	= math.random( 0, 1 ) == 1
	self.IsHard	= math.random( 0, 4 ) == 4
	
	local points = self:GetRandomPoints( self.Numbers, ONCRATE )
	local offset = Vector( 0, 0, 64 )
	
	local num = self.IsHard and -math.random(50,120) or 0
	
	self.Crates 	= {}
	self.Sequence 	= {}
	
	for index, point in ipairs( points ) do
		num = num + math.random( 1, 35 )
		
		local text = point:MakeEntity( "ware_text", offset )
			text:EnableMotion( false )
			text:SetText( num )
		
			text:Spawn()
		
		text.SeqID = index
		
		self.Crates[index]		= text
		self.Sequence[index]	= num
	end
	
end

function WARE:StartAction()
	self:SetPhaseTime( self.Numbers * ( self.isHard and self.TimeHard or self.TimeEasy ) )
	
	if ( self.IsDesc ) then
		self:Instruction( "In the descending order! (3 , 2 , 1...)" )
	else
		self:Instruction( "In the ascending order! (1 , 2 , 3...)" )
	end
	
	self.Current	= {}
	self.AlreadyHit	= {}
	
	for _, ply in pairs( self:GetPlayers() ) do 
		self.AlreadyHit[ply] 	= {}
		self.Current[ply]		= 0
	end
	
	self:GiveAll( "ware_pistol" )
end

function WARE:EndAction()
	local msg = ""
	
	local count = self.Numbers
	
	for index =1, count do
		if ( self.IsDesc ) then
			msg = msg .. self.Sequence[ count - index +1 ] .. ", " 
		else
			msg = msg .. self.Sequence[ index ] .. ", "
		end
	end
	
	msg = msg:sub( 1, msg:len() -2 )
	
	self:Instruction( "Sequence was ".. msg .."!" , self.Correct )
end

function WARE:EntityTakeDamage( prop, dmginfo )
	if ( !dmginfo:IsBulletDamage() or !prop.SeqID ) then return end
	
	local seqID = prop.SeqID
	local att = dmginfo:GetAttacker()
	
	if ( !att:IsPlayer() ) then return end
			
	if ( self.AlreadyHit[att][seqID] ) then return end
		self.AlreadyHit[att][seqID] = true
		
	prop:GetPos():Effect( "ware_appear" )
		
	local index = self.Current[att] +1
		self.Current[att] = index

	index = self.IsDesc and ( self.Numbers - index +1 ) or index
		
	if ( index == seqID ) then
		prop:SendTextColor( att, self.Correct )
		
		if ( self.Current[att] == self.Numbers ) then
			att:ApplyWin()
		end
	else
		local good = self.Crates[index]
		
		prop:SendTextColor( att, self.Wrong )
		good:SendTextColor( att, self.Target )
		
		att:ApplyLose()
	end
end
