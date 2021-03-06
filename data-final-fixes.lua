-- Read Debug Setting
GDIWdebugon = settings.startup["GDIW-debug"].value


GDIWworklistIn = {}
GDIWworklistOut = {}
GDIWworklistBoth = {}
GDIWproductivity = {}
GDIWresearch = {}
GDIWlist = {lout = {}, lin = {}, lboth = {}}

--function for sorting tables
function sortTableBySortorder(a,b)
  if a == nil or b == nil then
    return false
  end
  return a.sortorder<b.sortorder 
end


-- function for doing prototypes
function GDIWdoprototype(GDIWwl, isIn, isOut )
  for _, vin in pairs(GDIWwl) do
    -- Determine new names, suffixes
    if isIn and isOut then
    suffix = "GDIW-BR"
    ordersuffix = "-o3"
    elseif isIn then
    suffix = "GDIW-IR"
    ordersuffix = "-o2"
    elseif isOut then
    suffix = "GDIW-OR"
    ordersuffix = "-o1"
    else
    suffix = "GDIW-AR"
    ordersuffix = "-o4"
    end
    newName = vin.r .. "-" .. suffix
    
    if GDIWdebugon then log("[GDIW] Creating "..newName) end
    -- copy table
    data.raw.recipe[newName] = util.table.deepcopy(data.raw.recipe[vin.r])
    
    --Logging Code (Dev Only)
    --log("-## Creating "..newName)
    
    vro = data.raw.recipe[vin.r]
    vrn = data.raw.recipe[newName]
    -- fix names (and make enabled for testing)  
    vrn.name = newName
    --vrn.enabled = true
    -- Resort by Normal, Output, Input, Both
    if vro.order then
      vrn.order = vro.order .. ordersuffix
      else
      vrn.order = newName .. ordersuffix
    end
    
    -- Result Count (for naming)
    rc = 0
    if vrn.results then
      for _, rcv in pairs(vrn.results) do
        rc = rc + 1
      end
    end
    
    -- Hide if Startup Setting Set
    if settings.startup["GDIW-hide-recipes"].value == true then
      vrn.hidden = true
    end

    -- calculate localised name
    if vro.localised_name then
      vrn.localised_name = util.table.deepcopy(vro.localised_name)
    else
      vrn.localised_name = {"recipe-name." .. vro.name}
    end
    if vro.result then
      vrn.localised_name = {"item-name." .. vro.result}
    elseif vro.main_product then
      if data.raw.fluid[vro.main_product] then
        vrn.localised_name = {"fluid-name." .. vro.main_product}
      else
        vrn.localised_name = {"item-name." .. vro.main_product}
      end
    elseif vro.results then
      if vro.results[1] and vro.results[1].name then
        if vro.results[1].type then
          vrn.localised_name = {vro.results[1].type .. "-name." .. vro.results[1].name}
        else 
          vrn.localised_name = {gdiw_get_result_type(vro.results[1].name) .. "-name." .. vro.results[1].name}
        end
      else
        --log("--GDIW-----------")
        --log("failure on R:" .. vro.name .. " ")
        --log(serpent.block(vro.results))
        vrn.localised_name = {"recipe-name." .. vro.name}
      end
    end
    
    -- Name Overrides, because some things just dont like me.
    local nameoverrides = {
    "basic-oil-processing",
    "advanced-oil-processing",
    "light-oil-cracking",
    "heavy-oil-cracking",
    "coal-liquefaction",
    -- Krastorio Recipe overrides, because Krastorio also does not like us...
    "k-stone-processing",
    "k-air-separation",
    "pure-water-electrolysis",
    "raw-ores-processing",
    "raw-minerals-processing",
    "salt-water-electrolysis",
    }
    for _, nov in pairs(nameoverrides) do
      if vro.name == nov then
        vrn.localised_name = {"recipe-name." .. vro.name}
      end
    end

      
    
    ingbuild = {}
    newing = {}
    fluidflip = {}

    
    if isIn then
      
	
      if vrn.ingredients then
        sortcount = 0
          for _, vri in pairs(vrn.ingredients) do
            --Flip Input fluids
            sortcount = sortcount + 1
            vri.sortorder = sortcount
            if vri.type and vri.type == "fluid" then
              vri.sortorder = 1000 - sortcount
            end
          end
        end
    
      if vrn.normal and vrn.normal.ingredients then 
        sortcount = 0
        for _, vri in pairs(vrn.normal.ingredients) do
          --Flip Input fluids
          sortcount = sortcount + 1
          vri.sortorder = sortcount
          if vri.type and vri.type == "fluid" then
          vri.sortorder = 1000 - sortcount
          end
        end
      end
    
      if vrn.expensive and vrn.expensive.ingredients then 
        sortcount = 0
        for _, vri in pairs(vrn.expensive.ingredients) do
          --Flip Input fluids
          sortcount = sortcount + 1
          vri.sortorder = sortcount
          if vri.type and vri.type == "fluid" then
            vri.sortorder = 1000 - sortcount
          end
        end
      end
    
      if vrn.ingredients then
          table.sort(vrn.ingredients, sortTableBySortorder)
      end
        if vrn.normal and vrn.normal.ingredients then
        table.sort(vrn.normal.ingredients, sortTableBySortorder)
      end
      if vrn.expensive and vrn.expensive.ingredients then
        table.sort(vrn.expensive.ingredients, sortTableBySortorder)
      end
    
      if vrn.ingredients then
          for _, vri in pairs(vrn.ingredients) do
            --clear sortorder
            vri.sortorder = nil
          end
      end
      if vrn.normal and vrn.normal.ingredients then
        for _, vri in pairs(vrn.normal.ingredients) do
          --clear sortorder
          vri.sortorder = nil
        end
      end
      if vrn.expensive and vrn.expensive.ingredients then
        for _, vri in pairs(vrn.expensive.ingredients) do
          --clear sortorder
          vri.sortorder = nil
        end
      end
  
    end
    
    if isOut then
      

      if vrn.results then 
        sortcount = 0
        for _, vrr in pairs(vrn.results) do
		  --Flip Output fluids
          sortcount = sortcount + 1
          vrr.sortorder = sortcount
          if vrr.type and vrr.type == "fluid" then
            vrr.sortorder = 1000 - sortcount
          end
        end
      end
	
      if vrn.normal and vrn.normal.results then 
        sortcount = 0
        for _, vrr in pairs(vrn.normal.results) do
          --Flip Output fluids
          sortcount = sortcount + 1
          vrr.sortorder = sortcount
          if vrr.type and vrr.type == "fluid" then
          vrr.sortorder = 1000 - sortcount
          end
        end
      end
    
      if vrn.expensive and vrn.expensive.results then 
        sortcount = 0
        for _, vrr in pairs(vrn.expensive.results) do
          --Flip Output fluids
          sortcount = sortcount + 1
          vrr.sortorder = sortcount
          if vrr.type and vrr.type == "fluid" then
          vrr.sortorder = 1000 - sortcount
          end
        end
      end
    
      if vrn.results then -- check if there is any results
        table.sort(vrn.results, sortTableBySortorder)
        end
      if vrn.normal and vrn.normal.results then
        table.sort(vrn.normal.results, sortTableBySortorder)
      end
      if vrn.expensive and vrn.expensive.results then
        table.sort(vrn.expensive.results, sortTableBySortorder)
      end
    
      if vrn.results then -- check if there is any results
          for _, vrr in pairs(vrn.results) do
            --clear sortorder
            vrr.sortorder = nil
          end
        end
      
      if vrn.normal and vrn.normal.results then
        for _, vri in pairs(vrn.normal.results) do
          --clear sortorder
          vri.sortorder = nil
        end
      end
      if vrn.expensive and vrn.expensive.results then
        for _, vri in pairs(vrn.expensive.results) do
          --clear sortorder
          vri.sortorder = nil
        end
      end
    end
  
    newIcons = {}
    --grab old icon(s)
    if vro.icon then
      if vro.icon_size then
        vroIS = vro.icon_size
      else
        -- Assume 64 if its blank.
        vroIS  = 64
      end
      table.insert(newIcons,{icon=vro.icon,icon_size=vroIS})
    elseif vro.icons then
      newIcons = util.table.deepcopy(vro.icons)
    else
      -- Look through results for an icon
      local resultList = {}
      -- support for main_product
      if vrn.main_product then
        table.insert(resultList, {type=gdiw_get_result_type(vrn.main_product), name=vrn.main_product})
      end
      if vro.results then -- Do we have a list of results?
        for _,v in ipairs(vro.results) do 
          table.insert(resultList, v)
        end
      end
      if vro.normal and vro.normal.results then -- Do we have a list of normal results?
        for _,v in ipairs(vro.normal.results) do 
          table.insert(resultList, v)
        end
      end
      if vro.expensive and vro.expensive.results then -- Do we have a list of expensive results?
        for _,v in ipairs(vrn.expensive.results) do 
          table.insert(resultList, v)
        end
      end
      
      if vrn.result then -- Is there a single result string?
        table.insert(resultList, {type=gdiw_get_result_type(vrn.result), name=vrn.result})
      end
      if vrn.normal and vrn.normal.result then -- Is there a single normal result string?
        table.insert(resultList, {type=gdiw_get_result_type(vrn.normal.result), name=vrn.normal.result})
      end
      if vrn.expensive and vrn.expensive.result then -- Is there a single expensive result string?
        table.insert(resultList, {type=gdiw_get_result_type(vrn.expensive.result), name=vrn.expensive.result})
      end
      
      -- Now iterate over the list of results, until we either find an icon or checked all.
      for _, result in pairs(resultList) do
        if data.raw[result.type] and data.raw[result.type][result.name] then
          local rawResult = data.raw[result.type][result.name] 
          if rawResult.icon then
            if rawResult.icon_size then
              rawResIS = rawResult.icon_size
            else
              -- Assume 64 if its blank.
              rawResIS = 64
            end
            table.insert(newIcons,{icon=rawResult.icon, icon_size=rawResIS})
          elseif rawResult.icons then
            newIcons = util.table.deepcopy(rawResult.icons)
          end
          if #newIcons > 0 then break end
        end
      end
    end

      if #newIcons == 0 then
      table.insert(newIcons,{icon="__GDIW__/graphics/placeholder.png",icon_size = 32})
    end
    -- add overlay and use
    if isIn and isOut then
      table.insert(newIcons,{icon = "__GDIW__/graphics/reverse-overlay-both.png",icon_size = 32})
    elseif isIn then
      table.insert(newIcons,{icon = "__GDIW__/graphics/reverse-overlay-input.png",icon_size = 32})
    elseif isOut then
      table.insert(newIcons,{icon = "__GDIW__/graphics/reverse-overlay-output.png",icon_size = 32})
    else
      table.insert(newIcons,{icon = "__GDIW__/graphics/reverse-overlay-both.png",icon_size = 32})
    end
    
    vrn.icons = newIcons

    
    -- handle productivity modules
    if vin.prod then
      table.insert(GDIWproductivity,newName)
    end
  
    if not GDIWresearch[vin.r] then
      GDIWresearch[vin.r] = {}
    end
  
  table.insert(GDIWresearch[vin.r], newName)



    if isIn and isOut then
      table.insert(GDIWlist.lboth, {name=newName, orig=vin.r})
      elseif isIn then
      table.insert(GDIWlist.lin, {name=newName, orig=vin.r})
      elseif isOut then
      table.insert(GDIWlist.lout, {name=newName, orig=vin.r})
    end

  
  end

