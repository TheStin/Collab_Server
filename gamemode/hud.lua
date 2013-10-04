if CLIENT then 

	include( "shared.lua" ) 

	surface.CreateFont( "Deathrun_Smooth", { font = "Trebuchet18", size = 14, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothMed", { font = "Trebuchet18", size = 24, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothBig", { font = "Trebuchet18", size = 34, weight = 700, antialias = true } )
	surface.CreateFont( "DR_X", { font = "Trebuchet18", size = 34, weight = 1000, antialias = true } )
end
include( "cl_scoreboard.lua" )
include( "cl_frames.lua" )
include( "menutext.lua" )
include( "cl_voice.lua" )

include( "rtv/config.lua" )
include( "rtv/cl_rtv.lua" )

if SERVER then return end

local name = "A Mystical Force"

language.Add( "trigger_hurt", name )
language.Add( "env_explosion", name )
language.Add( "worldspawn", name )
language.Add( "func_movelinear", name )
language.Add( "func_physbox", name )
language.Add( "func_rotating", name )
language.Add( "func_door", name )
language.Add( "entityflame", name )
language.Add( "prop_physics", name )

function draw.AAText( text, font, x, y, color, align )

    draw.SimpleText( text, font, x+1, y+1, Color(0,0,0,math.min(color.a,120)), align )
    draw.SimpleText( text, font, x+2, y+2, Color(0,0,0,math.min(color.a,50)), align )
    draw.SimpleText( text, font, x, y, color, align )

end

local clamp = math.Clamp

local hx, hw, hh, border = 5, 204, 30, 2

local keys = {}
local draw_keys = false

function GM:HUDPaint( )

	local time = Material('hud/time.png')
	
	local ply = LocalPlayer()
	local ob = ply:GetObserverTarget()


	local hy = ScrH() - 35

	draw.RoundedBox( 0, 5, 16, 250, 44, Color( 50,50,50, 200 ) )
		draw.RoundedBox( 0, 5, 84, 250, 40, Color( 50, 50, 50, 200 ) )
		draw.SimpleText( LocalPlayer():PS_GetPoints(), "DR_X", 152, 104, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
		draw.RoundedBox( 0, 5, 72, 64, 64, Color( 255,255,255, 0 ) )
		
		surface.SetMaterial( Material("hud/hud_ps.png") )
		surface.SetDrawColor(255,255,255,255)
		surface.DrawTexturedRect( 5, 72, 64, 64 )

	local thp = ply:Alive() and ply:Health() or 0
	local hp = thp
	if hp > 0 then
		hp = ( hw - border*2 ) * ( math.Clamp(ply:Health(),0,100)/100) - 3
		draw.RoundedBox( 0, 55, 18, hp, 40, Color( 30, 100, 220, 255 ) )				
	end
	
	draw.AAText( tostring( thp > 999 and "dafuq" or math.max(thp, 0) ), "Deathrun_SmoothBig", 151, 20, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER )
	//draw.RoundedBox( 0, 5, 5, 64, 64, Color( 255,255,255, 255 ) )
	
	surface.SetMaterial( Material("hud/hud_hp.png") )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( 5, 5, 64, 64 )

	surface.SetFont( "Deathrun_SmoothBig" )
	local rt = string.ToMinutesSeconds(self:GetRoundTime())
	local ttw, _ = surface.GetTextSize( rt )

	local tw = hw/2 + 5
	//draw.WordBox( 4, 100, 80, rt, "Deathrun_SmoothBig", Color( 44, 44, 44, 200 ), Color( 255, 255, 255, 255 ) )
	
	draw.RoundedBox( 0, 5, 150, 250, 40, Color( 50,50,50, 200 ) )
	draw.SimpleText( rt, "DR_X", 150, 168, Color(255,255,255,255), TEXT_ALIGN_CENTER, TEXT_ALIGN_CENTER  )
	
	surface.SetMaterial( Material("hud/hud_time.png") )
	surface.SetDrawColor(255,255,255,255)
	surface.DrawTexturedRect( 5, 139, 64, 64 )
	//draw.RoundedBox( 0, 5, 107, 48, 48, Color( 255,255,255, 255 ) )

	self.BaseClass:HUDPaint()

end



local HUDHide = {
	
	["CHudHealth"] = true,
	["CHudSuitPower"] = true,
	["CHudBattery"] = true,
	--["CHudAmmo"] = true,
	--["CHudSecondaryAmmo"] = true,

}

function GM:HUDShouldDraw( No )
	if HUDHide[No] then return false end

	return true
end
