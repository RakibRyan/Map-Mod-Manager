--      ██╗██╗██╗███████╗███████╗██╗███████╗ █  ███████╗    ███╗   ███╗ ██████╗ ██████╗ ███████╗ --
--      ██║██║██║╚══███╔╝╚══███╔╝██║██╔════╝    ██╔════╝    ████╗ ████║██╔═══██╗██╔══██╗██╔════╝ --
--      ██║██║██║  ███╔╝   ███╔╝ ██║█████╗      ███████╗    ██╔████╔██║██║   ██║██║  ██║███████╗ --
-- ██   ██║██║██║ ███╔╝   ███╔╝  ██║██╔══╝      ╚════██║    ██║╚██╔╝██║██║   ██║██║  ██║╚════██║ --
-- ╚█████╔╝██║██║███████╗███████╗██║███████╗    ███████║    ██║ ╚═╝ ██║╚██████╔╝██████╔╝███████║ --
--  ╚════╝ ╚═╝╚═╝╚══════╝╚══════╝╚═╝╚══════╝    ╚══════╝    ╚═╝     ╚═╝ ╚═════╝ ╚═════╝ ╚══════╝ --

-- Permissions                                                                                   --
-- Redistribution of this mod without explicit permission from the creator, jiizzjacuzzii, is    --
-- prohibited under any circumstances. This includes, but is not limited to, uploading this mod  --
-- to the Steam Workshop or any other site, distrubtion as part of another mod or modpack, or    --
-- distribution of modified versions.                                       © 2024 jiizzjacuzzii --

-- Main Menu --
    local function AddMapModsButtonToBottomPanel()
        if MainScreen.instance.bottomPanel then
            local currentHeight = MainScreen.instance.bottomPanel:getHeight()
            MainScreen.instance.bottomPanel:setHeight(currentHeight + 100)
        end

        local buttonY = MainScreen.instance.bottomPanel:getHeight() - 80

        local button = ISButton:new(-4, buttonY, 182, 42, "MAP MOD MANAGER", nil, function()
            local ui = MapModChecker_UI:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
            ui:initialise()
            ui:addToUIManager()
        end)

        button:initialise()
        button:instantiate()
        button:setFont(UIFont.Large)
        button.borderColor = { r = 0, g = 0, b = 0, a = 0 }
        button.backgroundColor = { r = 0, g = 0, b = 0, a = 0 }
        button.backgroundColorMouseOver = { r = 0.6, g = 0.6, b = 0.6, a = 0.2 }

        function button:render()
            local originalTitle = self.title
            self.title = ""
        
            ISButton.render(self)
        
            self.title = originalTitle
        
            local textX = 2
            local textY = (tonumber(self.height) or 40 - (tonumber(self.fontHgt) or 20)) / 2 - 15 + 2
            self:drawText(self.title, textX, textY, 1, 1, 1, 1, self.font)
        end

        MainScreen.instance.bottomPanel:addChild(button)
    end

    Events.OnMainMenuEnter.Add(AddMapModsButtonToBottomPanel)
    Events.OnMainMenuEnter.Add(printActiveMods)

-- Mod List Update --
    function refreshActiveMods()
        local activeMods = getActivatedMods()
        local activeModsTable = {}

        for i = 0, activeMods:size() - 1 do
            local modID = tostring(activeMods:get(i)):gsub("%s+", "")
            activeModsTable[modID] = true
        end

        return activeModsTable
    end

    local tempModList = {}

    function populateTempModList()
        local activeMods = getActivatedMods()

        for i = 0, activeMods:size() - 1 do
            local modID = tostring(activeMods:get(i))
            tempModList[modID] = true
        end
    end

-- UI Initalize--
    MapModChecker_UI = ISPanel:derive("MapModChecker_UI")
    function MapModChecker_UI:initialise()
        ISPanel.initialise(self)
        self.selectedMaps = {}
        self.panelsVisible = true
        self:createChildren()
        populateTempModList()
        self:updateDependencies()
    end

    function MapModChecker_UI:refreshActiveModsTable()
        self.activeModsTable = refreshActiveMods()
    end

    function MapModChecker_UI:onOpen()
        self:refreshActiveModsTable()
        populateTempModList()
        self:updateDependencies()
        self:setVisible(true)
        self:addToUIManager()
    end

-- Render UI --
    function MapModChecker_UI:render()
        self:renderOverlay()
        self:renderTooltip()
        if self.panelsVisible then
            self:renderAllMapModsPanel()
            self:renderActiveMapModsPanel()
            self:renderDependenciesPanel()
        end
    end

-- Search Bar --
    function MapModChecker_UI:filterMapList(filterText)
        if filterText == "" then
            self.scrollListBox:clear()
            for _, mapName in ipairs(self.originalMapList) do
                self.scrollListBox:addItem(mapName, nil)
            end
            return
        end
        self.scrollListBox:clear()
        for _, mapName in ipairs(self.originalMapList) do
            if string.find(string.lower(mapName), string.lower(filterText)) then
                self.scrollListBox:addItem(mapName, nil)
            end
        end
    end