end --end function

function gdiw_get_result_type(itemName)
        -- Check the raw tables for an object of the given name and return the type
        if data.raw.item[itemName] then -- Are you an Item?
          return "item"
        elseif data.raw["ammo"][itemName] then -- Are you an Ammo?
          return "ammo"
        elseif data.raw["fluid"][itemName] then -- Are you a Fluid?
          return "fluid"
        elseif data.raw["gun"][itemName] then -- Are you a Gun?
          return "gun"
        elseif data.raw["tool"][itemName] then -- Are you a tool?
          return "tool"
        elseif data.raw["capsule"][itemName] then -- Are you an capsule?
          return "capsule"
        elseif data.raw["armor"][itemName] then -- Are you an armor?
          return "armor"
        elseif data.raw["repair-tool"][itemName] then -- Are you a repair-tool?
          return "repair-tool"
        elseif data.raw["module"][itemName] then -- Are you a module?
          return "module"
        elseif data.raw["blueprint"][itemName] then -- Are you an blueprint?
          return "blueprint"
        elseif data.raw["item-with-entity-data"][itemName] then -- Are you an item-with-entity-data?
          return "item-with-entity-data"
        elseif data.raw["artillery-flare"][itemName] then -- Are you an artillery-flare?
          return "artillery-flare"
        elseif data.raw["rail-planner"][itemName] then -- Are you an rail-planner?
          return "rail-planner"
        elseif data.raw["wall"][itemName] then -- Are you an wall?
          return "wall"
