-- overrides for silicon - tool to create code images
local utils = require("core.utils")
if utils.is_wsl or utils.is_mac or utils.is_linux then
	return {
		font = "VictorMono NF;Noto Emoji",
		to_clipboard = false,
	}
else
	return {}
end
