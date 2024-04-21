ArrestNPC = ArrestNPC or {}
local function AddFile(File, directory)
    local prefix = string.lower(string.Left(File, 3))
    if SERVER and prefix == "sv_" then include(directory .. File) end
    if prefix == "sh_" then
        if SERVER then AddCSLuaFile(directory .. File) end
        include(directory .. File)
    end

    if prefix == "cl_" then
        if SERVER then
            AddCSLuaFile(directory .. File)
        else
            include(directory .. File)
        end
    end
end

local function IncludeDir(directory)
    directory = directory .. "/"
    local files, directories = file.Find(directory .. "*", "LUA")
    for _, v in ipairs(files) do
        if string.EndsWith(v, ".lua") then AddFile(v, directory) end
    end

    for _, v in ipairs(directories) do
        IncludeDir(directory .. v)
    end
end

IncludeDir("arrestsystem")