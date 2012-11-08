
g_Clock			= g_Clock 		or vgui.Create( "WClock" )
g_ScreenPopup 	= g_ScreenPopup or vgui.Create( "WScreenPopup" )

g_ScoreBoard	= g_ScoreBoard	or vgui.Create( "WScoreBoard" )


GM.HUDBlacklist = {
	CHudHealth 				= true,
	CHudBattery 			= true,
	CHudWeaponSelection 	= true,
	CHudAmmo				= true,
	CHudSecondaryAmmo		= true
}

function GM:HUDShouldDraw( name )
	return !self.HUDBlacklist[name]
end

function GM:HUDWeaponPickedUp( wep )
	return false
end

