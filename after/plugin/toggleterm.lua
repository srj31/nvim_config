local toggleterm = require("toggleterm")

toggleterm.setup {
    open_mapping = [[<c-\>]],
    direction = "float",
    float_opts = {
        border = "curved",
    },

    -- function to run when the terminal opens
    size = function(term)
        if term.direction == "horizontal" then
            return 15
        elseif term.direction == "vertical" then
            return vim.o.columns * 0.4
        end
    end
}
