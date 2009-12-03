-- 
-- Ion bindings configuration file. Global bindings and bindings common 
-- to screens and all types of frames only. See modules' configuration 
-- files for other bindings.
--

-- Load a library to create common queries.
include("querylib")
-- Load a library to create menu display callbacks.
include("menulib")


-- global_bindings
--
-- Global bindings are available all the time. The functions given here 
-- should accept WScreens as parameter. 
--
-- The variable ctrlalt should contain a string of the form 'Mod1+'
-- where Mod1 maybe replaced with the modifier you want to use for most
-- of the bindings. Similarly SECOND_MOD may be redefined to add a 
-- modifier to some of the F-key bindings.

global_bindings{
    kpress("Control+Mod1+1", function(s) s:switch_nth(0) end),
    kpress("Control+Mod1+2", function(s) s:switch_nth(1) end),
    kpress("Control+Mod1+3", function(s) s:switch_nth(2) end),
    kpress("Control+Mod1+4", function(s) s:switch_nth(3) end),
    kpress("Control+Mod1+5", function(s) s:switch_nth(4) end),
    kpress("Control+Mod1+6", function(s) s:switch_nth(5) end),
    kpress("Control+Mod1+7", function(s) s:switch_nth(6) end),
    kpress("Control+Mod1+8", function(s) s:switch_nth(7) end),
    kpress("Control+Mod1+9", function(s) s:switch_nth(8) end),
    kpress("Control+Mod1+0", function(s) s:switch_nth(9) end),
    kpress("Control+Mod1+Left", WScreen.switch_prev),
    kpress("Control+Mod1+comma", WScreen.switch_prev),
    kpress("Control+Mod1+less", WScreen.switch_prev),
    kpress("Control+Mod1+Right", WScreen.switch_next),
    kpress("Control+Mod1+period", WScreen.switch_next),
    kpress("Control+Mod1+greater", WScreen.switch_next),
    
    kpress("F2", make_exec_fn("Eterm")),
    kpress("Control+F2", make_exec_fn("mlterm")),

    -- KEYF11 and KEYF12 are normally defined to be the strings "F11" 
    -- and "F12", respectively, but on SunOS, they're something  else 
    -- (although the keys on the keyboard are the same).
    kpress(KEYF12, make_bigmenu_fn("mainmenu")),
    mpress("Button2", make_pmenu_fn("windowlist")),
    mpress("Button3", make_pmenu_fn("mainmenu")),
    
    -- submap("Control+Mod1+K", {
    --     kpress("AnyModifier+K", goto_previous),
    --     kpress("AnyModifier+T", clear_tags),
    
    -- kpress("Control+Mod1+Shift+Right", goto_prev_screen),
    
    -- kpress("Control+Mod1+F1", function(scr)
    --                               -- Display Ion's manual page
    --                               local m=lookup_script("ion-man")
    --                               if m then
    --                                   exec_in(scr, m.." ion")
    --                               end
    --                           end),
    
    -- Create a new workspace with a default name.
    kpress("Control+F9", 
           function(scr)
               scr:attach_new({ type='WIonWS', switchto=true })
           end),
    kpress("Mod1+F9", 
           function(scr)
               scr:attach_new({ type='WFloatWS', switchto=true })
           end),

    -- Menus/queries

    --kpress("Control+Mod1+Menu", make_bigmenu_fn("mainmenu")),
    --kpress(SECOND_MOD..KEYF11, querylib.query_restart),
    --kpress(SECOND_MOD..KEYF12, querylib.query_exit),
}


-- mplex_bindings
--
-- These bindings work in frames and on screens. The innermost of such
-- objects always gets to handle the key press. Essentially these bindings
-- are used to define actions on client windows. (Remember that client
-- windows can be put in fullscreen mode and therefore may not have a
-- frame.)
-- 
-- The make_*_fn functions are used to call functions on the object currently 
-- managed by the screen or frame or the frame itself. Essentially e.g.
-- make_mplex_clientwin_fn(fn) expands to
-- 
-- function(mplex, sub)
--     local reg=(sub or mplex:current())
--     if obj_is(reg, "WClientWin") then 
--         fn(reg)
--     end
-- end
-- 
-- For details see the document "Ion: Configuring and extending with Lua".

mplex_bindings{
    kpress_waitrel("Control+Mod1+C", WMPlex.close_sub_or_self),
    kpress_waitrel("Control+Mod1+L", 
                   make_mplex_clientwin_fn(WClientWin.broken_app_resize_kludge)),
    kpress_waitrel("Mod1+Return", 
                   make_mplex_clientwin_fn(WClientWin.toggle_fullscreen)),

    -- submap("Control+Mod1+K", {
    --     kpress("AnyModifier+C",
    --            make_mplex_clientwin_fn(WClientWin.kill)),
    --     kpress("AnyModifier+Q", 
    --            make_mplex_clientwin_fn(WClientWin.quote_next)),
    -- }),
}


-- genframe_bindings
--
-- These bindings are common to all types of frames. The rest of frame
-- bindings that differ between frame types are defined in the modules' 
-- configuration files.

genframe_bindings{
    -- Tag viewed object
    kpress("Control+Mod1+T", make_mplex_sub_fn(WRegion.toggle_tag)),

    -- Attach tagged objects
    kpress("Control+Mod1+A", WGenFrame.attach_tagged),
    
    -- Selected object/tab switching
    kpress("Mod1+Shift+greater", WGenFrame.switch_next),
    kpress("Mod1+Shift+period", WGenFrame.switch_next),
    kpress("Mod1+Shift+less", WGenFrame.switch_prev),
    kpress("Mod1+Shift+comma", WGenFrame.switch_prev),
    kpress("Mod1+Shift+1", function(f) f:switch_nth(0) end),
    kpress("Mod1+Shift+2", function(f) f:switch_nth(1) end),
    kpress("Mod1+Shift+3", function(f) f:switch_nth(2) end),
    kpress("Mod1+Shift+4", function(f) f:switch_nth(3) end),
    kpress("Mod1+Shift+5", function(f) f:switch_nth(4) end),
    kpress("Mod1+Shift+6", function(f) f:switch_nth(5) end),
    kpress("Mod1+Shift+7", function(f) f:switch_nth(6) end),
    kpress("Mod1+Shift+8", function(f) f:switch_nth(7) end),
    kpress("Mod1+Shift+9", function(f) f:switch_nth(8) end),
    kpress("Mod1+Shift+0", function(f) f:switch_nth(9) end),

    -- Maximize
    submap("Control+Mod1+M", {
      kpress("AnyModifier+H", WGenFrame.maximize_horiz),
      kpress("AnyModifier+V", WGenFrame.maximize_vert),
    }),

    -- Queries
    kpress("Control+Mod1+G", querylib.query_gotoclient),
    kpress(SECOND_MOD.."F1", querylib.query_man),
    kpress(SECOND_MOD.."F3", querylib.query_exec),
    kpress("Mod1+F3", querylib.query_lua),
    kpress(SECOND_MOD.."F4", querylib.query_ssh),
    kpress(SECOND_MOD.."F5", querylib.query_editfile),
    kpress(SECOND_MOD.."F6", querylib.query_runfile),
    -- kpress(SECOND_MOD.."F9", querylib.query_workspace),
    -- Menus
    kpress("Control+Mod1+M", make_menu_fn("ctxmenu")),
    mpress("Button3", make_pmenu_fn("ctxmenu"), "tab"),

    -- Move workspaces left/right
    kpress("Control+Mod1+minus", function(f) f:parent():move_current_to_prev_index() end),
    kpress("Control+Mod1+underscore", function(f) f:parent():move_current_to_prev_index() end),
    kpress("Control+Mod1+plus", function(f) f:parent():move_current_to_next_index() end),
    kpress("Control+Mod1+equal", function(f) f:parent():move_current_to_next_index() end),
}

