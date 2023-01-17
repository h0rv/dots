local pdfPath = '/tmp/nvim.pdf'

-- Compile and Open Zathura

-- [1] Get the extension of the file
-- [2] Apply appropriate compilation command
-- [3] Save PDF as /tmp/nvim.pdf
function Compile()
    local file = vim.fn.expand('%:p') -- Get current file name
    local extension = vim.bo.filetype
    if extension == 'markdown' then
        os.execute('pandoc \'' .. file .. '\' --pdf-engine=xelatex -o ' .. pdfPath)
    end
end

-- Open the PDF from /tmp/
function Preview()
    Compile()
    os.execute('zathura ' .. pdfPath .. ' &')
end

-- alt + p: Compile
vim.keymap.set('n', '<A-p>', Preview)
-- alt + c: Preview
vim.keymap.set('n', '<A-c>', Compile)
