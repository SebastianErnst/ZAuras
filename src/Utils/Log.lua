local ZA = ZAuras
local Log = {}
ZA.Utils.Log = Log

function Log:new()
    local public = {}
    
    public.LEVELS = {
        DEBUG = 1,
        INFO = 2,
        WARN = 3,
        ERROR = 4
    }

    local verboseEnabled = false
    local currentLevel = public.LEVELS.INFO

    function public:SetLevel(level)
        currentLevel = level
    end

    function public:SetDevMode()
        currentLevel = public.LEVELS.DEBUG
        verboseEnabled = true
    end

    function public:SetProdMode()
        currentLevel = public.LEVELS.WARN
        verboseEnabled = false
    end

    local function FormatMessage(level, message)
        return string.format("|cff00ff00[%s]|r %s: %s", ZA.ADDON_NAME, level, tostring(message))
    end

    function public:debug(message)
        if currentLevel <= public.LEVELS.DEBUG then
            print(FormatMessage("DEBUG", message))
        end
    end

    function public:info(message)
        if currentLevel <= public.LEVELS.INFO then
            print(FormatMessage("INFO", message))
        end
    end

    function public:warn(message)
        if currentLevel <= public.LEVELS.WARN then
            print(FormatMessage("|cffffaa00WARN|r", message))
        end
    end

    function public:error(message)
        if currentLevel <= public.LEVELS.ERROR then
            print(FormatMessage("|cffff0000ERROR|r", message))
        end
    end

    function public:EnableVerbose()
        verboseEnabled = true
    end

    function public:DisableVerbose()
        verboseEnabled = false
    end

    function public:verbose(message)
        if verboseEnabled then
            print(FormatMessage("|cff888888VERBOSE|r", message))
        end
    end
    
    return public
end