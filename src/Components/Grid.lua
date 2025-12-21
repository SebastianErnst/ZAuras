local ZA = ZAuras
local Grid = {}
ZA.Components.Grid = Grid

function Grid:new()
    local public = {}
    local Log = ZA.Utils.Log

    function public:Create(parent, columns, gutterX, gutterY, rowHeight)
        local gridInstance = {
            parent = parent,
            rows = {},
            columns = columns or 1,
            gutterX = gutterX or 10,
            gutterY = gutterY or 10,
            rowHeight = rowHeight or 20,
            currentY = 0,
            columnWidths = {}
        }

        setmetatable(gridInstance, { __index = public })
        return gridInstance
    end

    -- Setze die Breiten mehrerer Spalten
    -- widths: Tabelle mit Index-Width Paaren, z.B. { [1] = 80, [2] = 200 }
    function public:SetColumnWidths(widths)
        if type(widths) ~= "table" then
            Log:error("Grid:SetColumnWidths() - Parameter muss eine Tabelle sein!")
            return
        end

        for index, width in pairs(widths) do
            if index < 1 or index > self.columns then
                Log:error("Grid:SetColumnWidths() - Ungültiger Spaltenindex " ..
                index .. " (max: " .. self.columns .. ")")
            else
                self.columnWidths[index] = width
            end
        end
    end

    -- -- Füge eine Reihe mit mehreren Elementen hinzu
    -- -- Verwendung:
    -- --   grid:AddRow(element1, element2, element3, ...)
    -- --   grid:AddRow({ element1, element2 }, keepWidth, height)
    function public:AddRow(...)
        local elements = arg
        local numElements = table.getn(arg)
        local keepWidth = false
        local rowHeight = nil

        -- Prüfe ob erstes Argument eine Tabelle ist (neue Syntax)
        if numElements >= 1 and type(elements[1]) == "table" and not elements[1].element and not elements[1].SetPoint then
            -- Neue Syntax: AddRow({ elem1, elem2 }, keepWidth, height)
            local elemTable = elements[1]
            keepWidth = elements[2] or false
            rowHeight = elements[3] -- Optionale explizite Höhe
            elements = elemTable
            numElements = table
                .getn(elemTable)
        end

        if numElements == 0 then
            Log:warn("Grid:AddRow() - Keine Elemente übergeben!")
            return
        end

        -- Bestimme Höhe der Reihe
        local maxHeight
        if rowHeight then
            -- Explizite Höhe wurde übergeben (hat Priorität)
            maxHeight = rowHeight
        elseif self.rowHeight then
            -- Verwende default Row-Height vom Grid
            maxHeight = self.rowHeight
        else
            -- Finde maximale Höhe in dieser Reihe
            maxHeight = 0
            for i = 1, numElements do
                local element = elements[i]
                local height = element.height or 30
                if height > maxHeight then
                    maxHeight = height
                end
            end
        end

        -- Speichere Reihe
        table.insert(self.rows, {
            elements = elements,
            height = maxHeight,
            y = self.currentY,
            numColumns = numElements
        })

        -- Berechne verfügbare Breite basierend auf tatsächlicher Spaltenanzahl dieser Reihe
        local parentWidth = self.parent:GetWidth()
        local totalGutterX = (numElements - 1) * self.gutterX
        local availableWidth = parentWidth - totalGutterX

        -- Berechne Breite für Spalten mit custom width
        local fixedWidth = 0
        local fixedColumns = 0
        for i = 1, numElements do
            if self.columnWidths[i] then
                fixedWidth = fixedWidth + self.columnWidths[i]
                fixedColumns = fixedColumns + 1
            end
        end

        -- Verbleibende Breite für flexible Spalten
        local flexibleWidth = availableWidth - fixedWidth
        local flexibleColumns = numElements - fixedColumns
        local flexColWidth = 0
        if flexibleColumns > 0 then
            flexColWidth = flexibleWidth / flexibleColumns
        end

        -- Positioniere Elemente in dieser Reihe
        local xOffset = 0
        for i = 1, numElements do
            local elem = elements[i]
            local element = elem.element or elem
            local elemKeepWidth = keepWidth or elem.keepWidth or false

            -- Bestimme Breite: custom width > columnWidth > flexible width
            local width
            if elem.width then
                width = elem.width
            elseif self.columnWidths[i] then
                width = self.columnWidths[i]
            else
                width = flexColWidth
            end

            -- Setze Breite nur wenn keepWidth nicht true ist
            if not elemKeepWidth then
                if element.isDropdown then
                    -- Dropdown: verwende UIDropDownMenu_SetWidth und SetButtonWidth direkt
                    UIDropDownMenu_SetWidth(width - 9, element)
                    UIDropDownMenu_SetAnchor(13, 13, element, "TOP", element, "BOTTOMLEFT")
                elseif element.SetWidth then
                    -- Normale Frames
                    element:SetWidth(width)
                end
            end

            -- Positionierung - Dropdowns brauchen angepassten Offset
            if i == 1 and table.getn(self.rows) == 1 then
                -- Erstes Element in erster Reihe
                if element.isDropdown then
                    element:SetPoint("TOPLEFT", self.parent, "TOPLEFT", -15, 0)
                else
                    element:SetPoint("TOPLEFT", self.parent, "TOPLEFT", 0, 0)
                end
            elseif i == 1 then
                -- Erstes Element in einer neuen Reihe
                local prevRow = self.rows[table.getn(self.rows) - 1]
                local prevElement = prevRow.elements[1].element or prevRow.elements[1]
                if element.isDropdown then
                    element:SetPoint("TOPLEFT", prevElement, "BOTTOMLEFT", -23, -self.gutterY)
                else
                    element:SetPoint("TOPLEFT", prevElement, "BOTTOMLEFT", 0, -self.gutterY)
                end
            else
                -- Weitere Elemente in der gleichen Reihe
                local prevElement = elements[i - 1].element or elements[i - 1]
                if element.isDropdown then
                    element:SetPoint("LEFT", prevElement, "RIGHT", self.gutterX - 23, 0)
                else
                    element:SetPoint("LEFT", prevElement, "RIGHT", self.gutterX, 0)
                end
            end

            xOffset = xOffset + width + self.gutterX
        end

        -- Update Y-Position für nächste Reihe
        self.currentY = self.currentY - maxHeight - self.gutterY
    end

    -- Berechne die benötigte Gesamthöhe
    function public:GetTotalHeight()
        if table.getn(self.rows) == 0 then
            return 0
        end

        local totalHeight = 0
        for i = 1, table.getn(self.rows) do
            totalHeight = totalHeight + self.rows[i].height
            if i < table.getn(self.rows) then
                totalHeight = totalHeight + self.gutterY
            end
        end

        return totalHeight
    end

    return public
end
