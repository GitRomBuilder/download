
---------------------------------------- System initialization ----------------------------------------

-- Obtaining boot filesystem component proxy
local bootFilesystemProxy = component.proxy(component.proxy(component.list("eeprom")()).getData())

-- Executes file from boot HDD during OS initialization (will be overriden in filesystem library later)
function dofile(path)
	local stream, reason = bootFilesystemProxy.open(path, "r")
	if stream then
		local data, chunk = ""
		while true do
			chunk = bootFilesystemProxy.read(stream, math.huge)
			if chunk then
				data = data .. chunk
			else
				break
			end
		end

		bootFilesystemProxy.close(stream)

		local result, reason = load(data, "=" .. path)
		if result then
			return result()
		else
			error(reason)
		end
	else
		error(reason)
	end
end

-- Initializing global package system
package = {
	paths = {
		["/Libraries/"] = true
	},
	loaded = {},
	loading = {}
}
LibFixPackage = {
	paths = {
		["/Applications/ApplicationData/LibFix/OfflineLibraries/"] = true
	},
	loaded = {},
	loading = {}
}

-- Checks existense of specified path. It will be overriden after filesystem library initialization
local function requireExists(path)
	return bootFilesystemProxy.exists(path)
end

-- Works the similar way as native Lua require() function
function require(module)
	-- For non-case-sensitive filesystems
	local lowerModule = unicode.lower(module)

	if package.loaded[lowerModule] then
		return package.loaded[lowerModule]
	elseif package.loading[lowerModule] then
		error("recursive require() call found: library \"" .. module .. "\" is trying to require another library that requires it\n" .. debug.traceback())
	else
		local errors = {}

		local function checkVariant(variant)
			if requireExists(variant) then
				return variant
			else
				table.insert(errors, "  variant \"" .. variant .. "\" not exists")
			end
		end

		local function checkVariants(path, module)
			return
				checkVariant(path .. module .. ".lua") or
				checkVariant(path .. module) or
				checkVariant(module)
		end

		local modulePath
		for path in pairs(package.paths) do
			modulePath =
				checkVariants(path, module) or
				checkVariants(path, unicode.upper(unicode.sub(module, 1, 1)) .. unicode.sub(module, 2, -1))
			
			if modulePath then
				package.loading[lowerModule] = true
				local result = dofile(modulePath)
				package.loaded[lowerModule] = result or true
				package.loading[lowerModule] = nil
				
				return result
			end
		end

		error("unable to locate library \"" .. module .. "\":\n" .. table.concat(errors, "\n"))
	end
end

-- [LF] Creating LibFix's require function, so it can run libraries from a different location
function LibFixRequire(module)
	-- For non-case-sensitive filesystems
	local lowerModule = unicode.lower(module)

	if package.loaded[lowerModule] then
		return package.loaded[lowerModule]
	elseif package.loading[lowerModule] then
		error("recursive require() call found: library \"" .. module .. "\" is trying to require another library that requires it\n" .. debug.traceback())
	else
		local errors = {}

		local function checkVariant(variant)
			if requireExists(variant) then
				return variant
			else
				table.insert(errors, "  variant \"" .. variant .. "\" not exists")
			end
		end

		local function checkVariants(path, module)
			return
				checkVariant(path .. module .. ".lua") or
				checkVariant(path .. module) or
				checkVariant(module)
		end

		local modulePath
		for path in pairs(LibFixPackage.paths) do
			modulePath =
				checkVariants(path, module) or
				checkVariants(path, unicode.upper(unicode.sub(module, 1, 1)) .. unicode.sub(module, 2, -1))
			
			if modulePath then
				package.loading[lowerModule] = true
				local result = dofile(modulePath)
				package.loaded[lowerModule] = result or true
				package.loading[lowerModule] = nil
				
				return result
			end
		end

		error("unable to locate library \"" .. module .. "\":\n" .. table.concat(errors, "\n"))
	end
end

-- [LF] Loading libraries required for LibFix to work, and also setting filesystem proxy to allow the internet library
bit32 = bit32 or LibFixRequire("Bit32")
local paths = LibFixRequire("Paths")
local event = LibFixRequire("Event")
local filesystem = LibFixRequire("Filesystem")
filesystem.setProxy(bootFilesystemProxy)
local component = LibFixRequire("Component")
local internet = LibFixRequire("Internet")

requireExists = function(variant)
return filesystem.exists(variant)
end

-- [LF] Declare LibFix path variables
LFuserPath = filesystem.read("/Applications/LibFix/UserPath.cfg")
LFrepo = filesystem.read(LFuserPath .. "LibFix/RepoStore.cfg")

