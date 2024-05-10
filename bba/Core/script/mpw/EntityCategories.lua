--------------------------------------------------------------------------------
MPW.EntityCategories = {}
MPW.EntityCategories.CurrentIndex = 51
MPW.EntityCategories.Backup = {} -- [_string] = _number
MPW.EntityCategories.Assignment = {}
--------------------------------------------------------------------------------
function MPW.EntityCategories.Init()

    MPW.EntityCategories.AddEntityCategory("Axe")

    MPW.EntityCategories.AssignEntityCategory(Entities.CU_BanditLeaderSword1, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.CU_BanditLeaderSword2, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.CU_BanditSoldierSword1, EntityCategories.Axe)
    MPW.EntityCategories.AssignEntityCategory(Entities.CU_BanditSoldierSword2, EntityCategories.Axe)
end
--------------------------------------------------------------------------------
function MPW.EntityCategories.Load()

    MPW.EntityCategories.RestoreEntityCategories()

    MPW.EntityCategories.IsEntityInCategory = Logic.IsEntityInCategory
    function Logic.IsEntityInCategory( _Id, _EntityCategory )
        if MPW.EntityCategories.IsEntityInCategory(_Id, _EntityCategory) == 1 then
            return 1
        end
        local lut = MPW.EntityCategories.Assignment[Logic.GetEntityType(_Id)]
        if lut then
            for i = 1, table.getn(lut) do
                if lut[i] == _EntityCategory then
                    return 1
                end
            end
        end
        return 0
    end
end
--------------------------------------------------------------------------------
function MPW.EntityCategories.AddEntityCategory( _String )
    EntityCategories[_String] = MPW.EntityCategories.CurrentIndex
    MPW.EntityCategories.Backup[_String] = MPW.EntityCategories.CurrentIndex
    MPW.EntityCategories.CurrentIndex = MPW.EntityCategories.CurrentIndex + 1
end
--------------------------------------------------------------------------------
function MPW.EntityCategories.RestoreEntityCategories()
    for name, value in pairs(MPW.EntityCategories.Backup) do
        EntityCategories[name] = value
    end
end
--------------------------------------------------------------------------------
function MPW.EntityCategories.AssignEntityCategory( _EntityType, _EntityCategory )
    MPW.EntityCategories.Assignment[_EntityType] = MPW.EntityCategories.Assignment[_EntityType] or {}
    table.insert(MPW.EntityCategories.Assignment[_EntityType], _EntityCategory)
end