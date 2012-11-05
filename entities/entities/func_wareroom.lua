
ENT.Type = "brush"
ENT.Base = "base_brush"

ENT.BypassFilter	= true

function ENT:Initialize()
	self.RoomType = self.RoomType or "generic"
	self.Points = {}
end

function ENT:KeyValue( key, value )
	key = string.lower( key )
	
	if ( key == "minplayers" ) then
		self.MinPlayers	= tonumber( value )
	elseif ( key == "maxplayers" ) then
		self.MaxPlayers	= tonumber( value )
	elseif ( key == "roomtype" ) then
		self.RoomType	= value
	end
end

function ENT:StartTouch( ent )

	if ( ent.ReportPoints ) then
		ent:ReportPoints( self.Points )
		ent:Remove()
	end

end

-- API
function ENT:GetRoomType()
	return self.RoomType
end

function ENT:GetPoints( group )
	if ( istable( group ) ) then
		local points = {}
		
		for _, key in pairs( group ) do
			table.Add( points, self:GetPoints( key ) )
		end
		
		return points
	elseif ( self.Points[ group ] ) then
		return table.Copy( self.Points[ group ] )
	else
		return {}
	end
end

function ENT:GetPointCount( group )
	if ( istable( group ) ) then
		local sum = 0
		
		for _, key in pairs( group ) do
			if ( self.Points[key] ) then
				sum = sum + #self.Points[key]
			end
		end
		
		return sum
	else
		return self.Points[group] and #self.Points[ group ] or 0
	end
end

function ENT:GetRandomPoints( num, group )
	local copy = self:GetPoints( group )	
	local count = #copy

	if ( num > count ) then
		return copy, count
	else
		local result = {}
	
		for index = 1, num do
			result[index] = table.remove( copy, math.random( 1, count - index ) )
		end
		
		return result, num
	end
end

function ENT:GetRandomFilterBox( num, group, filter, mins, maxs )
	
	if ( isnumber( mins ) ) then	-- Convenience
		mins = -mins /2
		
		mins = Vector( mins, mins, mins )
		maxs = -mins
	elseif ( !maxs ) then
		maxs = mins
		mins = -maxs
	end	
	
	local points = self:GetPoints( group )
	local count = #points
		num = math.Clamp( num, 0, count )
	
	local result	= {}
	local invalid 	= {}
	
	for index = 1, num do
		local isValid = true
		
		while( true ) do
			isValid = true
		
			if ( count <= 0 ) then		-- Failed to do with filter, adding invalid positions
				for i = 1, num -index +1 do
					result[i + index] = invalid[i]
				end
				
				return result
			end
		
			local picked = table.remove( points, math.random( 1, count ) )	-- Pick a random position
				count = count -1
		
			for _, ent in pairs( ents.FindInBox( picked + mins, picked + maxs ) ) do	-- Check entites near
				if ( ent == self ) then continue end	-- Skip the room itself

				if ( filter( ent, picked ) ) then
					isValid = false
					break
				end			
			end
			
			if ( !isValid ) then	-- Store if we fail, otherwise continue
				table.insert( invalid, picked )
			else
				result[index] = picked
				break
			end
		end
	end
	
	return result
end
