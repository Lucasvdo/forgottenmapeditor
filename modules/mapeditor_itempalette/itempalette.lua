ItemPalette = {}

local paletteWindow
local paletteList
local comboBox

UIPaletteCreature = extends(UICreature)
function UIPaletteCreature:onMousePress(mousePos, button)
  -- TODO: Could optimize this by outfit id?...
  _G["currentThing"] = self:getCreature():getName()
  ToolPalette.update()
end

UIPaletteItem = extends(UIItem)
function UIPaletteItem:onMousePress(mousePos, button)
  _G["currentThing"] = self:getItemId()
  ToolPalette.update()
end

local function onOptionChange(widget, optText, optData)
  paletteList:destroyChildren()

  if optData ~= ThingCategoryCreature then
    local items = g_things.findItemTypeByCategory(optData)
    for i = 1, #items do
      local widget = g_ui.createWidget('PaletteItem', paletteList)
      widget:setItemId(items[i]:getClientId())
    end
  else
    if not g_creatures.isLoaded() then
      return
    end

    local creatures = g_creatures.getCreatures()
    for i = 1, #creatures do
      local widget = g_ui.createWidget('PaletteCreature', paletteList)
      widget:setCreature(creatures[i]:cast())
    end
  end
end

local function deselectChild(child)
  paletteList:focusChild(nil)
  if child then
    child:setBorderWidth(0)
  end
end

local function onMousePress(self, mousePos, button)
  local previous = _G["currentWidget"]
  local next = self:getChildByPos(mousePos)

  if not next then
    deselectChild(previous)
    _G["currentWidget"] = nil
    _G["currentThing"] = nil
  elseif next ~= previous then
    deselectChild(previous)
    next:setBorderWidth(1)
    paletteList:focusChild(next)
    _G["currentWidget"] = next
  else
    deselectChild(previous)
  end

  ToolPalette.update()
end

function ItemPalette.init()
  paletteWindow = g_ui.loadUI('itempalette.otui', rootWidget:recursiveGetChildById('leftPanel'))
  paletteList   = paletteWindow:recursiveGetChildById('paletteList')
  comboBox     = paletteWindow:recursiveGetChildById('paletteComboBox')

  connect(paletteList, { onMousePress = onMousePress })
  comboBox.onOptionChange = onOptionChange

  _G["currentThing"] = 4526
  _G["secondThing"] = 106
  _G["currentWidget"] = nil
  
  ToolPalette.update()
  ItemPalette.initData()
end

function ItemPalette.initData()
  paletteList:destroyChildren()
  comboBox:clearOptions()

  comboBox:addOption("Grounds",      ItemCategoryGround)
  comboBox:addOption("Containers",   ItemCategoryContainer)
  comboBox:addOption("Weapons",      ItemCategoryWeapon)
  comboBox:addOption("Ammunition",   ItemCategoryAmmunition)
  comboBox:addOption("Armor",        ItemCategoryArmor)
  comboBox:addOption("Charges",      ItemCategoryCharges)
  comboBox:addOption("Teleports",    ItemCategoryTeleport)
  comboBox:addOption("MagicFields",  ItemCategoryMagicField)
  comboBox:addOption("Writables",    ItemCategoryWritable)
  comboBox:addOption("Keys",         ItemCategoryKey)
  comboBox:addOption("Splashs",      ItemCategorySplash)
  comboBox:addOption("Fluids",       ItemCategoryFluid)
  comboBox:addOption("Doors",        ItemCategoryDoor)
  comboBox:addOption("Creatures",    ThingCategoryCreature)

  comboBox:setCurrentIndex(1)
end

function ItemPalette.terminate()
  comboBox.onOptionChange = nil
  disconnect(paletteList, { onMousePress = onMousePress })

  paletteWindow:destroy()
  paletteWindow = nil
end