function MapModChecker_UI:createChildren()
    -- Background
        self.background = ISPanel:new(0, 0, self.width, self.height)
        self.background:initialise()
        self.background.backgroundColor = {r=0, g=0, b=0, a=0.5}
        self:addChild(self.background)

        local activeMods = getActivatedMods()
        local activeModsSet = {}
        for i = 0, activeMods:size() - 1 do
            local modID = tostring(activeMods:get(i)):lower():gsub("%s+", "")
            activeModsSet[modID] = true
        end     

    -- Scroll List 1 --
        local listWidth = 420
        local listX = getCore():getScreenWidth() - listWidth - 20
        local listY = 150
        local listHeight = getCore():getScreenHeight() - 140 - 45 - 30

    -- Scroll List 2 --
        local listWidth2 = listWidth
        local listX2 = listX - listWidth - 20
        local listHeight2 = (listHeight * 3 / 5) - 60
        local listY2 = listY

    -- Scroll List 3 --
        local listWidth3 = listWidth
        local listX3 = listX2
        local listY3 = listY2 + listHeight2 + 55
        local listHeight3 = listHeight * 2 / 5
    
    -- Clear Search Bar Button --
        self.searchButton = ISButton:new(listX + (listWidth - 100), listY - 50, 100, 35, "Clear", self, function()
            self.searchBar:setText("")
            self:filterMapList("")
        end)      
        self.searchButton:initialise()
        self.searchButton:instantiate()
        self:addChild(self.searchButton)

    -- Search Bar --
        self.searchBar = ISTextEntryBox:new("", listX, listY - 50, 315, 35)
        self.searchBar:initialise()
        self.searchBar:instantiate()
        self.searchBar.onTextChange = function(entry)
            self:filterMapList(entry:getText())
        end
        self:addChild(self.searchBar)

    -- Close Button --
        function MapModChecker_UI:onDiscard()
            tempModList = {}
            self:removeFromUIManager()
        end
    
        self.closeButton = ISButton:new(listX + listWidth - 30, 10, 30, 30, "X", self, self.onClose)        self.closeButton:initialise()
        self.closeButton:instantiate()
        self.closeButton.tooltip = "Save changes made to mods and go back to the main menu."
        self:addChild(self.closeButton)    

        local totalButtonAreaWidth = listWidth
        local numberOfButtons = 3
        local buttonSpacing = 10
        local buttonWidth = (totalButtonAreaWidth - ((numberOfButtons - 1) * buttonSpacing)) / numberOfButtons

    -- Discard Changes Button
        local buttonSpacing = 5
        local discardButtonX = self.closeButton:getX() - 70 - buttonSpacing - 30
        
        self.discardButton = ISButton:new(discardButtonX, 10, 70, 30, "Discard Changes", self, MapModChecker_UI.onDiscard)
        self.discardButton:initialise()
        self.discardButton:instantiate()
        self.discardButton:setFont(UIFont.Small)
        self.discardButton.tooltip = "Discard changes made to mods and go back to the main menu."
        self:addChild(self.discardButton)

    -- Increase Grid Button
        local increaseGridButtonX = discardButtonX - 70 - buttonSpacing - 25

        self.increaseGridButton = ISButton:new(increaseGridButtonX, 10, 90, 30, "Increase Grid", self, function()
            if self.isGridExpanded then
                self.overlayBackground:setVisible(false)
                self.increaseGridButton:setTitle("Increase Grid")
                self.isGridExpanded = false
                self.panelsVisible = true
            else
                self:IncreaseGrid()
                self.increaseGridButton:setTitle("Decrease Grid")
                self.isGridExpanded = true
            end
        end)
        self.increaseGridButton:initialise()
        self.increaseGridButton:instantiate()
        self.increaseGridButton:setFont(UIFont.Small)
        self.increaseGridButton.tooltip = "Increase the size of the grid by hiding the scroll lists."
        self:addChild(self.increaseGridButton)

        function MapModChecker_UI:IncreaseGrid()
            if not self.overlayBackground then
                self.overlayBackground = ISPanel:new(0, 0, getCore():getScreenWidth(), getCore():getScreenHeight())
                self.overlayBackground:initialise()
                self.overlayBackground.backgroundColor = {r=0, g=0, b=0, a=1}
                self:addChild(self.overlayBackground)
            end
            self.overlayBackground:setVisible(true)
            self.panelsVisible = false

            self:addChild(self.increaseGridButton)
            self:addChild(self.discardButton)
            self:addChild(self.closeButton)
        end


    -- Select All Subscribed Button --
        local selectsubscribedButtonX = listX2
        local selectsubscribedButtonY = listY - 50
        self.selectsubscribedButton = ISButton:new(selectsubscribedButtonX, selectsubscribedButtonY, buttonWidth, 35, "Select All Subscribed", self, function()
            if self.selectsubscribedButton.title == "Select All Subscribed" then
                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    self.selectedMaps[item.text] = true
                end
                self:updateDependencies()
                self.selectsubscribedButton:setTitle("Unselect All Subscribed")
            else
                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    self.selectedMaps[item.text] = nil
                end
                self:updateDependencies()
                self.selectsubscribedButton:setTitle("Select All Subscribed")
            end
        end)
        self.selectsubscribedButton:initialise()
        self.selectsubscribedButton:instantiate()
        self.selectsubscribedButton.tooltip = "Select/deselect all subscribed map mods to show their locations on the cell grid."
        self:addChild(self.selectsubscribedButton)

    -- Select All Active Mods Button --
        local selectactiveButtonX = selectsubscribedButtonX + buttonWidth + buttonSpacing
        local selectactiveButtonY = selectsubscribedButtonY
        self.selectactiveButton = ISButton:new(selectactiveButtonX, selectactiveButtonY, buttonWidth, 35, "Select All Active", self, function()
            if self.selectactiveButton.title == "Select All Active" then
                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    local mapName = item.text
                    local mapData = MapModChecker_DB[mapName]
                    -- Use tempModList to check if the mod is active
                    if mapData and tempModList[mapData.modID] then
                        self.selectedMaps[mapName] = true
                    end
                end
                self:updateDependencies()
                self.selectactiveButton:setTitle("Unselect All Active")
            else
                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    local mapName = item.text
                    local mapData = MapModChecker_DB[mapName]
                    -- Use tempModList to check if the mod is active
                    if mapData and tempModList[mapData.modID] then
                        self.selectedMaps[mapName] = nil
                    end
                end
                self:updateDependencies()
                self.selectactiveButton:setTitle("Select All Active")
            end
        end)
        self.selectactiveButton:initialise()
        self.selectactiveButton:instantiate()
        self.selectactiveButton.tooltip = "Select/deselect all active map mods to show their locations on the cell grid."
        self:addChild(self.selectactiveButton)

    -- Export Button --
        local exportButtonX = selectactiveButtonX + buttonWidth + buttonSpacing
        local exportButtonY = selectsubscribedButtonY
        self.exportButton = ISButton:new(exportButtonX, exportButtonY, buttonWidth, 35, "Export Selected Maps", self, function()
            self:exportHello()
        end)    
        self.exportButton:initialise()
        self.exportButton:instantiate()
        self.exportButton.tooltip = "Export selected maps (from both subscribed and all map mods), file is located in: C:\\Users\\User\\Zomboid\\Lua\\path"
        self:addChild(self.exportButton)

        -- Unselect All Maps Button --
        local unselectButtonY = listY + listHeight + 10
        self.unselectButton = ISButton:new(listX, unselectButtonY, listWidth / 2 - 5, 35, "Unselect All Maps", self, function()
            self:unselectAllMaps()
        end)
        self.unselectButton:initialise()
        self.unselectButton:instantiate()
        self:addChild(self.unselectButton)

    -- Select Vanilla Maps Button --
        local selectvanillaButtonX = listX + listWidth / 2 + 5
        self.selectvanillaButton = ISButton:new(selectvanillaButtonX, unselectButtonY, listWidth / 2 - 5, 35, "Select Vanilla Maps", self, function()
            self:selectVanillaMaps()
        end)
        self.selectvanillaButton:initialise()
        self.selectvanillaButton:instantiate()
        self:addChild(self.selectvanillaButton)
        
    -- Toggle Mods Buttons -- 
        local toggleButtonY = listY2 + listHeight2 + 10
        local toggleButtonWidth = listWidth / 2 - 5

        -- Toggle All Subscribed Maps Button
            local toggleSubscribedButtonX = listX2
            
            self.toggleSubscribedButton = ISButton:new(toggleSubscribedButtonX, toggleButtonY, toggleButtonWidth, 35, "Toggle All Subscribed Maps", self, function()
                local allOn = true
        
                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    local mapName = item.text
                    local mapData = MapModChecker_DB[mapName]
                    local modID = mapData and mapData.modID
                    if modID and not tempModList[modID] then
                        allOn = false
                        break
                    end
                end
            
                if allOn then
                    for i = 1, #self.scrollListBox2.items do
                        local item = self.scrollListBox2.items[i]
                        local mapName = item.text
                        local mapData = MapModChecker_DB[mapName]
                        local modID = mapData and mapData.modID
                        if modID then
                            tempModList[modID] = false
                        end
                    end
                    self.toggleSubscribedButton:setTitle("Toggle All Subscribed Maps On")
                else

                    for i = 1, #self.scrollListBox2.items do
                        local item = self.scrollListBox2.items[i]
                        local mapName = item.text
                        local mapData = MapModChecker_DB[mapName]
                        local modID = mapData and mapData.modID
                        if modID then
                            tempModList[modID] = true
                        end
                    end
                    self.toggleSubscribedButton:setTitle("Toggle All Subscribed Maps Off")
                end
                

                self:updateDependencies()
            end)

            self.toggleSubscribedButton:initialise()
            self.toggleSubscribedButton:instantiate()
            self.toggleSubscribedButton.tooltip = "Toggle the on/off status of all subscribed map mods."
            self:addChild(self.toggleSubscribedButton)

        -- Toggle All Selected and Subscribed Maps Button
            local toggleSelectedSubscribedButtonX = toggleSubscribedButtonX + toggleButtonWidth + 10
            self.toggleSelectedSubscribedButton = ISButton:new(toggleSelectedSubscribedButtonX, toggleButtonY, toggleButtonWidth, 35, "Toggle All Selected Maps", self, function()
                local allSelectedOn = true

                for i = 1, #self.scrollListBox2.items do
                    local item = self.scrollListBox2.items[i]
                    local mapName = item.text
                    if self.selectedMaps[mapName] then
                        local mapData = MapModChecker_DB[mapName]
                        local modID = mapData and mapData.modID
                        if modID and not tempModList[modID] then
                            allSelectedOn = false
                            break
                        end
                    end
                end
            
                if allSelectedOn then
                    for i = 1, #self.scrollListBox2.items do
                        local item = self.scrollListBox2.items[i]
                        local mapName = item.text
                        if self.selectedMaps[mapName] then
                            local mapData = MapModChecker_DB[mapName]
                            local modID = mapData and mapData.modID
                            if modID then
                                tempModList[modID] = false
                            end
                        end
                    end
                    self.toggleSelectedSubscribedButton:setTitle("Toggle All Selected Maps On")
                else

                    for i = 1, #self.scrollListBox2.items do
                        local item = self.scrollListBox2.items[i]
                        local mapName = item.text
                        if self.selectedMaps[mapName] then
                            local mapData = MapModChecker_DB[mapName]
                            local modID = mapData and mapData.modID
                            if modID then
                                tempModList[modID] = true
                            end
                        end
                    end
                    self.toggleSelectedSubscribedButton:setTitle("Toggle All Selected Maps Off")
                end
            
                self:updateDependencies()
            end)

            self.toggleSelectedSubscribedButton:initialise()
            self.toggleSelectedSubscribedButton:instantiate()
            self.toggleSelectedSubscribedButton.tooltip = "Toggle the on/off status of all selected map mods that you are subscribed to. Maps selected from the All Map Mods list won't be toggled on, you need to subscribe to them first."
            self:addChild(self.toggleSelectedSubscribedButton)

