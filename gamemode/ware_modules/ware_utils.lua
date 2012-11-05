
function table.RandomSet( tbl, count )
	local remain = #tbl
	local result = {}
	
	for index = 1, count do
		result[index] = table.remove( tbl, math.random( 1, remain ) )
			remain = remain -1
	end
	
	return result
end

local meta = FindMetaTable( "Vector" )

function meta:FindInBox( mins, maxs )	
	if ( isnumber( mins ) ) then	-- Convenience
		mins = mins /2
		
		maxs = Vector( mins, mins, mins )
		mins = -maxs
	elseif ( !maxs ) then 
		maxs = mins
		mins = -maxs
	end

	return ents.FindInBox( self + mins, self + maxs )
end

function meta:Effect( name )
	local data = EffectData()
		data:SetOrigin( self )
		
	util.Effect( name, data, true, true )
end

function meta:MakeEntity( name, offset, noware )
	local ent = ents.Create( name )

	if ( IsValid( ent ) ) then
		if ( isvector( offset ) ) then
			ent:SetPos( self + offset )
		else
			ent:SetPos( self )
		end
		
		if ( !noware and GAMEMODE.Ware ) then
			ent:GetPos():Effect( "ware_appear" )
		
			GAMEMODE:AddToTrash( ent )
		end
	end
	
	return ent
end

function meta:SpawnProp( model, offset, noware )
	local ent = self:MakeEntity( "prop_physics", offset, noware )
		ent:SetModel( model )
		ent:Spawn()
		
	return ent
end
