
surface.CreateFont( "ScoreboardDefault",
{
	font		= "Helvetica",
	size		= 20,
	weight		= 800
})

surface.CreateFont( "ScoreboardDefaultTitle",
{
	font		= "Helvetica",
	size		= 32,
	weight		= 800
})

surface.CreateFont( "ScoreboardSpecs",
{
	font		= "Helvetica",
	size		= 18,
	weight		= 800
})

surface.CreateFont( "PTs",
{
	font		= "Helvetica",
	size		= 16,
	weight		= 800
})

surface.CreateFont( "rank",
{
	font		= "Helvetica",
	size		= 16,
	weight		= 800
})

local PLAYER_LINE = 
{
	Init = function( self )
	
		self.Player = ply

		self.AvatarButton = self:Add( "DButton" )
		self.AvatarButton:Dock( LEFT )
		self.AvatarButton:SetSize( 32, 32 )
		self.AvatarButton.DoClick = function() self.Player:ShowProfile() end

		self.Avatar		= vgui.Create( "AvatarImage", self.AvatarButton )
		self.Avatar:SetSize( 32, 32 )
		self.Avatar:SetMouseInputEnabled( false )		

		self.Name		= self:Add( "DLabel" )
		self.Name:Dock( FILL )
		self.Name:SetFont( "ScoreboardDefault" )
		self.Name:DockMargin( 4, -16, 0, 0 )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		
		self.Rank		= self:Add( "DLabel" )
		self.Rank:Dock(FILL)
		self.Rank:SetFont ( "rank" )
		self.Rank:DockMargin ( 4, 16, 0, 0 )

		
		self.Points		= self:Add( "DLabel" )
		self.Points:Dock( FILL )
		self.Points:SetFont( "PTs" )
		self.Points:DockMargin( 150, 0, 0, 0 )
		self.Points:SetTextColor( Color( 255, 210, 10, 255 ) )
		
		


		self.Ping		= self:Add( "DLabel" )
		self.Ping:Dock( RIGHT )
		self.Ping:SetWidth( 50 )
		self.Ping:SetFont( "ScoreboardDefault" )
		self.Ping:SetContentAlignment( 5 )
		self.Ping:SetTextColor( Color(50,50,50,255) )

		--[[self.Deaths		= self:Add( "DLabel" )
		self.Deaths:Dock( RIGHT )
		self.Deaths:SetWidth( 50 )
		self.Deaths:SetFont( "ScoreboardDefault" )
		self.Deaths:SetContentAlignment( 5 )--]]--


		self:Dock( TOP )
		self:DockPadding( 3, 3, 3, 3 )
		self:SetHeight( 48 )
		self:DockMargin( 2, 0, 2, 2 )

	end,

	Setup = function( self, pl )

		self.Player = pl

		self.Avatar:SetPlayer( pl )
		self.Name:SetText( pl:Nick() )
		if pl:IsUserGroup() == "superadmin" then
			self.Rank:SetTextColor( Color( 255,50,10,255 ) )
		else
			self.Rank:SetTextColor( Color( 0,0,0,255) )
		end
		if pl:IsUserGroup("superadmin") then
			self.Rank:SetText( "Super Admin" )
		end
		self.Points:SetText ( pl:PS_GetPoints(), TEXT_ALIGN_CENTER )

		self:Think( self )

		--local friend = self.Player:GetFriendStatus()
		--MsgN( pl, " Friend: ", friend )

	end,

	Think = function( self )

		if ( !IsValid( self.Player ) ) then
			self:Remove()
			return
		end

		if ( self.NumPing == nil || self.NumPing != self.Player:Ping() ) then
			self.NumPing	=	self.Player:Ping()
			self.Ping:SetText( self.NumPing )
		end





		--
		-- Connecting players go at the very bottom
		--
		if ( self.Player:Team() == TEAM_CONNECTING ) then
			self:SetZPos( 2000 )
		end

		--
		-- This is what sorts the list. The panels are docked in the z order, 
		-- so if we set the z order according to kills they'll be ordered that way!
		-- Careful though, it's a signed short internally, so needs to range between -32,768k and +32,767
		--


	end,

	Paint = function( self, w, h )

		if ( !IsValid( self.Player ) ) then
			return
		end

		--
		-- We draw our background a different colour based on the status of the player
		--

		if ( self.Player:Team() == TEAM_CONNECTING ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color( 200, 200, 200, 200 ) )
			return
		end

		if  ( !self.Player:Alive() ) then
			draw.RoundedBox( 4, 0, 0, w, h, Color(220,220,220,255) )
			return
		end
		
		if self.Player:IsUserGroup("owner") then
		draw.RoundedBox( 4, 0, 0, w, h, Color(0,0,0,255) )
		elseif self.Player:IsUserGroup("superadmin") then
		//draw.RoundedBox( 4, 0, 0, w, h, Color( 255,50,10,255 ) )
		draw.RoundedBox( 4, 0, 0, w - 50, h, Color(20,150,255,255) )
		draw.RoundedBox ( 0, 280, 0, w, h, Color(220,220,220,255) ) 
		else
		draw.RoundedBox( 4, 0, 0, w, h, team.GetColor(self.Player:Team()) )
		end

	end,
}

