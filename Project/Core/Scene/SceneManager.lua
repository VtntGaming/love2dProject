local SceneManger = {}

--//Const
local SCENES_LOCATION = "Scenes"

--//
local SceneList = {}

function SceneManger.Init()
    print("SceneManger is init")
    for _, dirName in ipairs(love.filesystem.getDirectoryItems(SCENES_LOCATION)) do
        local sceneLocation = SCENES_LOCATION.."/"..dirName
        local requirementScriptPath = sceneLocation.."/SceneInit"
        local itemInfo = love.filesystem.getInfo(sceneLocation)
        local requirementScriptInfo = love.filesystem.getInfo(requirementScriptPath..".lua")
        if itemInfo and requirementScriptInfo and itemInfo.type == "directory" and requirementScriptInfo.type == "file" then
            require(requirementScriptPath)
        end
    end
end

return SceneManger