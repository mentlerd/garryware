WARE.Author = "Kilburn"

WARE.Room	= ROOM_BOXGRID
WARE.Award	= AWARD_FRENZY

WARE.Windup	= 3
WARE.Length	= 8

WARE.StripWeapons	= true

WARE.Ratio	= 0.5

WARE.Models = {
	"models/props_junk/wood_crate001a.mdl",
	"models/props_wasteland/speakercluster01a.mdl"
 }

WARE.Sounds = {
	"ambient/alarms/alarm_citizen_loop1.wav",
	"ambient/alarms/alarm1.wav",
	"ambient/alarms/city_firebell_loop1.wav",
	"ambient/alarms/siren.wav",
}

function WARE:GetModelList()
	return self.Models
end

function WARE:Initialize()

	local count  = self:GetPointCount( AIR )
	
	local alarms = self:PlayerRatio( self.Ratio, 1, count )
	local crates = math.Clamp( #self:GetPlayers() +1, 4, count - alarms )

	local points = self:GetRandomFilterBox( alarms + crates, ONCRATE, IsPlayer, 30 )	
	local offset = Vector( 0, 0, 100 )
	
	self.Speakers = {}
	
	for index, point in pairs( points ) do
		local prop = point:SpawnProp( self.Models[1], offset )
			prop:EnableMotion( false )
	
		if ( index <= alarms ) then
			local speaker = point:SpawnProp( self.Models[2], offset, true )
				speaker:SetAngles( AngleRand() )
				
				speaker:EnableMotion( false )
				speaker:SetNoDraw( true )
			
			speaker.Sound = CreateSound( speaker, table.Random( self.Sounds ) )
			
			prop.Speaker  = speaker
			
			self.Speakers[index] = speaker
			self:AddToTrash( speaker )
		end
	end

	self:Instruction( "Listen..." )
end

function WARE:StartAction()
	for _, prop in pairs( self.Speakers ) do
		prop.Sound:Play()
	end
	
	self:Instruction( "Shut it down!" )
	self:GiveAll( "weapon_crowbar" )
end

function WARE:EndAction()
	for _, prop in pairs( self.Speakers ) do
		prop.Sound:Stop()
	end
end

function WARE:Think()
	for _, prop in pairs( self.Speakers ) do
		if ( prop.Sound and prop.Pitch ) then
			prop.Pitch = prop.Pitch - 0.7
			prop.Sound:ChangePitch( prop.Pitch )
			
			if ( prop.Pitch <= 1 ) then
				prop.Pitch = nil
				prop.Sound:Stop()
			end
		end
	end
end

function WARE:PropBreak( ply, prop )
	if ( !ply:IsPlayer() ) then return end

	if ( prop.Speaker ) then
		ply:ApplyWin()
		
		local speaker = prop.Speaker
			speaker:EnableMotion( true )
			speaker:PhysWake()
			
			speaker:SetNoDraw( false )
			
			speaker.Pitch = 100
			
		local spark = ents.Create( "env_spark" )
			spark:SetPos( speaker:GetPos() )
			spark:SetParent( speaker )
			
			spark:SetKeyValue( "MaxDelay", 1 )
			spark:SetKeyValue( "Magnitude", 4 )
			spark:SetKeyValue( "TrailLength", 2 )
		
			spark:Spawn()
			spark:Fire( "StartSpark" )
		
		self:AddToTrash( spark )
	end
end
