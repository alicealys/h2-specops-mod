function newrecord()
    local mapname = Engine.GetDvarString("mapname")
    local stats = sostats.getmapstats(mapname)
    local newbest = stats.besttime or 0

    local popupwidth = 500
    local title = "@MENU_SP_NEW_BESTTIME"
	local popup = LUI.MenuBuilder.BuildRegisteredType("generic_confirmation_popup", {
		popup_title = Engine.Localize(title),
		message_text = formattime(newbest),
        popup_width = 400,
        popup_title_alignment = LUI.Alignment.Center
	})

    popup:getFirstDescendentById("spacer"):close()

    local text = popup:getFirstDescendentById("message_text_id")
    text:registerAnimationState("text", {
        alignment = LUI.Alignment.Center,
        height = 30,
    })
    text:animateToState("text")

    return popup
end

LUI.MenuBuilder.registerPopupType("so_new_record", newrecord)
