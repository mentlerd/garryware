
ENT.Base		= "ware_point"

GM_CORNERS	= 0
GM_EDGES	= 1

function ENT:Initialize()
	self.BaseClass.Initialize( self )
	
	self.GridMode	= self.GridMode or GM_CORNERS
	
	self.CellSizeX	= self.CellSizeX or 256
	self.CellSizeY	= self.CellSizeY or 256
	
	self.CellOffset = self.CellOffset or Vector( 0,0,0 )
end

function ENT:KeyValue( key, value )
	local key = key:lower()
	
	if ( key == "pointclass" ) then
		self.PointClass	= value
	elseif ( key == "gridmode" ) then
		self.GridMode	= tonumber( value )
	else
		local split = string.Explode( " ", value )
		
		if ( key == "cellcount" ) then
			self.CellCountX	= tonumber( split[1] )
			self.CellCountY	= tonumber( split[2] ) or self.CellCountX
		elseif ( key == "cellsize" ) then
			self.CellSizeX	= tonumber( split[1] )
			self.CellSizeY	= tonumber( split[2] ) or self.CellSizeX
		elseif ( key == "celloffset" ) then
			local x = tonumber( split[1] )
			local y = tonumber( split[2] ) or x
			local z = tonumber( split[3] ) or 0
			
			self.CellOffset = Vector( x, y, z )
		end
	end
end

local function addGrid( tbl, zero, maxX, maxY, offX, offY )
	for y = 0, maxY do
		for x = 0, maxX do
			table.insert( tbl, zero + Vector( x * offX, y * offY, 0 ) )
		end
	end
end

function ENT:ReportPoints( map )
	local class = self.PointClass

	if ( !map[class] ) then
		map[class] = {}
	end

	local offX 	= self.CellSizeX
	local offY	= self.CellSizeY
	
	local zero = self:GetPos() + self.CellOffset
		zero.x = zero.x - offX * self.CellCountX /2
		zero.y = zero.y - offY * self.CellCountY /2
	
	if ( self.GridMode == GM_CORNERS ) then	-- Points placed at cell corners
		addGrid( map[class], zero, self.CellCountX, self.CellCountY, offX, offY )
	elseif ( self.GridMode == GM_EDGES ) then	-- Points placed at cell edges
		addGrid( map[class], zero + Vector( offX/2, 0, 0 ), self.CellCountX -1, self.CellCountY, offX, offY )
		addGrid( map[class], zero + Vector( 0, offY/2, 0 ), self.CellCountX, self.CellCountY -1, offX, offY )		
	end
end
