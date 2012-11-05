
AddCSLuaFile()

include( "sh_meta_util.lua" )

local vgui = {
	"WClock", "WScreenPopup"
}

for _, file in pairs( vgui ) do
	local file = "vgui/" .. file .. ".lua"
	
	if ( SERVER ) then 	
		AddCSLuaFile( file )
	else
		include( file )
	end
end


GM.Name 	= "GarryWare 2"
GM.Author 	= ""
GM.Email 	= ""
GM.Website 	= ""

DeriveGamemode( "base" )

COLOR_RED		= Color( 250, 30, 30 )
COLOR_YELLOW	= Color( 250, 250, 0 )
COLOR_GREEN		= Color( 30, 250, 30 )

function GM:Warning( msg )
	if ( SERVER ) then
		MsgC( Color( 100, 255, 255 ), "[SV][WARNING] " .. msg .. "\n" )
	else
		MsgC( Color( 255, 255, 100 ), "[CL][WARNING] " .. msg .. "\n" )
	end
end
