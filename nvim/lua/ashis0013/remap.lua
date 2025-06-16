local opts = { noremap = true, silent = true }

local utils = require('ashis0013.utils')

local term_opts = { silent = true }
local keymap = vim.api.nvim_set_keymap

keymap("", "<Space>", "<Nop>", opts)
vim.g.mapleader = " "
vim.g.maplocalleader = " "

keymap("n", "<leader>og", ":ObsidianFollowLink<CR>", opts)
keymap("n", "<leader>e", ":NvimTreeToggle<CR>", opts)
keymap("n", "<Tab>", ":bnext<CR>", opts)
keymap("n", "<S-Tab>", ":bprevious<CR>", opts)
keymap("n", "<M-q>", ":bdelete<CR>", opts)

keymap("n", "<C-h>", ":TmuxNavigateLeft", opts)
keymap("n", "<C-j>", ":TmuxNavigateDown", opts)
keymap("n", "<C-k>", ":TmuxNavigateUp", opts)
keymap("n", "<C-l>", ":TmuxNavigateRight", opts)

keymap("n", "<C-h>", "<C-w>h", opts)
keymap("n", "<C-j>", "<C-w>j", opts)
keymap("n", "<C-k>", "<C-w>k", opts)
keymap("n", "<C-l>", "<C-w>l", opts)

keymap("v", "<", "<gv", opts)
keymap("v", ">", ">gv", opts)
keymap("v", "p", '"_dP', opts)

-- Prime's config
vim.keymap.set("v", "J", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "K", ":m '<-2<CR>gv=gv")

vim.keymap.set("n", "J", "mzJ`z")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<leader>s", [[:%s/\<<C-r><C-w>\>/<C-r><C-w>/gI<Left><Left><Left>]])
vim.keymap.set("n", "<leader>fmt", vim.lsp.buf.format)

function get_test_runner(test_name, debug)
  if debug then
    return 'mvn test -Dmaven.surefire.debug -Dtest="' .. test_name .. '"' 
  end
  return 'mvn test -Dtest="' .. test_name .. '"' 
end

function run_java_test_method(debug)
  local method_name = utils.get_current_full_method_name("\\#")
  vim.cmd('term ' .. get_test_runner(method_name, debug))
end

function run_java_test_class(debug)
  local class_name = utils.get_current_full_class_name()
  vim.cmd("new")
  vim.cmd("term " .. get_test_runner(class_name, debug))
  vim.cmd("startinsert")
end

vim.keymap.set("n", "<leader>tm", function() run_java_test_method() end)
vim.keymap.set("n", "<leader>TM", function() run_java_test_method(true) end)
vim.keymap.set("n", "<leader>tc", function() run_java_test_class() end)
vim.keymap.set("n", "<leader>TC", function() run_java_test_class(true) end)
vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "gd", function() vim.lsp.buf.definition() end, opts)
vim.keymap.set("n", "gi", function() vim.lsp.buf.implementation() end, opts)
vim.keymap.set("n", "gr", function() vim.lsp.buf.references() end, opts)
vim.keymap.set("n", "K", function() vim.lsp.buf.hover() end, opts)
vim.keymap.set("n", "<leader>vws", function() vim.lsp.buf.workspace_symbol() end, opts)
vim.keymap.set("n", "<leader>vd", function() vim.diagnostic.open_float() end, opts)
vim.keymap.set("n", "[d", function() vim.diagnostic.goto_next() end, opts)
vim.keymap.set("n", "]d", function() vim.diagnostic.goto_prev() end, opts)
vim.keymap.set("n", "<leader>ca", function() vim.lsp.buf.code_action() end, opts)
vim.keymap.set("n", "<leader>rr", function() vim.lsp.buf.references() end, opts)
vim.keymap.set("n", "<leader>rn", function() vim.lsp.buf.rename() end, opts)
vim.keymap.set("i", "<C-h>", function() vim.lsp.buf.signature_help() end, opts)


