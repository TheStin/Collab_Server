if CLIENT then 

	include( "shared.lua" ) 

	surface.CreateFont( "Deathrun_Smooth", { font = "Trebuchet18", size = 14, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothMed", { font = "Trebuchet18", size = 24, weight = 700, antialias = true } )
	surface.CreateFont( "Deathrun_SmoothBig", { font = "Trebuchet18", size = 34, weight = 700, antialias = true } )
	surface.CreateFont( "DR_X", { font = "Trebuchet18", size = 34, weight = 1000, antialias = true } )
end
include( "cl_scoreboard.lua" )
include( "hud.lua" )
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



CreateClientConVar( "deathrun_autojump", 1, true, false )

local bhstop = 0xFFFF - IN_JUMP
local band = bit.band

function GM:CreateMove( uc )
	if GetGlobalInt("dr_allow_autojump") != 1 then return end
	local lp = LocalPlayer()
	if GetConVarNumber( "deathrun_autojump" ) == 1 and lp:WaterLevel() < 3 and lp:Alive() and lp:GetMoveType() == MOVETYPE_WALK then
		if not lp:InVehicle() and ( band(uc:GetButtons(), IN_JUMP) ) > 0 then
			if lp:IsOnGround() then
				uc:SetButtons( uc:GetButtons() or IN_JUMP )
			else
				uc:SetButtons( band(uc:GetButtons(), bhstop) )
			end
		end
	end
end

function GM:GetScoreboardNameColor( ply )

	if not IsValid(ply) then return Color( 255, 255, 255, 255 ) end
	if ply:SteamID() == "STEAM_0:1:38699491" then return Color( 60, 220, 60, 255 ) end -- Please don't change this.
	if GetGlobalInt( "dr_highlight_admins" ) == 1 and ply:IsAdmin() then
		return Color(220, 180, 0, 255)
	end

end

function GM:GetScoreboardIcon( ply )

	if not IsValid(ply) then return false end
	if ply:SteamID() == "STEAM_0:1:38699491" then return "icon16/bug.png" end -- Please don't change this.
	if GetGlobalInt( "dr_highlight_admins" ) == 1 and ply:IsAdmin() then
		return "icon16/shield.png"
	end

end

local function GetIcon( str )

	if str == "1" then
		return "icon16/tick.png"
	end

	return "icon16/cross.png"

end

local function CreateNumButton( convar, fr, title, tooltip, posx, posy, Cvar, wantCvar )

	local btn = vgui.Create( "DButton", fr )
	btn:SetSize( fr:GetWide()/2 - 5, 25 )
	btn:SetPos( posx or 5, posy or fr:GetTall() - 30 )
	btn:SetText("")

	local icon = vgui.Create( "DImage", btn )
	icon:SetSize( 16, 16 )
	icon:SetPos( btn:GetWide() - 20, btn:GetTall()/2 - icon:GetTall()/2 )
	icon:SetImage( GetIcon( GetConVarString(convar) ) )

	btn.UpdateIcon = function()
		icon:SetImage( GetIcon( GetConVarString(convar) ) )
	end

	surface.SetFont( "Deathrun_Smooth" )
	local _, tH = surface.GetTextSize("|")

	local lv = nil

	local disabled = false

	btn.Paint = function(self, w, h)

		if Cvar and wantCvar then

			local c = GetGlobalInt( Cvar, 0 )

			if not lv then
				lv = c
				local change = c != wantCvar

				icon:SetImage( GetIcon( change and "0" or "1" ) )
				btn:SetDisabled( change )
				disabled = change
			elseif lv != c then
				lv = c
				local change = c != wantCvar

				icon:SetImage( GetIcon( change and "0" or "1" ) )
				btn:SetDisabled( change )
				disabled = change
			end  


		end

		surface.SetDrawColor( Color( 45, 55, 65, 200 ) )
		surface.DrawRect( 0, 0, w, h )

		draw.AAText( title..( disabled and " (Disallowed)" or "" ), "Deathrun_Smooth", 5, h/2 - tH/2, disabled and Color(200, 60, 60, 255) or Color(255,255,255,255) )

	end
	btn.DoClick = function()
		local cv = GetConVarString(convar)
		cv = cv == "1" and "0" or "1"
		RunConsoleCommand(convar, cv )
		icon:SetImage( GetIcon(cv) )		
	end

	if tooltip then
		btn:SetTooltip( tooltip )
	end

	return btn

end

function WrapText(text, width, font) -- Credit goes to BKU for this function!
	surface.SetFont(font)

	-- Any wrapping required?
	local w, _ = surface.GetTextSize(text)
	if w < width then
		return {text} -- Nope, but wrap in table for uniformity
	end
   
	local words = string.Explode(" ", text) -- No spaces means you're screwed

	local lines = {""}
	for i, wrd in pairs(words) do
		local l = #lines
		local added = lines[l] .. " " .. wrd
		if l == 0 then
			added = wrd
		end
		w, _ = surface.GetTextSize(added)

		if w > width then
			-- New line needed
			table.insert(lines, wrd)
		else
			-- Safe to tack it on
			lines[l] = added
		end
	end

	return lines
end

local function GetPlayerIcon( muted )

	if muted then
		return "icon16/sound_mute.png"
	end

	return "icon16/sound.png"

end

local function PlayerList()

	local fr = vgui.Create( "dFrame" )
	fr:SetSize( 400, 280 )
	fr:Center()
	fr:SetTitle( "Player List" )
	fr:MakePopup()

	local dlist = vgui.Create( "DPanelList", fr )
	dlist:SetSize( fr:GetWide() - 10, fr:GetTall() - 35 )
	dlist:SetPos( 5, 30 )
	dlist:EnableVerticalScrollbar(true)
	dlist:SetSpacing(2)
	dlist.Padding = 2

	surface.SetFont( "Deathrun_Smooth" )
	local _, tH = surface.GetTextSize( "|" )

	local color = false
	for k, v in pairs( player.GetAll() ) do
		if v == LocalPlayer() then continue end
		color = not color
		v._ListColor = color

		local icon

		local ply = vgui.Create( "DButton" )
		ply:SetText( "" )
		ply:SetSize( 0, 20 )
		ply.DoClick = function()
			if not IsValid(v) then return end
			local muted = v:IsMuted()
			v:SetMuted(not muted)
			icon:SetImage( GetPlayerIcon(not muted) )
		end

		local moved = false
		ply.Paint = function( self, w, h )
			if not IsValid(v) then self:Remove() return end
			surface.SetDrawColor( v._ListColor and Color( 45, 55, 65, 200 ) or Color( 65, 75, 85, 200 ) )
			surface.DrawRect( 0, 0, w, h )
			draw.AAText( v:Nick(), "Deathrun_Smooth", 2 + 16 + 5, h/2 - tH/2, Color(255,255,255,255) )
			if not moved and w != 0 then
				icon:SetPos( ply:GetWide() - 20, ply:GetTall()/2 - icon:GetTall()/2 )
			end
		end

		local ava = vgui.Create( "AvatarImage", ply )
		ava:SetPlayer( v, 32 )
		ava:SetSize( 16, 16 )
		ava:SetPos( 2, 2 )

		icon = vgui.Create( "DImage", ply )
		icon:SetSize( 16, 16 )
		icon:SetPos( ply:GetWide() - 20, ply:GetTall()/2 - icon:GetTall()/2 )
		icon:SetImage( GetPlayerIcon( v:IsMuted() ) )

		dlist:AddItem(ply)
	end


end

local menu
local btn
local function ShowHelp()

	menu = vgui.Create( "DPanel" )
	menu:SetSize( 500, 650 )
	menu:SetPos(-1000,-1000)
	menu:MoveTo( ScrW()/2-menu:GetWide()/2, ScrH()/2-menu:GetTall()/2, 0.25, 0.25, 0.25)
	menu:MakePopup()
	
	menu.Paint = function(self, w, h)	
					Derma_DrawBackgroundBlur( self, SysTime())
					draw.RoundedBoxEx( 0, 0, 0, menu:GetWide(), menu:GetTall(), Color(0,0,0,150), false, false, false, false )
					draw.RoundedBoxEx( 0, 0, 0, menu:GetWide(), 40, Color(4,84,117,255), false, false, false, false )
	end
	
	local LogoCard = vgui.Create('DPanel',menu)
            LogoCard:SetPos(5,2)
            LogoCard:SetSize(175,50)
            function LogoCard:Paint(w,h)
                    draw.SimpleText("Information",'DR_X',LogoCard:GetWide() /2,0,Color(255,255,255,255), TEXT_ALIGN_CENTER)
				   // draw.SimpleText(Texts.LogoCardBottom,'DermaLarge',5,35,Colors.LogoCardBottom)
            end
	
	local btnOK = vgui.Create("DButton", menu)
	btnOK:SetParent(menu)
	btnOK:SetSize(30, 30)
	btnOK:SetPos(menu:GetWide() /2 + 215, 5)
	btnOK:SetText("")
	btnOK:SetFont("Deathrun_SmoothBig")
	btnOK:SetDisabled(false)
	btnOK.DoClick = function()
			menu:Remove() 
	end
	btnOK.Paint = function(self, w, h)
		if self.Hovered then
       		draw.RoundedBoxEx( 0, 0, 0, btnOK:GetWide(), btnOK:GetTall(), Color(117,162,186,255), false, false, false, false )
			draw.SimpleText("x","DR_X",btnOK:GetWide() /2,btnOK:GetTall() /2 - 2,Color(4,84,117,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			draw.RoundedBoxEx( 0, 0, 0, btnOK:GetWide(), btnOK:GetTall(), Color(132,183,210,255), false, false, false, false )
			draw.SimpleText("x","DR_X",btnOK:GetWide() /2,btnOK:GetTall() /2 - 3,Color(4,84,117,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end

//	btn = CreateNumButton( "deathrun_autojump", menu, "AutoJump", "This will make you automatically jump if you hold down your jump key.", nil, nil, "dr_allow_autojump", 1 )

	surface.SetFont( "Deathrun_Smooth" )
	local _, tH = surface.GetTextSize("|")
	

	

	local dlist = vgui.Create( "DPanelList", menu )
	dlist:SetSize( menu:GetWide() - 10, menu:GetTall() - 70 )
	dlist:SetPos( 5, 30 )
	dlist:EnableVerticalScrollbar(true)
	
	
	local text = string.Explode( "\n", GAMEMODE.MenuText )

	for k, v in pairs(text) do
		v = WrapText( v, dlist:GetWide() - 15, "Deathrun_SmoothMed" )
		if #v > 1 then
			v[1] = string.sub( v[1], 2 )
		end

		for _, text in pairs( v ) do

			local label = vgui.Create( "DLabel" )
			label:SetFont( "Deathrun_SmoothMed" )
			label:SetText( text )
			label:SizeToContents()

			dlist:AddItem(label)

		end

	end
	
		local donate = vgui.Create("DButton", menu)
	donate:SetParent(menu)
	donate:SetSize(150, 40)
	donate:SetPos(menu:GetWide() /2 - 75, menu:GetTall() * 0.90)
	donate:SetText("")
	donate:SetDisabled(false)
	donate.DoClick = function()
			gui.OpenURL("http://google.com");
	end
	donate.Paint = function(self, w, h)
		if self.Hovered then
       		draw.RoundedBoxEx( 0, 0, 0, donate:GetWide(), donate:GetTall(), Color(30,135,180,255), false, false, false, false )
			draw.SimpleText("Donate","Deathrun_SmoothBig",donate:GetWide() /2,donate:GetTall() /2,Color(255,255,255,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		else
			draw.RoundedBoxEx( 0, 0, 0, donate:GetWide(), donate:GetTall(), Color(4,84,117,255), false, false, false, false )
			draw.SimpleText("Donate","Deathrun_SmoothBig",donate:GetWide() /2,donate:GetTall() /2,Color(150,150,150,255),TEXT_ALIGN_CENTER,TEXT_ALIGN_CENTER)
		end
	end


end


local function Notify( str )

	notification.AddLegacy( str, NOTIFY_HINT, 3 )
	surface.PlaySound( "ambient/water/drip"..math.random(1, 4)..".wav" )

end

local Deathrun_Funcs = {
	
	["F1"] = ShowHelp,
	["Notify"] = Notify

}

net.Receive( "Deathrun_Func", function()

	local func = net.ReadString()
	local args = net.ReadTable()

	if Deathrun_Funcs[func] then
		Deathrun_Funcs[func]( unpack(args) )
	end

end )

function GM:AddDeathrunFunc( name, func )
	Deathrun_Funcs[name] = func
end

function GM:HUDWeaponPickedUp( wep )

	if (!LocalPlayer():Alive()) then return end
	if not wep.GetPrintName then return end
		
	local pickup = {}
	pickup.time 		= CurTime()
	pickup.name 		=  wep:GetPrintName()
	pickup.holdtime 	= 5
	pickup.font 		= "Deathrun_Smooth"
	pickup.fadein		= 0.04
	pickup.fadeout		= 0.3
	pickup.color		= team.GetColor( LocalPlayer():Team() )
	
	surface.SetFont( pickup.font )
	local w, h = surface.GetTextSize( pickup.name )
	pickup.height		= h
	pickup.width		= w

	if (self.PickupHistoryLast >= pickup.time) then
		pickup.time = self.PickupHistoryLast + 0.05
	end
	
	table.insert( self.PickupHistory, pickup )
	self.PickupHistoryLast = pickup.time 

end

function GM:OnSpawnMenuOpen()
	RunConsoleCommand( "_dr_req_drop" )	
end

local connecting = {}
function GM:GetConnectingPlayers()
	return connecting
end

GM:AddDeathrunFunc( "Connecting_Player", function( name, id )

	connecting[id] = name

end )

GM:AddDeathrunFunc( "Remove_CPlayer", function( id )

	connecting[id] = nil

end )

GM:AddDeathrunFunc( "All_Connecting", function( tab )

	connecting = tab

end )