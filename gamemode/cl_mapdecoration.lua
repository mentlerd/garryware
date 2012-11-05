
local harmonics	= {}

local function MakeHarmonics( origin, radius, color )
	local dataTable = {}
	
	-- Statics
	dataTable.NumPins = 12
	dataTable.CirclePrecision = 3
	dataTable.Thickness = 6
	
	dataTable.Origin	= origin
	dataTable.Radius	= radius
	dataTable.Color		= color
	dataTable.BaseAlpha	= color.a
	
	dataTable.Distance	= radius
	
	dataTable.VD = {}
	for i = 1, 3 do
		table.insert(dataTable.VD, 0 )
		table.insert(dataTable.VD, ((math.random(0, 1) == 1) and 1 or -1) * math.Rand(0.7,3) )
	end
	
	dataTable.BaseCircle = {}
	for d = 0, 359, (360 / dataTable.CirclePrecision) do
		table.insert( dataTable.BaseCircle, Vector( math.cos( math.rad(d) ) * dataTable.Distance, math.sin( math.rad(d) ) * dataTable.Distance, 0) )
	end
	
	dataTable.SubSequents = {}
	
	for i = 1, dataTable.NumPins do
		dataTable.SubSequents[i] = {}
		
		for k = 1, dataTable.CirclePrecision do
			table.insert( dataTable.SubSequents[i], Vector(0,0,0) )
		end
	end
	
	table.insert( harmonics, dataTable )
end

local function CalculateAngle( iPhasis, dataTable, target )
	target.p = iPhasis * dataTable.VD[2]
	target.y = iPhasis * dataTable.VD[4]
	target.r = iPhasis * dataTable.VD[6]
end

local flareMat = Material( "effects/yellowflare" )

local angle			= Angle(0,0,0)
local lastPhasis	= 0

local isDecorated = false

net.Receive( "ware_decoration", function()
	GM:MapDecoration( net.ReadVector(), net.ReadVector() )
end )

function GM:MapDecoration( origin, extrema, override )
	local radius = (origin - extrema):Length()
	
	if ( override ) then
		harmonics = {}
	end
	
	MakeHarmonics( origin, radius, Color( 119, 199, 255, 164 ) )
	MakeHarmonics( origin, radius, Color( 241, 197, 255, 164 ) )
	--MAPDECO.MakeHarmonics( origin, radius, Color( 197, 255, 231, 164 ) )
	
	isDecorated = true
end

function GM:PostDrawOpaqueRenderables()
	if ( !isDecorated ) then return end

	local phasis = math.floor( CurTime() * 10 )
	render.SetMaterial( flareMat )
	
	for _, dataTable in pairs( harmonics ) do
		for i = 1, dataTable.NumPins do
			local delta = (dataTable.NumPins - i + 1) / dataTable.NumPins
			
			if ( phasis != lastPhasis ) then
				CalculateAngle( phasis - i, dataTable, angle )
				
				for k, _ in pairs( dataTable.SubSequents[i] ) do
					dataTable.SubSequents[i][k].x = dataTable.BaseCircle[k].x
					dataTable.SubSequents[i][k].y = dataTable.BaseCircle[k].y
					dataTable.SubSequents[i][k].z = 0
					
					dataTable.SubSequents[i][k]:Rotate( angle )
					dataTable.SubSequents[i][k] = dataTable.SubSequents[i][k] + dataTable.Origin
				end
			end
			
			for k,_ in pairs( dataTable.SubSequents[i] ) do
				dataTable.Color.a = dataTable.BaseAlpha * delta
				
				render.DrawBeam( dataTable.SubSequents[i][k], dataTable.SubSequents[i][(k % dataTable.CirclePrecision) + 1],
								 dataTable.Thickness, 0.5, 0.5, dataTable.Color )
			end
		end
	end
	
	lastPhasis = phasis
end
