
local is_vscode = vim.g.vscode == 1  -- or simply: if vim.g.vscode then

vim.cmd('source ~/.vim/rc/common/keymap.vim')

if is_vscode then
  vim.keymap.set('n', '<C-f>', function()
    vim.fn.VSCodeNotify('editorScroll', { to = 'down', by = 'page', revealCursor = true })
  end, { silent = true })

  vim.keymap.set('n', '<C-b>', function()
    vim.fn.VSCodeNotify('editorScroll', { to = 'up',   by = 'page', revealCursor = true })
  end, { silent = true })
end

-- if is_vscode then
--   local function page_move(dir)
--     local so   = vim.wo.scrolloff            -- window ごとの scrolloff
--     local h    = vim.api.nvim_win_get_height(0)
--     local step = math.max(1, h - 2*so - 1)   -- 画面高さ - 上下scrolloff - 1
--     local key  = (dir == 'down') and 'j' or 'k'
-- 
--     -- Vim 側でカーソルを動かす（scrolloff が効く）
--     vim.cmd(('normal! %d%s'):format(step, key))
-- 
--     -- VSCode 側に「この行を見せて」と伝える（中央寄せはしない）
--     -- local cur = vim.api.nvim_win_get_cursor(0)[1] - 1  -- 0-based
--     -- local at  = (dir == 'down') and 'bottom' or 'top'
--     -- vim.fn.VSCodeNotify('revealLine', { lineNumber = cur, at = at })
--     -- vim.fn.VSCodeNotify('revealLine', { lineNumber = cur, at = 'center' })
--   end
-- 
--   vim.keymap.set('n', '<C-f>', function() page_move('down') end, { silent = true })
--   vim.keymap.set('n', '<C-b>', function() page_move('up')   end, { silent = true })
-- end
