--################
--## AUTOSTART ###
--################

---@module 'hl'

hl.on("hyprland.start", function()
	hl.exec_cmd("qs -p ~/.config/quickshell/cartoon-shell")
end)
