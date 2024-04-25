Script.Load( "maps\\user\\EMS\\tools\\s5CommunityLib\\comfort\\math\\astar.lua" )
----------------------------------------------------------------------------------------------------------------------------------------------------------------
Chunk = Chunk or {}
Chunk.Size = 32
Chunk.Amount = Logic.WorldGetSize() / (Chunk.Size * 100) - 1 -- subtract 1 because its 0-based
Chunk.Chunks = {}
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Chunk.Init()

    for x = 0, Chunk.Amount do
        Chunk.Chunks[x] = {}
        for y = 0, Chunk.Amount do
            Chunk.Chunks[x][y] = { Nodes = {}, Sectors = {} }
            Chunk.CreateChunkSectorData(x, y)
        end
    end

    for x = 0, Chunk.Amount do
        for y = 0, Chunk.Amount do
            Chunk.CreateChunkSectorConnections(x, y)
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- updates sectors of given chunks
---@param _ChunkX1 number
---@param _ChunkY1 number
---@param _ChunkX2 number
---@param _ChunkY2 number
function Chunk.UpdateChunks(_ChunkX1, _ChunkY1, _ChunkX2, _ChunkY2)

    for x = _ChunkX1, _ChunkX2 do
        for y = _ChunkY1, _ChunkY2 do
            Chunk.CreateChunkSectorData(x, y)
        end
    end

