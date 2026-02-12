-- While (heavily) modified by me the general structure of this file was not created by me,
-- but brazenly copied from rebelot, who is the creator of heirline
-- You can find it here: https://github.com/rebelot/heirline.nvim/blob/master/cookbook.md

local conditions = require("heirline.conditions")
local utils = require("heirline.utils")

local colors = {
        bright_bg = utils.get_highlight("Folded").bg,
        bright_fg = utils.get_highlight("Folded").fg,
        red = utils.get_highlight("DiagnosticError").fg,
        dark_red = utils.get_highlight("DiffDelete").bg,
        green = utils.get_highlight("String").fg,
        blue = utils.get_highlight("Function").fg,
        gray = utils.get_highlight("NonText").fg,
        orange = utils.get_highlight("Constant").fg,
        purple = utils.get_highlight("Statement").fg,
        cyan = utils.get_highlight("Special").fg,
        diag_WARN = utils.get_highlight("DiagnosticWarn").fg,
        diag_ERROR = utils.get_highlight("DiagnosticError").fg,
        diag_HINT = utils.get_highlight("DiagnosticHint").fg,
        diag_INFO = utils.get_highlight("DiagnosticInfo").fg,
        git_del = utils.get_highlight("diffRemoved").fg,
        git_add = utils.get_highlight("diffAdded").fg,
        git_change = utils.get_highlight("diffChanged").fg,
}

-- local colors = require("catppuccin.palettes").get_palette()

local ViMode = {
        init = function(self)
                self.mode = vim.fn.mode(1)
        end,

        static = {
                mode_names = {
                        n = "NORMAL", -- Normal
                        no = "N?",
                        nov = "N?",
                        noV = "N?",
                        ["no\22"] = "N?",
                        niI = "Ni",
                        niR = "Nr",
                        niV = "Nv",
                        nt = "Nt",
                        v = "VISUAL", -- Visual
                        vs = "Vs",
                        V = "V_",
                        Vs = "Vs",
                        ["\22"] = "VISUAL BLOCK",
                        ["\22s"] = "VISUAL BLOCK",
                        s = "S", -- Insert it seems
                        S = "S_",
                        ["\19"] = "^S",
                        i = "INSERT", -- Insert
                        ic = "Ic",
                        ix = "Ix",
                        R = "REPLACE", -- Replace
                        Rc = "Rc",
                        rx = "Rx",
                        Rx = "Rx",
                        rv = "Rv",
                        Rv = "Rv",
                        Rvc = "Rv",
                        Rvx = "Rv",
                        c = "C", -- "cut" it seems?
                        cv = "Ex",
                        r = "...",
                        rm = "M",
                        ["r?"] = "?",
                        ["!"] = "!",
                        t = "T",
                },
                mode_colors = {
                        n = "red",
                        i = "green",
                        v = "cyan",
                        V = "cyan",
                        ["\22"] = "cyan",
                        c = "orange",
                        s = "purple",
                        S = "purple",
                        ["\19"] = "purple",
                        R = "orange",
                        r = "orange",
                        ["!"] = "red",
                        t = "red",
                }
        },

        provider = function(self)
                return "%2("..self.mode_names[self.mode].."%)"
        end,
        hl = function(self)
                local mode = self.mode:sub(1, 1)
                return {fg = self.mode_colors[mode], bold = true,}
        end,

        update = {
                "ModeChanged",
                pattern = "*:*",
                callback = vim.schedule_wrap(function()
                        vim.cmd("redrawstatus")
                end),
        },
}

local FileNameBlock = {
        init = function(self)
                self.filename = vim.api.nvim_buf_get_name(0)
        end,
}

local FileIcon = {
        init = function(self)
                local filename = self.filename
                local extension = vim.fn.fnamemodify(filename, ":e")
                self.icon, self.icon_color = require("nvim-web-devicons").get_icon_color(filename, extension, {default = true})
        end,

        provider = function(self)
                return self.icon and (self.icon .. " ")
        end,

        hl = function(self)
                return { fg = self.icon_color }
        end,
}

