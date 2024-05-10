--------------------------------------------------------------------------------
MPW.OSI.Leader = {}
--------------------------------------------------------------------------------
function MPW.OSI.Leader.PostInit()
	
	MPW.OSI.Leader.DrawExperience = {
		EntityCategories.Cannon,
		--EntityCategories.Axe,
	}
	
	table.insert( MPW.OSI.DrawCalls, MPW.OSI.Leader.DrawCall )
end
--------------------------------------------------------------------------------
function MPW.OSI.Leader.PostLoad()

	MPW.OSI.Leader.DrawEmblem = {
		[EntityCategories.Axe] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\mo_emblem_axe" ),
	}
	
	MPW.OSI.Leader.Images = {
		[0] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_1" ),
		[1] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_2" ),
		[2] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_3" ),
		[3] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_4" ),
		[4] = S5Hook.OSILoadImage( "graphics\\textures\\gui\\onscreen_stars_5" ),
	}
end
--------------------------------------------------------------------------------
function MPW.OSI.Leader.DrawCall( _Id, _Active, _X, _Y )
	
	if Logic.IsLeader( _Id ) == 1 and Logic.IsHero( _Id ) == 0 then
		for i = 1, table.getn(MPW.OSI.Leader.DrawExperience) do
			if Logic.IsEntityInCategory( _Id, MPW.OSI.Leader.DrawExperience[i] ) == 1 then
				
				local amount = Logic.GetLeaderExperienceLevel( _Id )
				
				if amount >= 0 then
					S5Hook.OSIDrawImage( MPW.OSI.Leader.Images[ amount ], _X - 33, _Y - 16, 32, 32 )
				end
			end
		end

		for entitycategory, emblem in pairs(MPW.OSI.Leader.DrawEmblem) do
			if Logic.IsEntityInCategory( _Id, entitycategory ) == 1 then
				S5Hook.OSIDrawImage( emblem, _X - 33, _Y - 16, 32, 32 )
			end
		end
	end
end