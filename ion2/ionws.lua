--
-- Ion ionws module configuration file
--

-- Bindings for the tiled workspaces (ionws). These should work on any 
-- object on the workspace.

function goto_multihead(ws, dir)
    if dir=="up" or dir=="down" then
        ws:goto_dir(dir)
        return
    end
    
    local nxt, nxtscr
    
    nxt=ws:next_to(ws:current(), dir)
    
    if not nxt then
        local otherdir
        local fid=find_screen_id
        if dir=="right" then
            otherdir="left"
            nxtscr=fid(ws:screen_of():id()+1) or fid(0)
        else
            otherdir="right"
            nxtscr=fid(ws:screen_of():id()-1) or fid(-1)
        end
        nxt=nxtscr:current()
        if obj_is(nxt, "WIonWS") then
            nxt=nxt:farthest(otherdir)
        end
    end
    
    nxt:goto()
end

ionws_bindings{
    -- kpress("Control+Mod1+j", WIonWS.goto_below),
    -- kpress("Control+Mod1+k", WIonWS.goto_above),
    -- kpress("Control+Mod1+l", WIonWS.goto_right),
    -- kpress("Control+Mod1+h", WIonWS.goto_left),
    kpress("Control+Mod1+j", function(ws) goto_multihead(ws, "down") end),
    kpress("Control+Mod1+k", function(ws) goto_multihead(ws, "up") end),
    kpress("Control+Mod1+l", function(ws) goto_multihead(ws, "right") end),
    kpress("Control+Mod1+h", function(ws) goto_multihead(ws, "left") end),
}


-- Frame bindings. These work in (Ion/tiled-style) frames. Some bindings
-- that are common to all frame types and multiplexes are defined in
-- ion-bindings.lua.

ionframe_bindings{
    kpress("Control+Mod1+R", WIonFrame.begin_resize),
    kpress("Control+Mod1+S",
           function(frame) frame:split("bottom") end),
    kpress("Control+Mod1+V",
           function(frame) frame:split("right") end),

    submap("Control+Mod1+K", {
        --kpress("AnyModifier+T", 
        --       make_mplex_clientwin_fn(WClientWin.toggle_transients_pos)),
        kpress("AnyModifier+X", WIonFrame.relocate_and_close),
        kpress("AnyModifier+S",
               function(frame) frame:split("right") end),
    }),
    
    mclick("Button1", WGenFrame.p_switch_tab, "tab"),
    mdblclick("Button1", WIonFrame.toggle_shade, "tab"),
    mdrag("Button1", WGenFrame.p_tabdrag, "tab"),
    mdrag("Button1", WGenFrame.p_resize, "border"),
    
    mclick("Button2", WGenFrame.p_switch_tab, "tab"),
    mdrag("Button2", WGenFrame.p_tabdrag, "tab"),
    
    mdrag("Control+Mod1+Button3", WGenFrame.p_resize),
}


-- Frame resize mode bindings

ionframe_moveres_bindings{
    kpress("AnyModifier+Escape", WIonFrame.cancel_resize),
    kpress("AnyModifier+Return", WIonFrame.end_resize),
    
    kpress("Left", function(f) f:do_resize( 1, 0, 0, 0) end),
    kpress("Right",function(f) f:do_resize( 0, 1, 0, 0) end),
    kpress("Up",   function(f) f:do_resize( 0, 0, 1, 0) end),
    kpress("Down", function(f) f:do_resize( 0, 0, 0, 1) end),
    kpress("F",    function(f) f:do_resize( 1, 0, 0, 0) end),
    kpress("B",    function(f) f:do_resize( 0, 1, 0, 0) end),
    kpress("P",    function(f) f:do_resize( 0, 0, 1, 0) end),
    kpress("N",    function(f) f:do_resize( 0, 0, 0, 1) end),

    kpress("Shift+Left", function(f) f:do_resize(-1, 0, 0, 0) end),
    kpress("Shift+Right",function(f) f:do_resize( 0,-1, 0, 0) end),
    kpress("Shift+Up",   function(f) f:do_resize( 0, 0,-1, 0) end),
    kpress("Shift+Down", function(f) f:do_resize( 0, 0, 0,-1) end),
    kpress("Shift+F",    function(f) f:do_resize(-1, 0, 0, 0) end),
    kpress("Shift+B",    function(f) f:do_resize( 0,-1, 0, 0) end),
    kpress("Shift+P",    function(f) f:do_resize( 0, 0,-1, 0) end),
    kpress("Shift+N",    function(f) f:do_resize( 0, 0, 0,-1) end),
}
