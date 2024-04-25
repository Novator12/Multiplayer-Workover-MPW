--------------------------------------------------------------------------------
MPW.OSI.Cannons = {}
--------------------------------------------------------------------------------
function MPW.OSI.Cannons.PostInit()

	MPW.OSI.Cannons.Images = {
		S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_1" ),
		S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_2" ),
		S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_3" ),
		S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_4" ),
		S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_5" ),
	}
	
	table.insert( MPW.OSI.DrawCalls, MPW.OSI.Cannons.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.Cannons.DrawCall( _Id, _Active, _X, _Y )
	
	if Logic.IsEntityInCategory( _Id, EntityCategories.Cannon ) == 1 and Logic.IsLeader( _Id ) == 1 then
		
		local amount = Logic.GetLeaderExperienceLevel( _Id ) + 1
		
		if amount > 0 then
			
			S5Hook.OSIDrawImage( MPW.OSI.Cannons.Images[ amount ], _X - 33, _Y - 16, 32, 32 )
		end
	end
end