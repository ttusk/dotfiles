local opt = vim.opt

local function system_background()
    if vim.fn.has("macunix") == 1 or vim.fn.has("mac") == 1 then
        local style = vim.fn.system({ "defaults", "read", "-g", "AppleInterfaceStyle" })

        if style:lower():match("dark") then
            return "dark"
        end
    end

    return "light"
end

opt.termguicolors = true

local background = system_background()
opt.background = background

if background == "dark" then
    require("gruvbox").setup({})
    vim.cmd.colorscheme("gruvbox")
else
    require("solarized").setup({})
    vim.cmd.colorscheme("solarized")
end
