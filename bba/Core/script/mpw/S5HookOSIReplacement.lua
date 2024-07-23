MPW.OSIReplacement = {}
MPW.OSIReplacement.MaxNumberOfWidgets = 256
MPW.OSIReplacement.CurrentNumberOfWidgets = 0
MPW.OSIReplacement.LastNumberOfWidgets = 0
MPW.OSIReplacement.TimeOfLastGameTick = 0

function MPW.OSIReplacement.Init()
    if not WidgetHelper then
        Script.Load( "MP_SettlerServer\\WidgetHelper.lua" )
    end
        WidgetHelper.AddPreCommitCallback(
            function()
                for i = 1, MPW.OSIReplacement.MaxNumberOfWidgets do
                    CWidget.Transaction_AddRawWidgets(
                        [[<WidgetList classname="EGUIX::CStaticWidget" classid="0x213a8776">
                            <Name>OSIReplacement]]..i..[[</Name>
                            <Rectangle>
                                <X>0</X>
                                <Y>0</Y>
                                <W>1</W>
                                <H>1</H>
                            </Rectangle>
                            <IsShown>False</IsShown>
                            <ZPriority>0</ZPriority>
                            <MotherID>Root</MotherID>
                            <Group></Group>
                            <ForceToHandleMouseEventsFlag>False</ForceToHandleMouseEventsFlag>
                            <ForceToNeverBeFoundFlag>False</ForceToNeverBeFoundFlag>
                            <BackgroundMaterial>
                                <Texture>data\graphics\textures\gui\dbg_arrow.png</Texture>
                                <TextureCoordinates>
                                    <X>0</X>
                                    <Y>0</Y>
                                    <W>1</W>
                                    <H>1</H>
                                </TextureCoordinates>
                                <Color>
                                    <Red>255</Red>
                                    <Green>255</Green>
                                    <Blue>255</Blue>
                                    <Alpha>255</Alpha>
                                </Color>
                            </BackgroundMaterial>
                        </WidgetList>]]
                    )
                end
            end
        )
end

function MPW.OSIReplacement.Load()
    function S5Hook.OSILoadImage(_TexturePath)
        return "data\\" .. _TexturePath .. ".png"
    end

    function S5Hook.OSIDrawImage(_Image, _X, _Y, _W, _H)
        if MPW.OSIReplacement.CurrentNumberOfWidgets < MPW.OSIReplacement.MaxNumberOfWidgets then
            MPW.OSIReplacement.CurrentNumberOfWidgets = MPW.OSIReplacement.CurrentNumberOfWidgets + 1

            local sizex, sizey = GUI.GetScreenSize()
            local factorx, factory = 1024 / sizex, 768 / sizey
            local widget = "OSIReplacement" .. MPW.OSIReplacement.CurrentNumberOfWidgets

            XGUIEng.ShowWidget(widget, 1)
            XGUIEng.SetWidgetPositionAndSize(widget, _X * factorx, _Y * factory, _W * factorx, _H * factory)
            XGUIEng.SetMaterialTexture(widget, 0, _Image)
        end
    end

    function S5Hook.OSISetDrawTrigger(_Function)
        MPW.OSIReplacement.Callback = _Function
    end
end

function MPW.OSIReplacement.PostInit()
    StartSimpleHiResJob(MPW.OSIReplacement.Job)
    
    MPW.GUIUpdate_Population = GUIUpdate_Population
    function GUIUpdate_Population()
        MPW.GUIUpdate_Population()

        -- dont do anything without a callback
        -- TODO: widgets wont disapear, if callback gets deleted
        if MPW.OSIReplacement.Callback then
            -- with exponent 1.4 the distance from camera location to screen corner on flat map is allways about the same
            local range = math.max(4000 * (Camera.GetZoomFactor() ^ 1.4),2000)
            local camerax, cameray = Camera.ScrollGetLookAt()
            local sizex, sizey = GUI.GetScreenSize()

            for id in CEntityIterator.Iterator(CEntityIterator.InRangeFilter(camerax, cameray, range), CEntityIterator.IsNotSoldierFilter(), CEntityIterator.OfCategoryFilter(EntityCategories.Military)) do
                local x, y = GetEntityOSIWidgetPosition(id)

                -- do all draw calls on screen
                if x >= 0 and y >= 0 and x <= sizex and y <= sizey then
                    MPW.OSIReplacement.Callback(id, IsEntityOSIWidgetActive(id), x, y)
                end
            end
        
            -- remove leftover widgets from last call
            for i = MPW.OSIReplacement.CurrentNumberOfWidgets + 1, MPW.OSIReplacement.LastNumberOfWidgets do
                XGUIEng.ShowWidget("OSIReplacement" .. i, 0)
            end

            MPW.OSIReplacement.LastNumberOfWidgets = MPW.OSIReplacement.CurrentNumberOfWidgets
            MPW.OSIReplacement.CurrentNumberOfWidgets = 0
        end
    end
end

function MPW.OSIReplacement.Job()
    MPW.OSIReplacement.TimeOfLastGameTick = XGUIEng.GetSystemTime()
end

---@param _EntityId number
---@return number X
---@return number Y
function GetEntityOSIWidgetPosition(_EntityId)
	local x, y, z = Logic.EntityGetPos(_EntityId)
    local gamespeed = Game.GameTimeGetFactor()

    -- estimate position
    -- TODO: interpolate z as well
    if Logic.IsEntityMoving(_EntityId) and gamespeed > 0 then
        local entityspeed = Memory.GetEntityMovementSpeed(_EntityId)
        local movement = Memory.GetEntityMovementBehavior(_EntityId)
        local rotation = math.atan2(movement[10]:GetFloat()-movement[13]:GetFloat(), movement[9]:GetFloat()-movement[12]:GetFloat()) --math.rad(Logic.GetEntityOrientation(_EntityId))
        local deltatime = (XGUIEng.GetSystemTime() - MPW.OSIReplacement.TimeOfLastGameTick) * gamespeed - 0.1 -- subtract one tick

        x = x + entityspeed * deltatime * math.cos(rotation)
        y = y + entityspeed * deltatime * math.sin(rotation)
    end

    local offset = (Logic.IsEntityInCategory(_EntityId,EntityCategories.CavalryHeavy) == 1 or Logic.IsEntityInCategory(_EntityId,EntityCategories.CavalryLight) == 1) and 320 or 200
	return Camera.GetScreenCoord(x, y, z + offset)
end

---@param _EntityId number
---@return boolean
function IsEntityOSIWidgetActive(_EntityId)
    local target = CUtil.GetTargetedEntity()
    if _EntityId == target then
        return true
    else
        local leader = CEntity.GetAttachedEntities(target)
        if leader and leader[31] and leader[31][1] == _EntityId then
            return true
        end
    end
    for _, selectedentity in pairs({GUI.GetSelectedEntities()}) do
        if _EntityId == selectedentity then
            return true
        end
    end
    return false
end