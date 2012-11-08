
local PANEL = {}

function PANEL:Init()
	self.PlayerPanels = {}
	
	self:SetMinimumSize( 800, 800 )
end

local function PlayerComparator( plyA, plyB )
	if ( plyA._first ) then return true		end
	if ( plyB._first ) then return false	end
	
	if ( plyA._lock ) then
		return !plyB._lock or ( plyA.time < plyB.time )
	elseif ( plyB._lock ) then
		return false
	else
		return plyA:GetName() < plyB:GetName()
	end
end

function PANEL:PerformScoreLayout()
	for ply, panel in pairs( self.PlayerPanels ) do
		if ( !IsValid( ply ) ) then
			panel:Remove()
		end
	end
	
	local winnerList	= {}
	local loserList		= {}
	
	for index, ply in pairs( player.GetAll() ) do
		local entry = self.PlayerPanels[ply]
		
		if ( !IsValid( entry ) ) then
			entry = vgui.Create( "WPlayerLabel", self )
			entry:SetSize( 400, 32 )
			entry:SetPlayer( ply )
			
			self.PlayerPanels[ply] = entry
		end
		
		entry:RefreshPlayerState()
		
		if ( ply:IsWarePlayer() ) then
			table.insert( ply:GetState() and winnerList or loserList, entry )
		end
	end
	
	if ( false ) then	-- TODO: States are hidden?
		for index, panel in pairs( loserList ) do
			panel:MoveTo( 200, index * 32, 0.2, 0, 2 )
		end
	else
		table.sort( winnerList, PlayerComparator )
		table.sort( loserList, PlayerComparator )
		
		for index, panel in pairs( winnerList ) do
			panel:MoveTo( 10, index * 32, 0.2, 0, 2 )		
		end
		
		for index, panel in pairs( loserList ) do
			panel:MoveTo( 400, index * 32, 0.2, 0, 2 )
		end
	end

end

function PANEL:Paint()
	return true
end

vgui.Register( "WScoreBoard", PANEL, "DPanel" )

if ( IsValid( g_Test ) ) then
	g_Test:Remove()
end

g_Test = vgui.Create( "WScoreBoard" )
g_Test:SetPos( 100, 100 )
g_Test:SetSize( 1024, 800 )
