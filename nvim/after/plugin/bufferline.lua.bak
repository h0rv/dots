local set = vim.keymap.set
local opts = { noremap = true, silent = true }

-- Move to previous/next
set('n', '<A-H>', '<Cmd>BufferPrevious<CR>', opts)
set('n', '<A-L>', '<Cmd>BufferNext<CR>', opts)
-- Close buffer
set('n', '<A-c>', '<Cmd>BufferClose<CR>', opts)
-- Re-order to previous/next
-- set('n', '<A-H>', '<Cmd>BufferMovePrevious<CR>', opts)
-- set('n', '<A-L>', '<Cmd>BufferMoveNext<CR>', opts)
-- Goto buffer in position...
-- set('n', '<A-1>', '<Cmd>BufferGoto 1<CR>', opts)
-- set('n', '<A-2>', '<Cmd>BufferGoto 2<CR>', opts)
-- set('n', '<A-3>', '<Cmd>BufferGoto 3<CR>', opts)
-- set('n', '<A-4>', '<Cmd>BufferGoto 4<CR>', opts)
-- set('n', '<A-5>', '<Cmd>BufferGoto 5<CR>', opts)
-- set('n', '<A-6>', '<Cmd>BufferGoto 6<CR>', opts)
-- set('n', '<A-7>', '<Cmd>BufferGoto 7<CR>', opts)
-- set('n', '<A-8>', '<Cmd>BufferGoto 8<CR>', opts)
-- set('n', '<A-9>', '<Cmd>BufferGoto 9<CR>', opts)
-- set('n', '<A-0>', '<Cmd>BufferLast<CR>', opts)
-- Pin/unpin buffer
-- set('n', '<A-p>', '<Cmd>BufferPin<CR>', opts)
-- Wipeout buffer
--                 :BufferWipeout
-- Close commands
--                 :BufferCloseAllButCurrent
--                 :BufferCloseAllButPinned
--                 :BufferCloseAllButCurrentOrPinned
--                 :BufferCloseBuffersLeft
--                 :BufferCloseBuffersRight
-- Magic buffer-picking mode
set('n', '<A-p>', '<Cmd>BufferPick<CR>', opts)
-- Sort automatically by...
-- set('n', '<Space>bb', '<Cmd>BufferOrderByBufferNumber<CR>', opts)
-- set('n', '<Space>bd', '<Cmd>BufferOrderByDirectory<CR>', opts)
-- set('n', '<Space>bl', '<Cmd>BufferOrderByLanguage<CR>', opts)
-- set('n', '<Space>bw', '<Cmd>BufferOrderByWindowNumber<CR>', opts)

-- Other:
-- :BarbarEnable - enables barbar (enabled by default)
-- :BarbarDisable - very bad command, should never be used

-- Set barbar's options
-- -- Set barbar's options
require 'bufferline'.setup {
	-- Enable/disable animations
	animation = true,

	-- Enable/disable auto-hiding the tab bar when there is a single buffer
	auto_hide = true,

	-- Enable/disable current/total tabpages indicator (top right corner)
	tabpages = false,

	-- Enables/disable clickable tabs
	--  - left-click: go to buffer
	--  - middle-click: delete buffer
	clickable = true,

	-- Excludes buffers from the tabline
	-- exclude_ft = { 'javascript' },
	-- exclude_name = { 'package.json' },

	-- A buffer to this direction will be focused (if it exists) when closing the current buffer.
	-- Valid options are 'left' (the default) and 'right'
	focus_on_close = 'left',

	-- Hide inactive buffers and file extensions. Other options are `alternate`, `current`, and `visible`.
	hide = { extensions = true, inactive = false },

	-- Disable highlighting alternate buffers
	highlight_alternate = false,

	-- Disable highlighting file icons in inactive buffers
	highlight_inactive_file_icons = false,

	-- Enable highlighting visible buffers
	highlight_visible = true,

	icons = {
		-- Configure the base icons on the bufferline.
		buffer_index = false,
		buffer_number = false,
		-- button = '',
		button = '',
		-- Enables / disables diagnostic symbols
		diagnostics = {
			[vim.diagnostic.severity.ERROR] = { enabled = false, icon = '' },
			[vim.diagnostic.severity.WARN] = { enabled = false },
			[vim.diagnostic.severity.INFO] = { enabled = false },
			[vim.diagnostic.severity.HINT] = { enabled = false },
		},
		filetype = {
			-- Sets the icon's highlight group.
			-- If false, will use nvim-web-devicons colors
			custom_colors = false,
			-- Requires `nvim-web-devicons` if `true`
			enabled = false,
		},
		separator = { left = '▎', right = '' },
		-- Configure the icons on the bufferline when modified or pinned.
		-- Supports all the base icon options.
		modified = { button = '●' },
		pinned = { button = '車' },
		-- Configure the icons on the bufferline based on the visibility of a buffer.
		-- Supports all the base icon options, plus `modified` and `pinned`.
		alternate = { filetype = { enabled = false } },
		current = { buffer_index = false },
		inactive = { button = '' },
		-- inactive = { button = '×' },
		visible = { modified = { buffer_number = false } },
	},

	-- If true, new buffers will be inserted at the start/end of the list.
	-- Default is to insert after current buffer.
	insert_at_end = true,
	insert_at_start = false,

	-- Sets the maximum padding width with which to surround each tab
	maximum_padding = 2,

	-- Sets the minimum padding width with which to surround each tab
	minimum_padding = 1,

	-- Sets the maximum buffer name length.
	maximum_length = 30,

	-- If set, the letters for each buffer in buffer-pick mode will be
	-- assigned based on their name. Otherwise or in case all letters are
	-- already assigned, the behavior is to assign letters in order of
	-- usability (see order below)
	semantic_letters = true,

	-- New buffer letters are assigned in this order. This order is
	-- optimal for the qwerty keyboard layout but might need adjustement
	-- for other layouts.
	letters = 'asdfjkl;ghnmxcvbziowerutyqpASDFJKLGHNMXCVBZIOWERUTYQP',

	-- Sets the name of unnamed buffers. By default format is "[Buffer X]"
	-- where X is the buffer number. But only a static string is accepted here.
	no_name_title = nil,
}