end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- fills the given chunks sector data
---@param _ChunkX number
---@param _ChunkY number
function Chunk.CreateChunkSectorData(_ChunkX, _ChunkY)

    --Chunk.Chunks[_ChunkX] = Chunk.Chunks[_ChunkX] or {}
    --Chunk.Chunks[_ChunkX][_ChunkY] = Chunk.Chunks[_ChunkX][_ChunkY] or { Nodes = {}, Sectors = {} }
    
    -- create / clear data
    -- forward declaration is neccessary for neighbours
    for x = 0, Chunk.Size do
        Chunk.Chunks[_ChunkX][_ChunkY].Nodes[x] = {}
    end
    
    -- location of chunk[0][0]
    local chunkx, chunky = _ChunkX * Chunk.Size, _ChunkY * Chunk.Size
    local chunk = Chunk.Chunks[_ChunkX][_ChunkY]
    local numberofsectors = 0

    -- fill node data
    for x = 0, Chunk.Size do
        for y = 0, Chunk.Size do
            if not chunk.Nodes[x][y] then
                -- here we only want to increment the sector, if a valide node was actually assigned to the next sector
                -- to prevent skipping sectors on invalid nodes which were assigned with 0
                numberofsectors = numberofsectors + Chunk.CreateNodesSectorData(chunkx, chunky, x, y, chunk.Nodes, numberofsectors + 1)
            end
        end
    end

    -- prepare / clear sector data
    -- this gets filled with connected sectors of adjacent chunks
    -- do this here, because now we still know how many sectors there are
    for sector = 1, numberofsectors do
        -- astar data
        chunk.Sectors[sector] = {X = _ChunkX, Y = _ChunkY, S = sector}
    end

    -- mark directions as dirty
    chunk.North, chunk.East, chunk.South, chunk.Weat = nil, nil, nil, nil
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- fills sector data of given node and its neighbours
---@param _ChunkX number absolute
---@param _ChunkY number absolute
---@param _X number relative
---@param _Y number relative
---@param _Nodes table
---@param _Sector number
---@return number success
function Chunk.CreateNodesSectorData(_ChunkX, _ChunkY, _X, _Y, _Nodes, _Sector)
    local success = 0
    for x = math.max(_X-1, 0), math.min(_X+1, Chunk.Size) do
        for y = math.max(_Y-1, 0), math.min(_Y+1, Chunk.Size) do
            if not _Nodes[x][y] then
                if IsNodeWalkable(_ChunkX + x, _ChunkY + y) then
                    -- at least one node was assigned with the current sector
                    -- so we set the return to 1 to increment sector
                    success = 1
                    _Nodes[x][y] = _Sector
                    Chunk.CreateNodesSectorData(_ChunkX, _ChunkY, x, y, _Nodes, _Sector)
                else
                    _Nodes[x][y] = 0
                end
            end
        end
    end
    return success
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- connect chunk sectors
---@param _ChunkX number
---@param _ChunkY number
function Chunk.CreateChunkSectorConnections(_ChunkX, _ChunkY)

    --[[ the data should look like this:

    Chunk[3][5].Sectors = {
        [1] = {
            X = 3,
            Y = 5,
            S = 1,
            [1] = {
                X = 3,
                Y = 6,
                S = 2,
            },
            [2] = {
                X = 4,
                Y = 5,
                S = 2,
            },
            [3] = {
                X = 3,
                Y = 4,
                S = 1,
            },
            [4] = {
                X = 2,
                Y = 5,
                S = 1,
            },
        },
        [2] = {
            X = 3,
            Y = 5,
            S = 2,
            [1] = {
                X = 3,
                Y = 6,
                S = 1,
            },
            [2] = {
                X = 2,
                Y = 5,
                S = 1,
            },
            [3] = {
                X = 2,
                Y = 5,
                S = 2,
            },
        },
        [3] = {
            X = 3,
            Y = 5,
            S = 3,
            [1] = {
                X = 4,
                Y = 5,
                S = 1,
            },
            [2] = {
                X = 3,
                Y = 4,
                S = 2,
            },
        },
    }
    --]]

    -- NOTE: cant really avoid code repetition with this directional stuff 
    local chunk = Chunk.Chunks[_ChunkX][_ChunkY]
    -----------------------------------------------------------------------------------------------------------
    -- north
    if (not chunk.North) and _ChunkY < Chunk.Amount then

        local neighbour = Chunk.Chunks[_ChunkX][_ChunkY+1]
        local sectors = {}

        -- check all overlapping nodes
        for x = 0, Chunk.Size do
            local chunksector, neighboursector = chunk.Nodes[x][Chunk.Size], neighbour.Nodes[x][0]
            if chunksector ~= 0 and neighboursector ~= 0 then
                sectors[chunksector] = sectors[chunksector] or {}
                table.addunique(sectors[chunksector], neighboursector)
            end
        end

        for k, t in pairs(sectors) do
            for _, v in pairs(t) do
                table.insert(chunk.Sectors[k], {X = _ChunkX, Y = _ChunkY+1, S = v})
                chunk.North = true
                table.insert(neighbour.Sectors[v], {X = _ChunkX, Y = _ChunkY, S = k})
                neighbour.South = true
            end
        end
    end
    -----------------------------------------------------------------------------------------------------------
    -- east
    if (not chunk.East) and _ChunkX < Chunk.Amount then

        local neighbour = Chunk.Chunks[_ChunkX+1][_ChunkY]
        local sectors = {}

        -- check all overlapping nodes
        for y = 0, Chunk.Size do
            local chunksector, neighboursector = chunk.Nodes[Chunk.Size][y], neighbour.Nodes[0][y]
            if chunksector ~= 0 and neighboursector ~= 0 then
                sectors[chunksector] = sectors[chunksector] or {}
                table.addunique(sectors[chunksector], neighboursector)
            end
        end

        for k, t in pairs(sectors) do
            for _, v in pairs(t) do
                table.insert(chunk.Sectors[k], {X = _ChunkX+1, Y = _ChunkY, S = v})
                chunk.East = true
                table.insert(neighbour.Sectors[v], {X = _ChunkX, Y = _ChunkY, S = k})
                neighbour.West = true
            end
        end
    end
    -----------------------------------------------------------------------------------------------------------
    -- south
    if (not chunk.South) and _ChunkY > 0 then

        local neighbour = Chunk.Chunks[_ChunkX][_ChunkY-1]
        local sectors = {}

        -- check all overlapping nodes
        for x = 0, Chunk.Size do
            local chunksector, neighboursector = chunk.Nodes[x][0], neighbour.Nodes[x][Chunk.Size]
            if chunksector ~= 0 and neighboursector ~= 0 then
                sectors[chunksector] = sectors[chunksector] or {}
                table.addunique(sectors[chunksector], neighboursector)
            end
        end

        for k, t in pairs(sectors) do
            for _, v in pairs(t) do
                table.insert(chunk.Sectors[k], {X = _ChunkX, Y = _ChunkY-1, S = v})
                chunk.South = true
                table.insert(neighbour.Sectors[v], {X = _ChunkX, Y = _ChunkY, S = k})
                neighbour.North = true
            end
        end
    end
    -----------------------------------------------------------------------------------------------------------
    -- west
    if (not chunk.West) and _ChunkX > 0 then

        local neighbour = Chunk.Chunks[_ChunkX-1][_ChunkY]
        local sectors = {}

        -- check all overlapping nodes
        for y = 0, Chunk.Size do
            local chunksector, neighboursector = chunk.Nodes[0][y], neighbour.Nodes[Chunk.Size][y]
            if chunksector ~= 0 and neighboursector ~= 0 then
                sectors[chunksector] = sectors[chunksector] or {}
                table.addunique(sectors[chunksector], neighboursector)
            end
        end

        for k, t in pairs(sectors) do
            for _, v in pairs(t) do
                table.insert(chunk.Sectors[k], {X = _ChunkX-1, Y = _ChunkY, S = v})
                chunk.West = true
                table.insert(neighbour.Sectors[v], {X = _ChunkX, Y = _ChunkY, S = k})
                neighbour.East = true
            end
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get an aproximate walk distance betwenn two positions on the map
---@param _X1 number
---@param _Y1 number
---@param _X2 number
---@param _Y2 number
---@param _MaxLength? number
---@return number|nil
function Chunk.GetSectorPathDistance(_X1, _Y1, _X2, _Y2, _MaxLength)
    local pathlength = Chunk.GetSectorPathLength(_X1, _Y1, _X2, _Y2, _MaxLength)
    if pathlength then
        return pathlength * Chunk.Size * 100
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get number of sectors betwenn two positions on the map
---@param _X1 number
---@param _Y1 number
---@param _X2 number
---@param _Y2 number
---@param _MaxLength? number
---@return number|nil
function Chunk.GetSectorPathLength(_X1, _Y1, _X2, _Y2, _MaxLength)
    local path = Chunk.FindSectorPathByLocations(_X1, _Y1, _X2, _Y2, _MaxLength)
    if path then
        return table.getn(path)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get a coarse path betwenn two positions on the map