--        elseif data.raw[""][itemName] then -- Are you an ?
--          return ""
        else
          return "item"
        end
end



-- Find what needs to be done
GDIWfullcountIN = 0
GDIWfullcountOUT = 0
GDIWfullcountBOTH = 0
for kr, vr in pairs(data.raw.recipe) do
  --For each recipe
  GDIWfincountD = 0 --"Default, normal, expensive"
  GDIWfincountN = 0
  GDIWfincountE = 0
  GDIWfoutcountD = 0
  GDIWfoutcountN = 0
  GDIWfoutcountE = 0
  
  if vr.ingredients then
    for _, vri in pairs(vr.ingredients) do
      --Search for Inputs with Fluids
      if vri.type == "fluid" then
        GDIWfincountD = GDIWfincountD + 1
      end
    end
  end
  
  if vr.normal and vr.normal.ingredients then
    for _, vri in pairs(vr.normal.ingredients) do
      --Search for Inputs with Fluids
      if vri.type == "fluid" then
        GDIWfincountN = GDIWfincountN + 1
      end
    end
  end
  
  if vr.expensive and vr.expensive.ingredients then
    for _, vri in pairs(vr.expensive.ingredients) do
      --Search for Inputs with Fluids
      if vri.type == "fluid" then
        GDIWfincountE = GDIWfincountE + 1
      end
    end
  end
  
  if vr.results then
    for _, vri in pairs(vr.results) do
      --Search for Outputs with Fluids
      if vri.type == "fluid" then
        GDIWfoutcountD = GDIWfoutcountD + 1
      end
    end
  end
  
  if vr.normal and vr.normal.results then
    for _, vri in pairs(vr.normal.results) do
      --Search for Outputs with Fluids
      if vri.type == "fluid" then
        GDIWfoutcountN = GDIWfoutcountN + 1
      end
    end
  end
  
  if vr.expensive and vr.expensive.results then
    for _, vri in pairs(vr.expensive.results) do
      --Search for Outputs with Fluids
      if vri.type == "fluid" then
        GDIWfoutcountE = GDIWfoutcountE + 1
      end
    end
  end
  
  local GDIWfincount = math.max(GDIWfincountD, math.max(GDIWfincountN, GDIWfincountE))
  local GDIWfoutcount = math.max(GDIWfoutcountD, math.max(GDIWfoutcountN, GDIWfoutcountE))
  
  --and if they will be touched by this mod
  thisProduc = false
  if GDIWfincount > 1 or GDIWfoutcount > 1 then
    --determine if they have productivity support anywhere
    for _, vm in pairs(data.raw.module) do
      if vm.effect.productivity and vm.limitation then
        for _, prr in pairs(vm.limitation) do
          if prr == kr then thisProduc = true end--And mark them as having it
        end
      end
    end
  end
    
  
  --And generate a list
  if GDIWfincount > 1 then
    --of Input flipping
    table.insert(GDIWworklistIn,{r=kr, prod=thisProduc})
    GDIWfullcountIN = GDIWfullcountIN + 1
  end
  if GDIWfoutcount > 1 then
    --of Output flipping
    table.insert(GDIWworklistOut,{r=kr, prod=thisProduc})
    GDIWfullcountOUT = GDIWfullcountOUT + 1
  end
  if GDIWfincount > 1 and GDIWfoutcount > 1 then
    --of Input and Output flipping
    table.insert(GDIWworklistBoth,{r=kr, prod=thisProduc})
    GDIWfullcountBOTH = GDIWfullcountBOTH + 1
  end
  
