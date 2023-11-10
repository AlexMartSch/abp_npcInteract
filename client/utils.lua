ShowFloatingHelpNotification = function(msg, coords)
    AddTextEntry('nexFloatingHelpNotification', msg)
    SetFloatingHelpTextWorldPosition(1, coords)
    SetFloatingHelpTextStyle(1, 1, 2, -1, 3, 0)
    BeginTextCommandDisplayHelp('nexFloatingHelpNotification')
    EndTextCommandDisplayHelp(2, false, false, -1)
end


ShowHelpNotification = function(msg, thisFrame, beep, duration)
    AddTextEntry('nexHelpNotification', msg)

    if thisFrame then
        DisplayHelpTextThisFrame('nexHelpNotification', false)
    else
        if beep == nil then beep = true end
        BeginTextCommandDisplayHelp('nexHelpNotification')
        EndTextCommandDisplayHelp(0, false, beep, duration or -1)
    end
end

TableContains = function(t, e)
	for _, val in pairs(t) do
		if val == e then
			return true
		end
	end

	return false
end