local function get_spring_boot_runner(build_tool, profile, debug, debug_port)
  debug_port = debug_port or "5005" -- Default debug port

  local debug_param = ""
  if debug then
    if build_tool == "maven" then
      debug_param = ' -Dspring-boot.run.jvmArguments="-Xdebug -Xrunjdwp:transport=dt_socket,server=y,suspend=y,address=' .. debug_port .. '" '
    elseif build_tool == "gradle" then
      debug_param = ' --args="--spring.profiles.active=' .. (profile or "") .. ' -agentlib:jdwp=transport=dt_socket,server=y,suspend=y,address=' .. debug_port .. '"'
    end
  end

  local profile_param = ""
  if profile and build_tool == "maven" then
    profile_param = " -Dspring-boot.run.profiles=" .. profile .. " "
  end

  if build_tool == "maven" then
    return 'mvn spring-boot:run' .. profile_param .. debug_param
  elseif build_tool == "gradle" then
    local profile_arg = profile and '--args="--spring.profiles.active=' .. profile .. '"' or ""
    if debug then
      return './gradlew bootRun ' .. debug_param
    else
      return './gradlew bootRun ' .. profile_arg
    end
  else
    error("Unsupported build tool. Use 'maven' or 'gradle'.")
  end
end

local function run_command_in_buffer(cmd)
  vim.cmd("new")
  vim.fn.termopen(cmd)
  vim.cmd("startinsert")
end
--
-- Run Maven Spring Boot application
vim.api.nvim_create_user_command("RunMaven", function(opts)
  local cmd = get_spring_boot_runner("maven", opts.args, false)
  run_command_in_buffer(cmd)
end, { nargs = "?" })

-- Run Gradle Spring Boot application
vim.api.nvim_create_user_command("RunGradle", function(opts)
  local cmd = get_spring_boot_runner("gradle", opts.args, false)
  run_command_in_buffer(cmd)
end, { nargs = "?" })

-- Debug Maven Spring Boot application
vim.api.nvim_create_user_command("DebugMaven", function(opts)
  local cmd = get_spring_boot_runner("maven", opts.args, true)
  run_command_in_buffer(cmd)
end, { nargs = "?" })

-- Debug Gradle Spring Boot application
vim.api.nvim_create_user_command("DebugGradle", function(opts)
  local cmd = get_spring_boot_runner("gradle", opts.args, true)
  run_command_in_buffer(cmd)
end, { nargs = "?" })

function attach_to_debug()
  local dap = require('dap')
  dap.configurations.java = {
    {
      type = 'java';
      request = 'attach';
      name = "Attach to the process";
      hostName = 'localhost';
      port = '5005';
    },
  }
  dap.continue()
end 

function show_dap_centered_scopes()
  local widgets = require'dap.ui.widgets'
  widgets.centered_float(widgets.scopes)
end

vim.keymap.set('n', '<leader>ds', ':lua show_dap_centered_scopes()<CR>')
vim.keymap.set('n', '<leader>da', ':lua attach_to_debug()<CR>')
vim.keymap.set('n', '<leader>dc', ':lua require"dap".continue()<CR>')
vim.keymap.set('n', '<leader>so', ':lua require"dap".step_over()<CR>')
vim.keymap.set('n', '<leader>si', ':lua require"dap".step_into()<CR>')
vim.keymap.set('n', '<S-F8>', ':lua require"dap".step_out()<CR>')
vim.keymap.set('n', '<leader>b', ':lua require"dap".toggle_breakpoint()<CR>')
vim.keymap.set('n', '<leader>B', ':lua require"dap".set_breakpoint(vim.fn.input("Condition: "))<CR>')
vim.keymap.set('n', '<leader>bl', ':lua require"dap".set_breakpoint(nil, nil, vim.fn.input("Log: "))<CR>')
vim.keymap.set('n', '<leader>dr', ':lua require"dap".repl.open()<CR>')
