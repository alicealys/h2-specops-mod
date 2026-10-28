function newstars()
    local popupwidth = 500
    local title = "@MENU_SP_STARS_EARNED"
	local popup = LUI.MenuBuilder.BuildRegisteredType("generic_confirmation_popup", {
		popup_title = Engine.Localize(title),
		message_text = formattime(10000),
        popup_width = 400,
        popup_title_alignment = LUI.Alignment.Center
	})

    popup:getFirstDescendentById("spacer"):close()
    popup:getFirstDescendentById("message_text_id"):close()

    local content = popup:getFirstDescendentById("generic_selectionList_content_id")
    local width = 210
    local height = 50
    local container = LUI.UIElement.new({
        topAnchor = true,
        alignment = LUI.Alignment.Center,
        width = width,
        height = height + 10,
    })

    local extraheight = 100

    local num = 0
    local staticnum = 0
    local addstar = function(static)
        local leftoffset = 0
        if (num == 0) then
            leftoffset = - (extraheight) / 2
        elseif (num == 1) then
            leftoffset = - (height + extraheight) / 2
        elseif (num == 2) then
            leftoffset = - (height + extraheight / 2)
        end

        local star = nil
        if (static) then
            star = LUI.UIImage.new({
                topAnchor = true,
                leftAnchor = staticnum == 0,
                rightAnchor = staticnum == 2,
                height = height,
                width = height,
                color = {
                    r = 0.1,
                    g = 0.1,
                    b = 0.1,
                },
                alpha = 1,
                material = RegisterMaterial("star")
            })
        else
            star = LUI.UIImage.new({
                topAnchor = true,
                leftAnchor = num == 0,
                rightAnchor = num == 2,
                top = - (extraheight) / 2,
                left = leftoffset,
                height = height + extraheight,
                width = height + extraheight,
                color = Colors.white,
                alpha = 0,
                material = RegisterMaterial("star")
            })

            star:registerAnimationState("disabled", {
                topAnchor = true,
                leftAnchor = num == 0,
                rightAnchor = num == 2,
                height = height,
                width = height,
                color = Colors.light_grey,
                alpha = 1,
                material = RegisterMaterial("star")
            })
    
            star:registerAnimationState("enabled", {
                topAnchor = true,
                leftAnchor = num == 0,
                rightAnchor = num == 2,
                height = height,
                width = height,
                color = Colors.h2.yellow,
                alpha = 1,
                material = RegisterMaterial("star")
            })
        end

        if (not static) then
            num = num + 1
        else
            staticnum = staticnum + 1
        end

        container:addElement(star)

        return star
    end

    addstar(true)
    addstar(true)
    addstar(true)

    local stars = {
        addstar(),
        addstar(),
        addstar(),
    }

    local timer = LUI.UITimer.new(300, "star_update")
    container:addElement(timer)
    local starnum = 1

    local newstars = tonumber(Engine.GetDvarString("ui_so_new_stars"))
    local prevstars = tonumber(Engine.GetDvarString("ui_so_prev_stars"))

    container:registerEventHandler("star_update", function()
        if (stars[starnum] == nil) then
            timer:close()
            return
        end

        if (starnum <= prevstars) then
            Engine.PlaySound("so_earn_star")
            stars[starnum]:animateToState("disabled", 100)
        elseif (starnum <= newstars) then
            Engine.PlaySound("so_earn_star")
            stars[starnum]:animateToState("enabled", 100)
        end

        starnum = starnum + 1
    end)    

    popup:registerEventHandler("menu_close", function()
        local newbest = tonumber(Engine.GetDvarString("ui_so_new_besttime")) == 1
        if (newbest) then
            LUI.FlowManager.RequestAddMenu(nil, "so_new_record")
        end
    end)

    content:insertElement(container, 1)

    return popup
end

LUI.MenuBuilder.registerPopupType("so_new_stars", newstars)
