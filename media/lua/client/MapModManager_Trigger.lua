local function MapModManager_Trigger()
    print("[MAP-MOD-MANAGER] Triggering Java renamer...")
    -- Call the Java method to rename the file
    MapModManager_Renamer.renameMapModFile()
end

-- Trigger the renaming process when the game starts
Events.OnGameStart.Add(MapModManager_Trigger)