-- Scroll Lists --
    -- Scroll List 1 --
        self.scrollListBox = ISScrollingListBox:new(listX, listY, listWidth, listHeight)
        self.scrollListBox:initialise()
        self.scrollListBox.itemheight = 40
        self.scrollListBox.selected = 0
        self.scrollListBox:setFont(UIFont.Medium)

        self.scrollListBox.doDrawItem = function(self, y, item, alt)
            y = y + 5
            local isSelected = self.parent.selectedMaps[item.text] ~= nil
            self:drawRect(0, y, self:getWidth(), self.itemheight + 12, 1, 0, 0, 0)
            if isSelected then
                self:drawRect(0, y - 3, self:getWidth(), self.itemheight + 11, 0.5, 0.7, 0.7, 0.7)
            end

            self:drawText(item.text, 10, y + 5, 1, 1, 1, 1, UIFont.Medium)

            -- Check if the item is not a "vanilla:" map before drawing the logo
            if not item.text:match("^Vanilla:") then
                local logoX = self:getWidth() - 40
                local logoY = y + 5
                self:drawTexture(getTexture("media/textures/steamlogo20x20.png"), logoX, logoY, 1, 1, 1, 1)
            
                -- Store logo coordinates for non-vanilla maps
                item.logoX = logoX
                item.logoY = logoY
                item.logoWidth = 20
                item.logoHeight = 20
            else
                -- Clear logo coordinates for vanilla maps
                item.logoX, item.logoY, item.logoWidth, item.logoHeight = nil, nil, nil, nil
            end

            return y + self.itemheight + 5
        end

        self.scrollListBox.onMouseDown = function(_, x, y)
            local index = self.scrollListBox:rowAt(x, y)
            if index >= 1 and index <= #self.scrollListBox.items then
                local selectedItem = self.scrollListBox.items[index]
                if selectedItem then
                    if x >= selectedItem.logoX and x <= selectedItem.logoX + selectedItem.logoWidth and
                    y >= selectedItem.logoY and y <= selectedItem.logoY + selectedItem.logoHeight then
        
                        local mapData = MapModChecker_DB[selectedItem.text]
                        if mapData and mapData.workshopID then
                            local steamURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. mapData.workshopID
                            openUrl(steamURL)
                        end
                        return
                    end
        
                    local mapName = selectedItem.text
                    if self.selectedMaps[mapName] then
                        self.selectedMaps[mapName] = nil
                    else
                        self.selectedMaps[mapName] = true
                    end
                    self.scrollListBox.selected = index
                    self:updateDependencies()
                end
            end
        end

        self:addChild(self.scrollListBox)

    -- Scroll List 2 --
        self.scrollListBox2 = ISScrollingListBox:new(listX2, listY2, listWidth, listHeight2)
        self.scrollListBox2:initialise()
        self.scrollListBox2.itemheight = 40
        self.scrollListBox2.selected = 0
        self.scrollListBox2:setFont(UIFont.Medium)

        self.scrollListBox2.doDrawItem = function(self, y, item, alt)
            y = y + 5
            local isSelected = self.parent.selectedMaps[item.text] ~= nil

            self:drawRect(0, y, self:getWidth(), self.itemheight + 12, 1, 0, 0, 0)
            if isSelected then
                self:drawRect(0, y - 3, self:getWidth(), self.itemheight + 11, 0.5, 0.7, 0.7, 0.7)
            end

            local textColor = {r=1, g=1, b=1, a=1}
            local mapData = MapModChecker_DB[item.text]
            local modID = mapData and mapData.modID
            
            -- Set text color based on tempModList
            if modID and tempModList[modID] == true then
                textColor = {r=102/255, g=204/255, b=76/255, a=1}  -- Green for active
            else
                textColor = {r=1, g=1, b=1, a=1}  -- White for inactive
            end

            self:drawText(item.text, 10, y + 5, textColor.r, textColor.g, textColor.b, textColor.a, UIFont.Medium)

            -- Determine button label based on tempModList
            local buttonLabel = "Off"
            if modID and tempModList[modID] == true then
                buttonLabel = "On"
            end

            -- Draw the "On/Off" button and store its exact position
            local buttonWidth = 50
            local buttonHeight = 20
            local buttonX = self:getWidth() - buttonWidth - 20
            local buttonY = y + ((self.itemheight - buttonHeight) / 2) + 3

            -- Store button coordinates within the item data
            item.buttonX, item.buttonY, item.buttonWidth, item.buttonHeight = buttonX, buttonY, buttonWidth, buttonHeight

            self:drawRect(buttonX, buttonY, buttonWidth, buttonHeight, 1, 0, 0, 0)
            self:drawRectBorder(buttonX, buttonY, buttonWidth, buttonHeight, 1, 1, 1, 1)
            self:drawTextCentre(buttonLabel, buttonX + buttonWidth / 2, buttonY + 3, 1, 1, 1, 1, UIFont.Small)

            return y + self.itemheight + 5
        end


        self.scrollListBox2.onMouseDown = function(_, x, y)
            local index = self.scrollListBox2:rowAt(x, y)
            if index >= 1 and index <= #self.scrollListBox2.items then
                local selectedItem = self.scrollListBox2.items[index]
                if selectedItem then
                    local mapName = selectedItem.text
                    local mapData = MapModChecker_DB[mapName]  -- Retrieve map data for the item

                    -- Retrieve stored button coordinates
                    local buttonX, buttonY, buttonWidth, buttonHeight = selectedItem.buttonX, selectedItem.buttonY, selectedItem.buttonWidth, selectedItem.buttonHeight

                    -- Check if the click is within the stored button boundaries
                    if x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
                        if mapData then
                            local modID = mapData.modID  -- Use the exact modID from MapModChecker_DB
                            
                            -- Use `tempModList` to determine current active status without transformations
                            if tempModList[modID] == true then
                                -- If mod is currently active, set it to inactive
                                tempModList[modID] = false
                            else
                                -- If mod is currently inactive or not in the list, set it to active
                                tempModList[modID] = true
                            end                    
                        else
                            print("Mod with ID", modID, "not found.")
                        end
                        self:updateDependencies()
                        return  -- Exit after processing the button click to prevent further actions
                    else
                        -- Toggle selection state if click is outside the button
                        if self.selectedMaps[mapName] then
                            self.selectedMaps[mapName] = nil
                        else
                            self.selectedMaps[mapName] = true
                        end
                        self.scrollListBox2.selected = index
                        self:updateDependencies()
                    end
                end
            end
        end

        self:addChild(self.scrollListBox2)

    -- Scroll List 3 --
        self.scrollListBox3 = ISScrollingListBox:new(listX3, listY3 + 50, listWidth, listHeight3)
        self.scrollListBox3:initialise()
        self.scrollListBox3.itemheight = 40
        self.scrollListBox3.selected = 0
        self.scrollListBox3:setFont(UIFont.Medium)

        self.scrollListBox3.doDrawItem = function(self, y, item, alt)
            y = y + 5
            local isSelected = self.parent.selectedMaps[item.text] ~= nil

            self:drawRect(0, y, self:getWidth(), self.itemheight + 12, 1, 0, 0, 0)

            -- Retrieve dependency data
            local dependencyData = Dependency_DB[item.text]
            local modID = dependencyData and dependencyData.modID
            local workshopID = dependencyData and dependencyData.workshopID

            -- Determine button label and default text color
            local buttonLabel = "Off"
            local textColor = {r=1, g=1, b=1, a=1}  -- White as default color for inactive

            if modID and tempModList[modID] then
                buttonLabel = "On"
                textColor = {r=102/255, g=204/255, b=76/255, a=1}  -- Green for active
            elseif workshopID and not self.subscribedModsSet[workshopID] then
                textColor = {r=1, g=0, b=0, a=1}  -- Red for not subscribed
            end

            -- Draw item text with determined color
            self:drawText(item.text, 10, y + 5, textColor.r, textColor.g, textColor.b, textColor.a, UIFont.Medium)

            -- Draw Steam logo to the left of the button
            local buttonWidth = 50
            local buttonHeight = 20
            local buttonX = self:getWidth() - buttonWidth - 20
            local buttonY = y + ((self.itemheight - buttonHeight) / 2) + 3
            local logoX = buttonX - 30  -- Position the logo to the left of the button
            local logoY = y + 5

            -- Draw Steam logo
            self:drawTexture(getTexture("media/textures/steamlogo20x20.png"), logoX, logoY, 1, 1, 1, 1)

            -- Store logo and button coordinates within the item data for use in onMouseDown
            item.logoX, item.logoY, item.logoWidth, item.logoHeight = logoX, logoY, 20, 20
            item.buttonX, item.buttonY, item.buttonWidth, item.buttonHeight = buttonX, buttonY, buttonWidth, buttonHeight

            -- Draw the "On/Off" button with the correct label
            self:drawRect(buttonX, buttonY, buttonWidth, buttonHeight, 1, 0, 0, 0)
            self:drawRectBorder(buttonX, buttonY, buttonWidth, buttonHeight, 1, 1, 1, 1)
            self:drawTextCentre(buttonLabel, buttonX + buttonWidth / 2, buttonY + 3, 1, 1, 1, 1, UIFont.Small)

            return y + self.itemheight + 5
        end

        self:addChild(self.scrollListBox3)

        self.scrollListBox3.onMouseDown = function(_, x, y)
            local index = self.scrollListBox3:rowAt(x, y)
            if index >= 1 and index <= #self.scrollListBox3.items then
                local selectedItem = self.scrollListBox3.items[index]
                if selectedItem then
                    local dependencyName = selectedItem.text
                    local dependencyData = Dependency_DB[dependencyName]
                    local modID = dependencyData and dependencyData.modID
                    local workshopID = dependencyData and dependencyData.workshopID
        
                    -- Check if this dependency is subscribed (i.e., not red)
                    local isSubscribed = workshopID and self.scrollListBox3.subscribedModsSet[workshopID]
                    
                    -- Retrieve stored button coordinates
                    local buttonX, buttonY, buttonWidth, buttonHeight = selectedItem.buttonX, selectedItem.buttonY, selectedItem.buttonWidth, selectedItem.buttonHeight
        
                    -- Check if the click is within the button boundaries
                    if modID and x >= buttonX and x <= buttonX + buttonWidth and y >= buttonY and y <= buttonY + buttonHeight then
                        -- Allow toggling only if the dependency is subscribed
                        if isSubscribed then
                            -- Toggle the active status of the dependency in tempModList
                            tempModList[modID] = not tempModList[modID]
                            print("Toggled dependency:", dependencyName, "New status:", tempModList[modID] and "On" or "Off")
                            self:updateDependencies()
                        else
                            print("Cannot toggle dependency:", dependencyName, "because it is not subscribed")
                        end
                        return
                    end
        
                    -- Check if clicked on Steam logo and open the URL if clicked
                    local logoX, logoY, logoWidth, logoHeight = selectedItem.logoX, selectedItem.logoY, selectedItem.logoWidth, selectedItem.logoHeight
                    if x >= logoX and x <= logoX + logoWidth and y >= logoY and y <= logoY + logoHeight then
                        if dependencyData and dependencyData.workshopID then
                            local steamURL = "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. dependencyData.workshopID
                            openUrl(steamURL)
                        end
                        return
                    end
                end
            end
        end
                
    -- Scroll List 1 --
        self.scrollListBox:clear()
        self.originalMapList = {}
        local vanillaMaps = {}
        local otherMaps = {}
        for mapName, _ in pairs(MapModChecker_DB) do
            if mapName then
                if mapName:find("Vanilla:") then
                    table.insert(vanillaMaps, mapName)
                else
                    table.insert(otherMaps, mapName)
                end
            end
        end
        table.sort(vanillaMaps)
        table.sort(otherMaps)
        for _, mapName in ipairs(vanillaMaps) do
            table.insert(self.originalMapList, mapName)
            self.scrollListBox:addItem(mapName, nil)
            self.selectedMaps[mapName] = true
        end
        for _, mapName in ipairs(otherMaps) do
            table.insert(self.originalMapList, mapName)
            self.scrollListBox:addItem(mapName, nil)
        end


    -- Scroll List 2 --
        self.scrollListBox2:clear()
        local activeMods = getSteamWorkshopItemIDs()
        local mapNames = {}

        for i = 0, activeMods:size() - 1 do
            local modID = activeMods:get(i)
            for mapName, mapData in pairs(MapModChecker_DB) do
                if mapData.workshopID == modID then
                    table.insert(mapNames, mapName)
                end
            end
        end

        table.sort(mapNames)

        for _, mapName in ipairs(mapNames) do
            self.scrollListBox2:addItem(mapName, nil)
        end
        end