-- [LF] Check if all libraries exist, if not, create LibFix progress bar
if filesystem.exists("/Libraries/BigLetters.lua") and filesystem.exists("/Libraries/Bit32.lua") and filesystem.exists("/Libraries/Color.lua") and filesystem.exists("/Libraries/Component.lua") and filesystem.exists("/Libraries/Compressor.lua") and filesystem.exists("/Libraries/Event.lua") and filesystem.exists("/Libraries/Filesystem.lua") and filesystem.exists("/Libraries/GUI.lua") and filesystem.exists("/Libraries/Image.lua") and filesystem.exists("/Libraries/Internet.lua") and filesystem.exists("/Libraries/Keyboard.lua") and filesystem.exists("/Libraries/Network.lua") and filesystem.exists("/Libraries/Number.lua") and filesystem.exists("/Libraries/Paths.lua") and filesystem.exists("/Libraries/Screen.lua") and filesystem.exists("/Libraries/SHA-256.lua") and filesystem.exists("/Libraries/System.lua") and filesystem.exists("/Libraries/Text.lua") then
else
local GPUProxy = component.proxy(component.list("gpu")())
local screenWidth, screenHeight = GPUProxy.getResolution()

-- Displays title and currently required library when booting OS
local UIRequireTotal, UIRequireCounter = 19, 1

