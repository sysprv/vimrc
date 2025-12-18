local M = {}

function M.stln_buf_mod_status()
  local m = ''
  if vim.bo.modified then m = m .. '+' end
  if not vim.bo.modifiable then m = m .. '-' end
  if m == '' then m = '_' end
  if vim.bo.readonly then m = m .. '.ro' end
  if vim.bo.buftype == '' and vim.o.swapfile and (not vim.bo.swapfile or vim.o.updatecount == 0) then
    m = m .. '.!swf'
  end
  return m
end

function M.stln_text_width()
  return vim.o.paste and '!P' or tostring(vim.bo.textwidth)
end

function M.stln_fenc()
  local fenc = vim.bo.fileencoding
  if fenc ~= '' and fenc ~= 'utf-8' then
    return 'fenc:' .. fenc
  end
  return ''
end

function M.stln_ff()
  if vim.bo.fileformat ~= 'unix' then
    return 'ff:' .. vim.bo.fileformat
  end
  return ''
end

function M.stln_indentation()
  if vim.bo.tabstop == 8 and vim.bo.expandtab and vim.bo.shiftwidth == 4 and vim.bo.softtabstop == 4 then
    -- my default
    return ''
  end
  if vim.bo.tabstop == 8 and not vim.bo.expandtab and vim.bo.shiftwidth == 0 and vim.bo.softtabstop == 0 then
    -- classic tab mode
    return ''
  end
  local l = {}
  if vim.bo.tabstop ~= 8 then
    table.insert(l, 'ts:' .. vim.bo.tabstop)
  end
  -- moniker: soft/hard
  table.insert(l, vim.bo.expandtab and 'so' or 'ha')
  if vim.bo.shiftwidth == vim.bo.softtabstop then
    table.insert(l, 'sf:' .. vim.bo.shiftwidth)
  else
    table.insert(l, 'sw:' .. vim.bo.shiftwidth)
    table.insert(l, 'sts:' .. vim.bo.softtabstop)
  end

  if #l == 2 and l[1] == 'so' and l[2] == 'sf:2' and vim.bo.filetype == 'json' then
    -- my defaults for json
    return ''
  end
  if #l == 0 then
    return ''
  end

  return '{' .. table.concat(l, ',') .. '}'
end

function fmtpos()
    local pos = vim.fn.getpos('.')
    return string.format('<%3d:%-2d>', pos[2], pos[3])
end

function M.stln_buf_flags()
  local l = {}

  if vim.bo.buftype == 'terminal' then
    table.insert(l, 'TERM')
    if vim.fn.mode() == 'n' then
        table.insert(l, fmtpos())
    end
  else
    table.insert(l, M.stln_buf_mod_status())
    if vim.wo.previewwindow then
      table.insert(l, 'PRV')
    end
    table.insert(l, fmtpos())

    local ind = M.stln_indentation()
    if ind ~= '' then table.insert(l, ind) end

    local tw = M.stln_text_width()
    if tw ~= '0' then table.insert(l, tw) end

    local fenc = M.stln_fenc()
    if fenc ~= '' then table.insert(l, fenc) end

    local ff = M.stln_ff()
    if ff ~= '' then table.insert(l, ff) end

    if vim.bo.formatoptions:find('a') then
      table.insert(l, 'fo-a')
    end
  end

  l = vim.tbl_filter(function(v) return v ~= '' and v ~= 0 end, l)
  return '[' .. table.concat(l, '/') .. ']'
end


_G.UserStLnBufFlags = M.stln_buf_flags
