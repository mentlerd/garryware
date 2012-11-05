
GM.WareRooms = {}	-- [type][plycount] = { rooms }

function GM:ReadMapRooms()

	for _, room in pairs( ents.FindByClass( "func_wareroom" ) ) do
		if ( IsValid( room ) ) then
			local class = room.RoomType:lower()
		
			if ( !self.WareRooms[class] ) then
				self.WareRooms[class] = {}
			end
			
			local min = room.MinPlayers
			
			if ( min ) then
				if ( self.WareRooms[class][min] ) then
					self:Warning( "Duplicate func_warerooms! '".. class .."' @" .. min .. " !" )
				end
				
				self.WareRooms[class][min] = room
			end
		end
	end
	
end

function GM:FindRoomFor( class, playerNum )

	if ( class == "*" ) then
		if ( !playerNum ) then return true end
		
		class = ROOM_BOXGRID	-- TODO !!!
	end

	local rooms = self.WareRooms[class:lower()]
	if ( !rooms ) then return false end
	
	if ( !playerNum ) then return true end
	
	for count = playerNum, 0, -1 do
		if ( rooms[count] ) then
			return rooms[count]
		end
	end
	
	return false
end