--
-- Convert it from a normal table into a Panel Table based on DPanel
--
PLAYER_LINE = vgui.RegisterTable( PLAYER_LINE, "DPanel" );

--
-- Here we define a new panel table for the scoreboard. It basically consists 
-- of a header and a scrollpanel - into which the player lines are placed.
--
local SCORE_BOARD = 
{
	Init = function( self )

		self.Header = self:Add( "Panel" )
		self.Header:Dock( TOP )
		self.Header:SetHeight( 140 )

		self.Name = self.Header:Add( "DLabel" )
		self.Name:SetFont( "ScoreboardDefaultTitle" )
		self.Name:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.Name:Dock( BOTTOM )
		self.Name:SetHeight( 40 )
		self.Name:SetContentAlignment( 5 )
		self.Name:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		--self.NumPlayers = self.Header:Add( "DLabel" )
		--self.NumPlayers:SetFont( "ScoreboardDefault" )
		--self.NumPlayers:SetTextColor( Color( 255, 255, 255, 255 ) )
		--self.NumPlayers:SetPos( 0, 100 - 30 )
		--self.NumPlayers:SetSize( 300, 30 )
		--self.NumPlayers:SetContentAlignment( 4 )
		
		self.Specs = self:Add( "DLabel" )
		self.Specs:Dock(BOTTOM)
		self.Specs:SetHeight(18)
		self.Specs:SetFont( "ScoreboardSpecs" )
		self.Specs:SetTextColor( Color(255,255,255,255) )
		self.Specs:SetContentAlignment( 5 )
		self.Specs:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )

		self.Scores = self:Add( "Panel" )
		self.Scores:Dock( FILL )
		
		--
		--Administrators side
		--
		self.AdminPanel = self.Scores:Add("Panel")
		self.AdminPanel:Dock( LEFT )
		self.AdminPanel:SetWidth(340)
		
		self.AdminName = self.AdminPanel:Add("DLabel")
		self.AdminName:Dock(TOP)
		self.AdminName:SetFont("ScoreboardDefaultTitle")
		self.AdminName:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.AdminName:SetHeight( 32 )
		self.AdminName:SetContentAlignment( 5 )
		--self.AdminName:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		self.AdminName:SetText("Runners")
		
		self.AdminScores = self.AdminPanel:Add("DScrollPanel")
		self.AdminScores:Dock(FILL)
		--self.AdminScores:SetHeight(300)
		
		--
		--Mingebag side
		--
		self.MingePanel = self.Scores:Add("Panel")
		self.MingePanel:Dock( RIGHT )
		self.MingePanel:SetWidth(340)
		
		self.MingeName = self.MingePanel:Add("DLabel")
		self.MingeName:Dock(TOP)
		self.MingeName:SetFont("ScoreboardDefaultTitle")
		self.MingeName:SetTextColor( Color( 255, 255, 255, 255 ) )
		self.MingeName:SetHeight( 32 )
		self.MingeName:SetContentAlignment( 5 )
		--self.AdminName:SetExpensiveShadow( 2, Color( 0, 0, 0, 200 ) )
		self.MingeName:SetText("Deaths")
		
		self.MingeScores = self.MingePanel:Add("DScrollPanel")
		self.MingeScores:Dock(FILL)
		--self.MingeScores:SetHeight(300)

	end,

	PerformLayout = function( self )

		self:SetSize( 700, ScrH() - 200 )
		self:SetPos( ScrW() / 2 - 350, 100 )

	end,

	Paint = function( self, w, h )

		draw.RoundedBox( 4, 0, 0, w, h, Color( 50, 50, 50, 200 ) )
		
		--draw.SimpleText("Spectators/Unassigned: "..table.concat(specsN,", "), "ScoreboardSpecs", w/2, 88, Color(255,255,255,255), TEXT_ALIGN_CENTER)
		//surface.SetTexture(surface.GetTextureID("VGUI/metastrike_logo_scoreboard"))
		//surface.SetDrawColor(255,255,255,255)
		//surface.DrawTexturedRect(0,0,w,w/4)
	end,

	Think = function( self, w, h )
		local specs = {}
		table.Add(specs, team.GetPlayers(TEAM_CONNECTING))
		table.Add(specs, team.GetPlayers(TEAM_UNASSIGNED))
		table.Add(specs, team.GetPlayers(TEAM_SPECTATOR))
		local specsN = {}
		for k,pl in pairs(specs) do
			specsN[k]=pl:Name()
		end
		self.Specs:SetText("Spectators/Unassigned: "..table.concat(specsN,", "))
		self.Name:SetText( GetHostName() )
		self.AdminName:SetText("Runners")
		self.MingeName:SetText("Deaths")

		--
		-- Loop through each player, and if one doesn't have a score entry - create it.
		--
		local plyrs = player.GetAll()
		for id, pl in pairs( plyrs ) do
			if pl:Team()==TEAM_RUNNER or pl:Team()==TEAM_DEATH then
			if ( IsValid( pl.ScoreEntry ) ) then 
				continue 
			end

			pl.ScoreEntry = vgui.CreateFromTable( PLAYER_LINE, pl.ScoreEntry )
			pl.ScoreEntry:Setup( pl )

			if pl:Team()==TEAM_RUNNER then self.AdminScores:AddItem( pl.ScoreEntry ) end
			if pl:Team()==TEAM_DEATH then self.MingeScores:AddItem( pl.ScoreEntry ) end
			end
		end		

	end,
}

SCORE_BOARD = vgui.RegisterTable( SCORE_BOARD, "EditablePanel" );

function GM:ScoreboardShow()

	if ( !IsValid( g_Scoreboard ) ) then
		g_Scoreboard = vgui.CreateFromTable( SCORE_BOARD )
	end

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Show()
		g_Scoreboard:MakePopup()
		g_Scoreboard:SetKeyboardInputEnabled( false )
		RefreshScoreboard()
	end

end

--[[---------------------------------------------------------
   Name: gamemode:ScoreboardHide( )
   Desc: Hides the scoreboard
-----------------------------------------------------------]]
function GM:ScoreboardHide()

	if ( IsValid( g_Scoreboard ) ) then
		g_Scoreboard:Hide()
	end

end

function RefreshScoreboard()
	for id,pl in pairs(player.GetAll()) do
		if ( IsValid( pl.ScoreEntry ) ) then 
			pl.ScoreEntry:Remove()
			pl.ScoreEntry=nil
		end
	end
end

usermessage.Hook("RefreshScoreboard", RefreshScoreboard)