local FileName = {
        provider = function(self)
                local filename = vim.fn.fnamemodify(self.filename, ":.")
                if filename == "" then return "[No Name]" end
                if not conditions.width_percent_below(#filename, 0.25) then
                        filename = vim.fn.pathshorten(filename)
                end
                return filename
        end,
        hl = { fg = utils.get_highlight("Directory").fg },
}

local FileFlags = {
        {
                condition = function()
                        return vim.bo.modified
                end,
                provider = " [+]",
                hl = { fg = "cyan" },
        },
        {
                condition = function()
                        return not vim.bo.modifiable or vim.bo.readonly
                end,
                provider = " ",
                hl = { fg = "orange" }
        }
}

local FileNameModifier = {
        hl = function()
                if vim.bo.modified then
                        return { fg = "red", bold = true, force = true } -- force needed to override the child's hl.fg
                end
        end,
}

FileNameBlock = utils.insert(FileNameBlock,
        FileIcon,
        utils.insert(FileNameModifier, FileName),
        FileFlags,
        { provider = '%<' } -- the statusline will be cut here when there is not enough space
)

local FileType = {
        provider = function()
                return string.upper(vim.bo.filetype)
        end,
        hl = { fg = utils.get_highlight("Type").fg, bold = true },
}

local FileEncoding = {
        provider = function()
                local enc = (vim.bo.fenc ~= '' and vim.bo.fenc) or vim.o.enc
                return enc ~= 'utf-8' and enc:upper()
        end,
}

local FileFormat = {
        provider = function()
                local fmt = vim.bo.fileformat
                return fmt ~= 'unix' and fmt:upper()
        end,
}

local FileSize = {
        provider = function()
                local suffix = { 'b', 'k', 'M', 'G', 'T', 'P', 'E' }
                local fsize = vim.fn.getfsize(vim.api.nvim_buf_get_name(0))
                fsize = (fsize < 0 and 0) or fsize
                if fsize < 1024 then
                        return fsize..suffix[1]
                end
                local i = math.floor((math.log(fsize) / math.log(1024)))
                return string.format("%.2g%s", fsize / math.pow(1024, i), suffix[i + 1])
        end,
}

local FileLastModified = {
        provider = function()
                local ftime = vim.fn.getftime(vim.api.nvim_buf_get_name(0))
                return (ftime > 0) and os.date("%c", ftime)
        end,
}

local Ruler = {
        -- %l = current line number
        -- %L = number of lines in the buffer
        -- %c = column number
        -- %P = percentage through file of displayed window
        provider = "%7(%1/%3L%):%2c %P",
}

local ScrollBar = {
        static = {
                sbar = { '▁', '▂', '▃', '▄', '▅', '▆', '▇', '█' }
        },
        provider = function(self)
                local curr_line = vim.api.nvim_win_get_cursor(0)[1]
                local lines = vim.api.nvim_buf_line_count(0)
                local i = math.floor((curr_line - 1) / lines * #self.sbar) + 1
                return string.rep(self.sbar[i], 2)
        end,
        hl = { fg = "blue", bg = "bright_bg" },
}

local LSPActive = {
        condition = conditions.lsp_attached,
        update = {'LspAttach', "LspDetach"},

        provider = function()
                local names = {}
                for i, server in pairs(vim.lsp.get_clients({ bufnr = 0 })) do
                        table.insert(names, server.name)
                end
                return " [" .. table.concat(names, " ") .. "]"
        end,
        hl = { fg = "green", bold = true },
}

--[[local LSPMessages = {
        provider = require("lsp-status").status,
        hl = { fg = "gray" }
}]]

local Navic = { -- far simpler but works
        condition = function() return require("nvim-navic").is_available() end,
        provider = function()
                return require("nvim-navic").get_location({highlight=true})
        end,
        update = 'CursorMoved'
}

--[[local Navic = { -- more complicated -> caused errors with its bit shifts
        condition = function() return require("nvim-navic").is_available() end,
        static = {
                -- creates a type highlight map
                type_hl = {
                        File = "Directory",
                        Module = "@include",
                        Namespace = "@namespace",
                        Package = "@include",
                        Class = "@structure",
                        Method = "@method",
                        Property = "@property",
                        Field = "@field",
                        Constructor = "@constructor",
                        Enum = "@enum",
                        Interface = "@type",
                        Function = "@function",
                        Variable = "@variable",
                        Constant = "@constant",
                        String = "@string",
                        Number = "@number",
                        Boolean = "@boolean",
                        Array = "@field",
                        Object = "@type",
                        Key = "@keyword",
                        Null = "@comment",
                        EnumMember = "@field",
                        Struct = "@structure",
                        Event = "@keyword",
                        Operator = "@operator",
                        TypeParameter = "@type",
                },

                enc = function(line, col, winnr)
                        return bit.bor(bit.lshift(line, 16), bit.lshift(col, 6), winnr)
                end,

                -- line: 16 bit (65535); col: 10 bit (1023); winnr: 6 bit (63)
                dec = function(c)
                        local line = bit.rshift(c, 16)
                        local col = bit.band(bit.rshift(c, 6), 1023)
                        local winnr = bit.band(c, 63)
                        return line, col, winnr
                end,
        },

        init = function(self)
                local data = require("nvim-navic").get_data() or {}
                local children = {}

                -- create a child for each level
                for i, d in ipairs(data) do
                        local pos = self.enc(d.scope.start.line, d.scope.character, self.winnr)
                        local child = {
                                {
                                        provider = d.icon,
                                        hl = self.type_hl[d.type],
                                },
                                {
                                        provider = d.name:gsub("%%", "%%%%"):gsub("%s*->%s*", ''),

                                        on_click = {
                                                minwid = pos,
                                                callback = function(_, minwid)
                                                        local line, col, winnr = self.dec(minwid)
                                                        vim.api.nvim_win_set_cursor(vim.fn.win_getid(winnr), {line, col})
                                                end,
                                                name = "heirline_navic"
                                        },
                                },
                        }

                        if #data > 1 and i < #data then
                                table.insert(child, {
                                        provider = " > ",
                                        hl = { fg = "bright_fg" },
                                })
                        end
                        table.insert(children, child)
                end

                self.child = self:new(children, 1)
        end,

        provider = function(self)
                return self.child:eval()
        end,
        hl = { fg = "gray" },
        update = 'CursorMoved'
}]]

local Diagnostics = {
        condition = conditions.has_diagnostics,

        static = {
                error_icon = vim.diagnostic.config()['signs']['text'][vim.diagnostic.severity.ERROR],
                warn_icon = vim.diagnostic.config()['signs']['text'][vim.diagnostic.severity.WARN],
                info_icon = vim.diagnostic.config()['signs']['text'][vim.diagnostic.severity.INFO],
                hint_icon = vim.diagnostic.config()['signs']['text'][vim.diagnostic.severity.HINT],
        },

        init = function(self)
                self.errors = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.ERROR })
                self.warnings = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.WARN })
                self.hints = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.HINT })
                self.info = #vim.diagnostic.get(0, { severity = vim.diagnostic.severity.INFO })
        end,

        update = { "DiagnosticChanged", "BufEnter" },

        {
                provider = "![",
        },
        {
                provider = function(self)
                        return self.errors > 0 and (self.error_icon .. " " .. self.errors .. " ")
                end,
                hl = { fg = "diag_ERROR" },
        },
        {
                provider = function(self)
                        return self.warnings > 0 and (self.warn_icon .. " " .. self.warnings .. " ")
                end,
                hl = { fg = "diag_WARN" },
        },
        {
                provider = function(self)
                        return self.info > 0 and (self.info_icon .. " " .. self.info .. " ")
                end,
                hl = { fg = "diag_INFO" },
        },
        {
                provider = function(self)
                        return self.hints > 0 and (self.hint_icon .. " " .. self.hints .. " ")
                end,
                hl = { fg = "diag_HINT" },
        },
        {
                provider = "]",
        },
}

