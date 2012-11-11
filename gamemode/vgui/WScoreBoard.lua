
local PANEL = {}

function PANEL:Init()
	self.PlayerPanels = {}
	
	self:SetSize( ScrW(), 800 )
end

function PlayerComparator( panelA, panelB )
	local plyA = panelA.Player._time or math.huge
	local plyB = panelB.Player._time or math.huge
	
	return plyA < plyB
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
			entry:SetSize( 500, 20 )
			entry:SetPlayer( ply )
			
			self.PlayerPanels[ply] = entry
		end
		
		entry.first = false 	-- TODO: Make the server tell this!
		entry:RefreshPlayerState()
		
		if ( ply:IsWarePlayer() ) then
			table.insert( ply:GetState() and winnerList or loserList, entry )
		end
	end
	
	if ( false ) then	-- TODO: States are hidden?
		for index, panel in pairs( loserList ) do		
			self:MovePanel( panel, 1, index ) -- TODO
		end
	else
		table.sort( winnerList, PlayerComparator )
		table.sort( loserList, PlayerComparator )
	
		if ( #winnerList > 0 ) then
			winnerList[1].first = true	-- TODO: Make the server tell this!
		end
		
		for index, panel in pairs( winnerList ) do
			panel:MoveTo( 10, index * 20, 0.2, 0, 2 )
			self:MovePanel( panel, 1, index )			
		end
		
		for index, panel in pairs( loserList ) do
			self:MovePanel( panel, 2, index )			
		end
	end
end

function PANEL:MovePanel( panel, column, index )
	local w, h = panel:GetSize()
	
	panel:MoveTo( (ScrW()/3) *column - w/2, index * h, 0.2, 0, 2 )
	-- TODO: Multiple rows, and nice stuff for later
end

function PANEL:Paint()
	return true
end

vgui.Register( "WScoreBoard", PANEL, "DPanel" )
