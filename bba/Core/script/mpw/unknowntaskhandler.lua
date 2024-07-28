----------------------------------------------------------------------------------------------
MPW.UnknownTaskHandler = {}
----------------------------------------------------------------------------------------------
MPW.GameCallback_UnknownTask = GameCallback_UnknownTask or function() return 0 end
function GameCallback_UnknownTask(_Id)

    local result = MPW.GameCallback_UnknownTask(_Id)
	local taskhandler = MPW.UnknownTaskHandler[Logic.GetCurrentTaskList(_Id)]

	if taskhandler then

		local taskindex = CUtilMemory.GetMemory(CUtilMemory.GetEntityAddress(_Id))[37]:GetInt()
		local task = taskhandler[taskindex]

		if task then

			if task.NextTick then
				NextTick(task.Func, _Id, unpack(task.Params or {}))
			else
				task.Func(_Id, unpack(task.Params or {}))
			end

			return task.Return or result
		end
	end

	return result
end