local Git = {
        condition = conditions.is_git_repo,

        init = function(self)
                self.status_dict = vim.b.gitsigns_status_dict
                self.has_changes = self.status_dict.added ~= 0 or self.status_dict.removed ~= 0 or self.status_dict.changed ~= 0
        end,

        hl = { fg = "orange" },

        {       -- git branch name
                provider = function(self)
                        return " " .. self.status_dict.head
                end,
                hl = { bold = true }
        },
        {
                condition = function(self)
                        return self.has_changes
                end,
                provider = "("
        },
        {
                provider = function (self)
                        local count = self.status_dict.added or 0
                        return count > 0 and ("+" .. count)
                end,
                hl = { fg = "git_add" }
        },
        {
                provider = function(self)
                        local count = self.status_dict.removed or 0
                        return count > 0 and ("-" .. count)
                end,
                hl = { fg = "git_del" }
        },
        {
                provider = function(self)
                        local count = self.status_dict.changed or 0
                        return count > 0 and ("~" .. count)
                end,
                hl = { fg = "git_change" }
        },
        {
                condition = function (self)
                        return self.has_changes
                end,
                provider = ")",
        },
}

local WorkDir = {
        provider = function()
                local icon = (vim.fn.haslocaldir(0) == 1 and "1" or "g") .. " " .. " "
                local cwd = vim.fn.getcwd(0)
                cwd = vim.fn.fnamemodify(cwd, ":~")
                if not conditions.width_percent_below(#cwd, 0.25) then
                        cwd = vim.fn.pathshorten(cwd)
                end
                local trail = cwd:sub(-1) == "/" and '' or "/"
                return icon .. cwd .. trail
        end,
        hl = { fg = "blue", bold = true },
}

local TerminalName = {
        provider = function()
                local tname, _ = vim.api.nvim_buf_get_name(0):gsub(".*:", "")
                return " " .. tname
        end,
        hl = { fg = "blue", bold = true },
}

local Wakastat = {
        provider = function ()
                return " " .. require("wakastat").status() .. " "
        end,
        hl = "Wakastat",
        update = { "User", pattern = "WakastatUpdated "},
}

local Align = { provider = "%=" }
local Space = { provider = " " }

local DefaultStatusLine = {
        ViMode, Space, FileNameBlock, Space, Git, Space, Diagnostics, Align,
        Navic, Align,
        LSPActive, Space, --[[LSPMessages, Space,]] FileType, Space, Ruler, Space, ScrollBar
}

local InactiveStatusLine = {
        condition = conditions.is_not_active,
        FileType, Space, FileName, Align
}

local TerminalStatusLine = {
        condition = function()
            return conditions.buffer_matches({ buftype = { "terminal" } })
        end,

        hl = { bg = "dark_red" },

        { condition = conditions.is_active, ViMode, Space }, FileType, Space, TerminalName, Align,
}

local StatusLines = {
        hl = function ()
                if conditions.is_active() then
                        return "StatusLine"
                else
                        return "StatusLineNC"
                end
        end,

        fallthrough = false,

        TerminalStatusLine, InactiveStatusLine, DefaultStatusLine,
}

require("heirline").setup({
        statusline = StatusLines,
        opts = {
                colors = colors,
        }
})