-- Grid
    -- Checks mouse hover --
        function MapModChecker_UI:isMouseOverCell(cellX, cellY, cellSize)
            local mouseX = getMouseX()
            local mouseY = getMouseY()
            return mouseX >= cellX and mouseX <= cellX + cellSize and mouseY >= cellY and mouseY <= cellY + cellSize
        end

    -- Grid Render --
        function MapModChecker_UI:renderOverlay()
            local screenWidth = getCore():getScreenWidth()
            local screenHeight = getCore():getScreenHeight()
            
            local gridRows = 64
            local gridCols = 64
            local availableHeight = screenHeight * 0.98
            local availableWidth
    
        -- Toggleable grid size
            if self.isGridExpanded then
                local aspectRatio = gridCols / gridRows
                availableWidth = availableHeight * aspectRatio
            else
                availableWidth = screenWidth - 900
            end
        
            local cellSize = math.min(availableWidth / gridCols, availableHeight / gridRows)
            local gridWidth = cellSize * gridCols
            local gridHeight = cellSize * gridRows
        
            local gridStartX = 10
            local gridStartY = (screenHeight - gridHeight) / 2
    
        -- Check overlapping cells --
            local cellTooltips = {}
    
        -- Grid Background --
            self:drawRect(gridStartX, gridStartY, gridWidth, gridHeight, 0.5, 0, 0, 0)
    
        -- Clear tooltip when not hovering --
            self.tooltip = nil
    
        -- Highlight cells --
            for mapName, mapData in pairs(MapModChecker_DB) do
                if self.selectedMaps[mapName] then
                    for _, cellData in ipairs(mapData.cells) do
                        local cellKey = cellData.row .. "_" .. cellData.col
                        if not cellTooltips[cellKey] then
                            cellTooltips[cellKey] = {color = {0.5, 0, 0.5}, tooltips = {}}  -- Purple for map mods with no conflicts
                        end
                        table.insert(cellTooltips[cellKey].tooltips, mapName)
        
                        -- Adjust color logic
                        if mapName:find("Ohio River") then
                            cellTooltips[cellKey].color = {0, 0, 1}  -- Blue for Ohio River
                        elseif mapName:find("Vanilla:") then
                            cellTooltips[cellKey].color = {0, 1, 0}  -- Green for Vanilla
                        else
                            -- Check for conflicts
                            if #cellTooltips[cellKey].tooltips > 1 then
                                local hasVanillaConflict = false
                                local nonVanillaCount = 0
        
                                for _, conflictingMapName in ipairs(cellTooltips[cellKey].tooltips) do
                                    if conflictingMapName:find("Vanilla:") then
                                        hasVanillaConflict = true
                                    else
                                        nonVanillaCount = nonVanillaCount + 1
                                    end
                                end
        
                                if hasVanillaConflict and nonVanillaCount > 1 then
                                    cellTooltips[cellKey].color = {1, 0, 0}  -- Red for conflicts involving Vanilla and multiple mods
                                elseif hasVanillaConflict then
                                    cellTooltips[cellKey].color = {1, 1, 0}  -- Yellow for conflicts with Vanilla
                                elseif nonVanillaCount > 1 then
                                    cellTooltips[cellKey].color = {1, 0, 0}  -- Red for conflicts between multiple non-Vanilla maps
                                end
                            end
                        end
                    end
                end
            end
    
        -- Grid overlay --
            for row = 0, gridRows - 1 do
                for col = 0, gridCols - 1 do
                    local cellX = gridStartX + (col * cellSize)
                    local cellY = gridStartY + (row * cellSize)
        
                    self:drawRectBorder(cellX, cellY, cellSize, cellSize, 0.5, 0.75, 0.75, 0.75)
                end
            end
    
        -- Highlights below grid overlay --
            for cellKey, cellInfo in pairs(cellTooltips) do
                local row, col = cellKey:match("(%d+)_(%d+)")
                if row and col then
                    row, col = tonumber(row), tonumber(col)
        
                    if row and col then
                        local cellX = gridStartX + ((row + 1) * cellSize)
                        local cellY = gridStartY + ((col + 1) * cellSize)
        
                        self:drawRect(cellX, cellY, cellSize, cellSize, 0.5, cellInfo.color[1], cellInfo.color[2], cellInfo.color[3])
        
                        -- Tooltip --
                        if self:isMouseOverCell(cellX, cellY, cellSize) then
                            local tooltipText = table.concat(cellInfo.tooltips, "\n")
                            local tooltipWidth = getTextManager():MeasureStringX(UIFont.Small, tooltipText) + 10
                            local tooltipHeight = (#cellInfo.tooltips * 20) + 10
        
                            self.tooltip = {x = cellX + cellSize + 5, y = cellY, width = tooltipWidth, height = tooltipHeight, text = tooltipText}
                        end
                    end
                end
            end
    
        -- Row / Column Labels --
            for row = 0, gridRows - 1 do
                for col = 0, gridCols - 1 do
                    if row == 0 or col == 0 then
                        local cellX = gridStartX + (col * cellSize)
                        local cellY = gridStartY + (row * cellSize)
        
                        self:drawRect(cellX, cellY, cellSize, cellSize, 0.6, 1, 1, 1)
        
                        local text = ""
                        if row == 0 and col > 0 then
                            text = tostring(col - 1)
                        elseif col == 0 and row > 0 then
                            text = tostring(row - 1)
                        end
        
                        if text ~= "" then
                            local xOffset = #text == 1 and (cellSize / 3) or (cellSize / 4.5)
                            local adjustedX = col == 0 and (cellX - 2) or cellX
                            local adjustedY = row == 0 and (cellY - 2) or (cellY - 1)
        
                            self:drawText(text, adjustedX + xOffset, adjustedY, 0, 0, 0, 1, UIFont.VerySmall)
                            end
                        end
                    end
                end
            end

    -- Tooltip --
        function MapModChecker_UI:renderTooltip()
            if self.tooltip then
                -- Trim any extra blank lines from the tooltip text
                local cleanText = self.tooltip.text:gsub("\n+", "\n"):gsub("^\n", ""):gsub("\n$", "")
        
                -- Recalculate tooltip height based on cleaned text
                local tooltipLines = {}
                for line in cleanText:gmatch("[^\n]+") do
                    table.insert(tooltipLines, line)
                end
                local tooltipHeight = (#tooltipLines * 20) + 10
        
                -- Draw tooltip box and text
                self:drawRect(self.tooltip.x, self.tooltip.y, self.tooltip.width, tooltipHeight, 1, 0, 0, 0)
                self:drawRectBorder(self.tooltip.x, self.tooltip.y, self.tooltip.width, tooltipHeight, 1, 1, 1, 1)
                local yOffset = 5
                for _, line in ipairs(tooltipLines) do
                    self:drawText(line, self.tooltip.x + 5, self.tooltip.y + yOffset, 1, 1, 1, 1, UIFont.Small)
                    yOffset = yOffset + 20
                end
            end
        end
        


-- Panels
    -- All Map Mods Panel --
        function MapModChecker_UI:renderAllMapModsPanel()
            local panelX = self.scrollListBox:getX()
            local panelY = self.scrollListBox:getY() - 90  
            local panelWidth = self.scrollListBox2:getWidth() - 300
            local panelHeight = 35

            self:drawRect(panelX, panelY, panelWidth, panelHeight, 0.5, 0, 0, 0)
            self:drawText("ALL MAP MODS", panelX + 10, panelY + 5, 1, 1, 1, 1, UIFont.Medium)
        end

    -- Subscribed Map Mods Panel --
        function MapModChecker_UI:renderActiveMapModsPanel()
            local panelX2 = self.scrollListBox2:getX()
            local panelY2 = self.scrollListBox2:getY() - 90   
            local panelWidth2 = self.scrollListBox2:getWidth()
            local panelHeight2 = 35

            self:drawRect(panelX2, panelY2, panelWidth2, panelHeight2, 0.5, 0, 0, 0)
            self:drawText("SUBSCRIBED MAP MODS", panelX2 + 10, panelY2 + 5, 1, 1, 1, 1, UIFont.Medium)
        end

    -- Dependencies Panel --
        function MapModChecker_UI:renderDependenciesPanel()
            local panelX3 = self.scrollListBox2:getX()
            local panelY3 = self.scrollListBox2:getY() + self.scrollListBox2:getHeight() + 60
            local panelWidth3 = self.scrollListBox2:getWidth()
            local panelHeight3 = 35

            self:drawRect(panelX3, panelY3, panelWidth3, panelHeight3, 0.5, 0, 0, 0)
            self:drawText("DEPENDENCIES", panelX3 + 10, panelY3 + 5, 1, 1, 1, 1, UIFont.Medium)
        end


-- On Close --
    function MapModChecker_UI:onClose()
        for modID, shouldBeActive in pairs(tempModList) do
            local mod = getModInfoByID(modID)
            if mod then
                toggleModActive(mod, shouldBeActive)
            else
                print("Mod with ID " .. modID .. " not found.")
            end
        end

        saveModsFile()

        getCore():ResetLua("default", "modsChanged")
        self:removeFromUIManager()
    end



-- Unselect All Maps Button --
    function MapModChecker_UI:unselectAllMaps()
        for mapName, _ in pairs(self.selectedMaps) do
            self.selectedMaps[mapName] = nil
        end
        self.scrollListBox:clear()
        for _, mapName in ipairs(self.originalMapList) do
            self.scrollListBox:addItem(mapName, nil)
        end
        self.scrollListBox2:clear()
        local activeMods = getSteamWorkshopItemIDs()
        local mapNames = {}

        for i = 0, activeMods:size() - 1 do
            local modID = activeMods:get(i)
            for mapName, mapData in pairs(MapModChecker_DB) do
                if mapData.workshopID == modID then
                    table.insert(mapNames, mapName)
                end
            end
        end

        table.sort(mapNames)

        for _, mapName in ipairs(mapNames) do
            self.scrollListBox2:addItem(mapName, nil)
        end
        self:updateDependencies()
    end

-- Select Vanilla Maps Button --
    function MapModChecker_UI:selectVanillaMaps()
        for _, item in ipairs(self.scrollListBox.items) do
            if item.text:find("Vanilla:") then
                self.selectedMaps[item.text] = true
            end
        end
        self.scrollListBox:clear()
        for _, mapName in ipairs(self.originalMapList) do
            self.scrollListBox:addItem(mapName, nil)
        end
        self:updateDependencies()
    end




-- Update Dependencies --
    function MapModChecker_UI:updateDependencies()
        self.scrollListBox3:clear()

        local subscribedModsSet = {}
        local subscribedMods = getSteamWorkshopItemIDs()
        for i = 0, subscribedMods:size() - 1 do
            local modID = subscribedMods:get(i)
            subscribedModsSet[modID] = true
        end

        self.scrollListBox3.subscribedModsSet = subscribedModsSet

        local dependenciesSet = {}

        for mapName, _ in pairs(self.selectedMaps) do
            local mapData = MapModChecker_DB[mapName]
            if mapData and mapData.dependencies then
                for _, dependency in ipairs(mapData.dependencies) do
                    local workshopID = dependency:match("id=(%d+)")
                    if workshopID then
                        for depName, depData in pairs(Dependency_DB) do
                            if depData.workshopID == workshopID then
                                dependenciesSet[depName] = true
                            end
                        end
                    end
                end
            end
        end


        for modID, isActive in pairs(tempModList) do
            if isActive then
                for mapName, mapData in pairs(MapModChecker_DB) do
                    if mapData.modID == modID and mapData.dependencies then
                        for _, dependency in ipairs(mapData.dependencies) do
                            local workshopID = dependency:match("id=(%d+)")
                            if workshopID then
                                for depName, depData in pairs(Dependency_DB) do
                                    if depData.workshopID == workshopID then
                                        dependenciesSet[depName] = true
                                    end
                                end
                            end
                        end
                    end
                end
            end
        end


        local sortedDependencies = {}
        for dependency, _ in pairs(dependenciesSet) do
            table.insert(sortedDependencies, dependency)
        end
        table.sort(sortedDependencies)


        for _, dependency in ipairs(sortedDependencies) do
            self.scrollListBox3:addItem(dependency, nil)
        end
    end


-- Export Selected Maps --
    function MapModChecker_UI:exportHello()
        file = getFileWriter("path/mapmodchecker.txt", true, false)
        
        -- Unique sets for workshop IDs, mod IDs, and map folders
        local workshopIDsSet = {}
        local modIDsSet = {}
        local mapFoldersSet = {}

        file:write("This was generated using the Map Mod Manager. Be mindful of load orders, you may need to rearrange maps that overlap each other.\n\n")
        file:write("Maps selected:\n")

        -- Write selected maps and collect workshop IDs, mod IDs, and map folders
        for mapName, _ in pairs(self.selectedMaps) do
            if not string.find(mapName, "Vanilla:") then
                local mapData = MapModChecker_DB[mapName]
                if mapData then
                    file:write(string.format("%s (%s)\n", mapName, mapData.url or "N/A"))
                    
                    -- Collect unique workshop IDs, mod IDs, and map folders for selected maps
                    if mapData.workshopID and mapData.workshopID ~= "N/A" then
                        workshopIDsSet[mapData.workshopID] = true
                    end
                    if mapData.modID and mapData.modID ~= "N/A" then
                        modIDsSet[mapData.modID] = true
                    end
                    if mapData.mapFolder and mapData.mapFolder ~= "N/A" then
                        mapFoldersSet[mapData.mapFolder] = true
                    end
                end
            end
        end    

        -- Write dependencies required with name and URL
        file:write("\nDependencies required:\n")
        local dependenciesSet = {}

        for mapName, _ in pairs(self.selectedMaps) do
            local mapData = MapModChecker_DB[mapName]
            if mapData and mapData.dependencies then
                for _, dependency in ipairs(mapData.dependencies) do
                    local workshopID = dependency:match("id=(%d+)")
                    if workshopID then
                        for depName, depData in pairs(Dependency_DB) do
                            if depData.workshopID == workshopID then
                                dependenciesSet[depName] = depData.url or "https://steamcommunity.com/sharedfiles/filedetails/?id=" .. workshopID
                                
                                -- Collect unique workshop IDs, mod IDs, and map folders for dependencies
                                if depData.workshopID and depData.workshopID ~= "N/A" then
                                    workshopIDsSet[depData.workshopID] = true
                                end
                                if depData.modID and depData.modID ~= "N/A" then
                                    modIDsSet[depData.modID] = true
                                end
                                if depData.MapFolder and depData.MapFolder ~= "N/A" then
                                    mapFoldersSet[depData.MapFolder] = true
                                end
                            end
                        end
                    end
                end
            end
        end

        -- Write each dependency with its name and URL only
        for depName, url in pairs(dependenciesSet) do
            file:write(string.format("%s (%s)\n", depName, url))
        end

        -- Convert sets to lists for concatenation
        local workshopIDs = {}
        for id, _ in pairs(workshopIDsSet) do
            table.insert(workshopIDs, id)
        end

        local modIDs = {}
        for id, _ in pairs(modIDsSet) do
            table.insert(modIDs, id)
        end

        local mapFolders = {}
        for folder, _ in pairs(mapFoldersSet) do
            table.insert(mapFolders, folder)
        end

        -- Write consolidated workshop IDs, mod IDs, and map folders to the file
        file:write("\nWorkshop ID: " .. table.concat(workshopIDs, ";") .. "\n")
        file:write("ModID: " .. table.concat(modIDs, ";") .. "\n")
        file:write("MapFolder: " .. table.concat(mapFolders, ";") .. ";Muldraugh, KY\n")
        
        file:close()
    end