---@param _X1 number
---@param _Y1 number
---@param _X2 number
---@param _Y2 number
---@param _MaxLength? number
---@return table|nil
function Chunk.FindSectorPathByLocations(_X1, _Y1, _X2, _Y2, _MaxLength)

    local sector1, sector2 = Chunk.GetSectorByLocation(_X1, _Y1), Chunk.GetSectorByLocation(_X2, _Y2)
    
    -- same chunk and same sector - same result with astar
    --if chunkx1 == chunkx2 and chunky1 == chunky2 and sector1 == sector2 then
        --return {}
    --end
    if sector1 and sector2 then
        --TODO: find a way to differenciate between length and distance
        --if _MaxLength then
           -- _MaxLength = _MaxLength / (Chunk.Size * 100)
        --end
        return Chunk.FindSectorPathBySectors(sector1, sector2, _MaxLength)
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get a coarse path betwenn two positions on the map
---@param _Sector1 table sector object in Chunk.Chunks[chunkX][chunkY].Sectors[sector]
---@param _Sector2 table
---@return table|nil path
function Chunk.FindSectorPathBySectors(_Sector1, _Sector2, _MaxLength)
    return AStar.FindPath(_Sector1, _Sector2, Chunk.Chunks, Chunk.GetNeighborNodes, Chunk.GetPathCost, _MaxLength)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Chunk.GetSectorByEntity(_EntityId)
    local x, y = Logic.GetEntityPosition(_EntityId)
    return Chunk.GetSectorByLocation(x, y)
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
function Chunk.GetSectorByLocation(_X, _Y)
    local size = Chunk.Size * 100

    -- chunk coords
    local chunkx, chunky = math.floor(_X / size), math.floor(_Y / size)
    -- relative node coords
    local x, y = math.mod(math.floor(_X / 100), Chunk.Size), math.mod(math.floor(_Y / 100), Chunk.Size)
    -- sectors of nodes
    local sector = Chunk.Chunks[chunkx][chunky].Nodes[x][y]

    return Chunk.Chunks[chunkx][chunky].Sectors[sector]
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get nodes neighbours
--
-- internal
---@param _ThisNode table
---@param _Nodes table
---@return table
function Chunk.GetNeighborNodes(_ThisNode, _Nodes)
    local neighbours = {}
    for _, node in ipairs(_ThisNode) do
        table.insert(neighbours, _Nodes[node.X][node.Y].Sectors[node.S])
    end
    return neighbours
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- internal
function Chunk.GetPathCost(_NodeA, _NodeB)
    return 1
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get nearby walkable position in scm
-- optional MaxDistance to look for and Sector to match found position
---@param _X number
---@param _Y number
---@param _MaxDistance? number
---@param _Sector? number
---@return number|nil x
---@return number|nil y
function GetNearbyWalkablePosition(_X, _Y, _MaxDistance, _Sector)
    local x, y = GetNearbyWalkableNode(math.floor(_X / 100), math.floor(_Y / 100), math.floor((_MaxDistance or 1600) / 100), _Sector)
    if x then
        return x * 100, y * 100
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- get nearby walkable position in sm
-- optional MaxDistance to look for and Sector to match found position
---@param _X number
---@param _Y number
---@param _MaxDistance? number
---@param _Sector? number
---@return number|nil x
---@return number|nil y
function GetNearbyWalkableNode(_X, _Y, _MaxDistance, _Sector)
    
    if IsNodeWalkable(_X, _Y, _Sector) then
        return _X, _Y
    end

    _MaxDistance = _MaxDistance or 16

    for i = 1, _MaxDistance do
        for x = _X-i, _X+i-1 do
            if IsNodeWalkable(x, _Y-i, _Sector) then
                return x, _Y-i
            end
        end
        for y = _Y-i, _Y+i-1 do
            if IsNodeWalkable(_X+i, y, _Sector) then
                return _X+i, y
            end
        end
        for x = _X+i, _X-i+1, -1 do
            if IsNodeWalkable(x, _Y+i, _Sector) then
                return x, _Y+i
            end
        end
        for y = _Y+i, _Y-i+1, -1 do
            if IsNodeWalkable(_X-i, y, _Sector) then
                return _X-i, y
            end
        end
    end
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- checks if a node is walkable by units, ignores build block
---@param _X number
---@param _Y number
---@param _Sector? number
---@return boolean
function IsNodeWalkable(_X, _Y, _Sector)
    local sector = CUtil.GetSector(_X, _Y)
    if sector ~= 0 and ((not _Sector) or _Sector == sector) then
        return true
    end
    return false
end
----------------------------------------------------------------------------------------------------------------------------------------------------------------
-- adds a unique value at the end of given table
---@param _table table
---@param _value any
function table.addunique(_table, _value)
    for _,v in pairs(_table) do
        if v == _value then
            return
        end
    end
    table.insert(_table, _value)
end