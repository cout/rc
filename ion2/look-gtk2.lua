-- theme that goes well with the gtk2 default colors
-- it makes use of terminus als artwiz fonts
--
--	By Rene van Bevern <rvb@pro-linux.de>

if not gr_select_engine("de") then return end

de_reset()

de_define_style("*", {
    shadow_colour = "#9c9a94",
    highlight_colour = "#ffffff",
    background_colour = "#dedbd6",
    foreground_colour = "#000000",
    padding_pixels = 0,
    highlight_pixels = 1,
    shadow_pixels = 1,
    border_style = "elevated",
    font = "-*-helvetica-medium-r-normal-*-*-120-*-*-*-*-iso8859-15",
    text_align = "center",
})

de_define_style("frame", {
    based_on = "*",
    shadow_colour = "#9c9a94",
    highlight_colour = "#ffffff",
    padding_colour = "#dedbd6",
    background_colour = "#dedbd6",
    transparent_background = true,
    foreground_colour = "#ffffff",
    padding_pixels = 2,
    highlight_pixels = 1,
    shadow_pixels = 1,
    de_substyle("active", {
        shadow_colour = "#9c9a94",
        highlight_colour = "#ffffff",
        background_colour = "#dedbd6",
        foreground_colour = "#ffffff",
    }),
})

de_define_style("frame-ionframe", {
    based_on = "frame",
    border_style = "inlaid",
    padding_pixels = 1,
    spacing = 2,
})

de_define_style("frame-floatframe", {
    based_on = "frame",
    border_style = "ridge",
    padding_pixels = 1
})

de_define_style("tab", {
    based_on = "*",
    border_style = "groove",
    font = "anorexia",
    de_substyle("active-selected", {
        shadow_colour = "#1a3954",
        highlight_colour = "#7aa9d4",
        background_colour = "#4a6984",
        foreground_colour = "#ffffff",
    }),
    de_substyle("active-unselected", {
        shadow_colour = "#9c9a94",
        highlight_colour = "#ffffff",
        background_colour = "#dedbd6",
        foreground_colour = "#000000",
    }),
    de_substyle("inactive-selected", {
        shadow_colour = "#9c9a94",
        highlight_colour = "#ffffff",
        background_colour = "#efebe7",
        foreground_colour = "#97979e",
    }),
    de_substyle("inactive-unselected", {
        shadow_colour = "#9c9a94",
        highlight_colour = "#ffffff",
        background_colour = "#dedbd6",
        foreground_colour = "#97979e",
    }),
    text_align = "center",
})

de_define_style("tab-frame", {
    based_on = "tab",
    de_substyle("*-*-*-*-activity", {
        shadow_colour = "#777777",
        highlight_colour = "#eeeeee",
        background_colour = "#990000",
        foreground_colour = "#eeeeee",
    }),
})

de_define_style("tab-frame-ionframe", {
    based_on = "tab-frame",
    spacing = 3,
})

de_define_style("tab-menuentry", {
    based_on = "tab",
    spacing = 2,
    highlight_pixels = 1,
    shadow_pixels = 1,
    text_align = "left",
    font = "fixed",
    de_substyle("inactive-selected", {
        shadow_colour = "#1a3954",
        highlight_colour = "#7aa9d4",
        background_colour = "#4a6984",
        foreground_colour = "#ffffff",
    }),
    de_substyle("inactive-unselected", {
        shadow_colour = "#9c9a94",
        highlight_colour = "#ffffff",
        background_colour = "#dedbd6",
        foreground_colour = "#000000",
    }),

})

de_define_style("tab-menuentry-big", {
    based_on = "tab-menuentry",
    font = "-*-terminus-medium-r-*-*-17-120-*-*-*-*-iso8859-15",
})

de_define_style("input", {
    based_on = "tab",
    font = "-*-terminus-medium-r-*-*-17-120-*-*-*-*-iso8859-15",
    de_substyle("*-cursor", {
        background_colour = "#000000",
        foreground_colour = "#aaaaaa",
    }),
    de_substyle("*-selection", {
        background_colour = "#aaaaaa",
        foreground_colour = "black",
    }),
})

gr_refresh()