end


if GDIWdebugon then 
  GDIWfullcountTOTAL = GDIWfullcountIN + GDIWfullcountOUT + GDIWfullcountBOTH
  log("[GDIW] Queued "..GDIWfullcountTOTAL.." recipes for GDIW processing") 
  log("[GDIW] (IN:"..GDIWfullcountIN.."  OUT:"..GDIWfullcountOUT.."  BOTH:"..GDIWfullcountBOTH..")") 
end

-- Add all prototypes via function
-- GDIWdoprototype(GDIWwl, isIn, isOut )
GDIWdoprototype(GDIWworklistIn, true, false )
GDIWdoprototype(GDIWworklistOut, false, true )
GDIWdoprototype(GDIWworklistBoth, true, true )


-- parse research, find unlocks and add new recipe
for _, rv in pairs(data.raw["technology"]) do
  if rv.effects then
    for _, rev in pairs(rv.effects) do
      if rev.type == "unlock-recipe" then
        for wlk, wlv in pairs(GDIWresearch) do
          if rev.recipe == wlk then
            for _, newrecipe in ipairs(wlv) do
              table.insert(rv.effects,{type = "unlock-recipe", recipe = newrecipe})
            end
          end
        end
      end
    end
  end
end


for km, vm in pairs(data.raw.module) do
  if vm.effect.productivity and vm.limitation then
    for _, recipe in ipairs(GDIWproductivity) do
      table.insert(vm.limitation, recipe)
    end
  end
end


-- Output list data to Control.lua (thanks data-raw-prototypes)
--log("GDIWlist Length: "..string.len(serpent.dump(GDIWlist)))
--log(serpent.dump(GDIWlist))
--data:extend({{
--	type = "flying-text",
--	name = "gdiw_data_list_flying-text",
--	time_to_live = 0,
--	speed = 1,
--	resource_category = serpent.dump(GDIWlist)
--}})