local function LFBar()
	local function centrize(width)
		return math.floor(screenWidth / 2 - width / 2)
	end
	
	local title, width, total = "LibFix", 26, 14
	local x, y, part = centrize(width), math.floor(screenHeight / 2 - 1), math.ceil(width * UIRequireCounter / UIRequireTotal)
	UIRequireCounter = UIRequireCounter + 1
	
	-- Title
	GPUProxy.setForeground(0x753AB5)
	GPUProxy.set(centrize(#title), y, title)

	-- Progressbar
	GPUProxy.setForeground(0x753AB5)
	GPUProxy.set(x, y + 2, string.rep("─", part))
	GPUProxy.setForeground(0xC3C3C3)
	GPUProxy.set(x + part, y + 2, string.rep("─", width - part))

	return
end

-- Preparing screen for repairing libraries
GPUProxy.setBackground(0xE1E1E1)
GPUProxy.fill(1, 1, screenWidth, screenHeight, " ")










--------------------------------------------------------------------------------------------------

-- [LF] Enabling online functionality if enabled in config

local component = LibFixRequire("Component")
local internet = LibFixRequire("Internet")

-- Check libraries to restore

if filesystem.exists(LFuserPath .. "LibFix/IsOnline.cfg") then

if filesystem.exists("/Libraries/BigLetters.lua") then
else internet.download(LFrepo .. "BigLetters.lua", "/Libraries/BigLetters.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Bit32.lua") then
else internet.download(LFrepo .. "Bit32.lua", "/Libraries/Bit32.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Color.lua") then
else internet.download(LFrepo .. "Color.lua", "/Libraries/Color.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Component.lua") then
else internet.download(LFrepo .. "Component.lua", "/Libraries/Component.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Compressor.lua") then
else internet.download(LFrepo .. "Compressor.lua", "/Libraries/Compressor.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Event.lua") then
else internet.download(LFrepo .. "Event.lua", "/Libraries/Event.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Filesystem.lua") then
else internet.download(LFrepo .. "Filesystem.lua", "/Libraries/Filesystem.lua")
	LFBar()
end

if filesystem.exists("/Libraries/GUI.lua") then
else internet.download(LFrepo .. "GUI.lua", "/Libraries/GUI.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Image.lua") then
else internet.download(LFrepo .. "Image.lua", "/Libraries/Image.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Internet.lua") then
else internet.download(LFrepo .. "Internet.lua", "/Libraries/Internet.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Keyboard.lua") then
else internet.download(LFrepo .. "Keyboard.lua", "/Libraries/Keyboard.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Network.lua") then
else internet.download(LFrepo .. "Network.lua", "/Libraries/Network.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Number.lua") then
else internet.download(LFrepo .. "Number.lua", "/Libraries/Number.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Paths.lua") then
else internet.download(LFrepo .. "Paths.lua", "/Libraries/Paths.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Screen.lua") then
else internet.download(LFrepo .. "Screen.lua", "/Libraries/Screen.lua")
	LFBar()
end

if filesystem.exists("/Libraries/SHA-256.lua") then
else internet.download(LFrepo .. "SHA-256.lua", "/Libraries/SHA-256.lua")
	LFBar()
end

if filesystem.exists("/Libraries/System.lua") then
else internet.download(LFrepo .. "System.lua", "/Libraries/System.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Text.lua") then
else internet.download(LFrepo .. "Text.lua", "/Libraries/Text.lua")
	LFBar()
end

else
--offline mode

-- Check libraries to restore

if filesystem.exists("/Libraries/BigLetters.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/BigLetters.lua", "/Libraries/BigLetters.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Bit32.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Bit32.lua", "/Libraries/Bit32.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Color.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Color.lua", "/Libraries/Color.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Component.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Component.lua", "/Libraries/Component.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Compressor.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Compressor.lua", "/Libraries/Compressor.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Event.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Event.lua", "/Libraries/Event.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Filesystem.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Filesystem.lua", "/Libraries/Filesystem.lua")
	LFBar()
end

if filesystem.exists("/Libraries/GUI.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/GUI.lua", "/Libraries/GUI.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Image.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Image.lua", "/Libraries/Image.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Internet.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Internet.lua", "/Libraries/Internet.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Keyboard.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Keyboard.lua", "/Libraries/Keyboard.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Network.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Network.lua", "/Libraries/Network.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Number.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Number.lua", "/Libraries/Number.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Paths.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Paths.lua", "/Libraries/Paths.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Screen.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Screen.lua", "/Libraries/Screen.lua")
	LFBar()
end

if filesystem.exists("/Libraries/SHA-256.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/SHA-256.lua", "/Libraries/SHA-256.lua")
	LFBar()
end

if filesystem.exists("/Libraries/System.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/System.lua", "/Libraries/System.lua")
	LFBar()
end

if filesystem.exists("/Libraries/Text.lua") then
else filesystem.copy("/Applications/ApplicationData/LibFix/OfflineLibraries/Text.lua", "/Libraries/Text.lua")
	LFBar()
end

end
end
end

local GPUProxy = component.proxy(component.list("gpu")())
local screenWidth, screenHeight = GPUProxy.getResolution()

-- Displays title and currently required library when booting OS
local UIRequireTotal, UIRequireCounter = 13, 1

local function UIRequire(module)
	local function centrize(width)
		return math.floor(screenWidth / 2 - width / 2)
	end
	
	local title, width, total = "MineOS", 26, 14
	local x, y, part = centrize(width), math.floor(screenHeight / 2 - 1), math.ceil(width * UIRequireCounter / UIRequireTotal)
	UIRequireCounter = UIRequireCounter + 1
	
	-- Title
	GPUProxy.setForeground(0x2D2D2D)
	GPUProxy.set(centrize(#title), y, title)

	-- Progressbar
	GPUProxy.setForeground(0x878787)
	GPUProxy.set(x, y + 2, string.rep("─", part))
	GPUProxy.setForeground(0xC3C3C3)
	GPUProxy.set(x + part, y + 2, string.rep("─", width - part))

	return require(module)
end

-- Preparing screen for loading libraries
GPUProxy.setBackground(0xE1E1E1)
GPUProxy.fill(1, 1, screenWidth, screenHeight, " ")

-- Loading libraries
bit32 = bit32 or UIRequire("Bit32")
local paths = UIRequire("Paths")
local event = UIRequire("Event")
local filesystem = UIRequire("Filesystem")

-- Redeclaring requireExists function after filesystem library initialization
requireExists = function(variant)
	return filesystem.exists(variant)
end

-- Loading other libraries
UIRequire("Component")
UIRequire("Keyboard")
UIRequire("Text")
UIRequire("Number")
UIRequire("Color")
local image = UIRequire("Image")
local screen = UIRequire("Screen")

-- Setting currently chosen GPU component as screen buffer main one
screen.setGPUProxy(GPUProxy)

local GUI = UIRequire("GUI")
local system = UIRequire("System")
UIRequire("Network")

-- Filling package.loaded with default global variables for OpenOS bitches
package.loaded.bit32 = bit32
package.loaded.computer = computer
package.loaded.component = component
package.loaded.unicode = unicode

---------------------------------------- Main loop ----------------------------------------

-- Creating OS workspace, which contains every window/menu/etc.
local workspace = GUI.workspace()
system.setWorkspace(workspace)

-- "double_touch" event handler
local doubleTouchInterval, doubleTouchX, doubleTouchY, doubleTouchButton, doubleTouchUptime, doubleTouchcomponentAddress = 0.3
event.addHandler(
	function(signalType, componentAddress, x, y, button, user)
		if signalType == "touch" then
			local uptime = computer.uptime()
			
			if doubleTouchX == x and doubleTouchY == y and doubleTouchButton == button and doubleTouchcomponentAddress == componentAddress and uptime - doubleTouchUptime <= doubleTouchInterval then
				computer.pushSignal("double_touch", componentAddress, x, y, button, user)
				event.skip("touch")
			end

			doubleTouchX, doubleTouchY, doubleTouchButton, doubleTouchUptime, doubleTouchcomponentAddress = x, y, button, uptime, componentAddress
		end
	end
)

-- Screen component attaching/detaching event handler
event.addHandler(
	function(signalType, componentAddress, componentType)
		if (signalType == "component_added" or signalType == "component_removed") and componentType == "screen" then
			local GPUProxy = screen.getGPUProxy()

			local function bindScreen(address)
				screen.bind(address, false)
				GPUProxy.setDepth(GPUProxy.maxDepth())
				workspace:draw()
			end

			if signalType == "component_added" then
				if not GPUProxy.getScreen() then
					bindScreen(componentAddress)
				end
			else
				if not GPUProxy.getScreen() then
					local address = component.list("screen")()
					if address then
						bindScreen(address)
					end
				end
			end
		end
	end
)

-- Logging in
system.authorize()

-- Main loop with UI regeneration after errors 
while true do
	local success, path, line, traceback = system.call(workspace.start, workspace, 0)
	if success then
		break
	else
		system.updateWorkspace()
		system.updateDesktop()
		workspace:draw()
		
		system.error(path, line, traceback)
		workspace:draw()
	end
end
