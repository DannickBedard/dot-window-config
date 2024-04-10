-- Pull in the wezterm API
local wezterm = require 'wezterm'

-- This will hold the configuration.
local config = wezterm.config_builder()

local workspaces = {
  window="window",
  ubuntu="ubuntu",
  work="work",
  mac="mac",
}

local settings = {
  workspace = workspaces.work, -- À changer selon l'ordinateur utilisé
  workspaceProject = {
    work = {
      project1 = {
        path = "/viridem",
        projectName = "Viridem",
      },
      project2 = {
        path = "/viridem/api",
        projectName = "Viridem-api",
      }
    },
    window = {}, -- À faire
    ubuntu = {}, -- À faire
    mac = {}, -- À faire
  }
}

config.default_prog = { 'C:\\Windows\\System32\\WindowsPowerShell\\v1.0\\powershell.exe' }
--config.default_prog = { 'pwsh.exe' }

config.font = wezterm.font '0xProto Nerd Font'
config.color_scheme = 'OneHalfDark'
config.window_close_confirmation = 'NeverPrompt'


local act = wezterm.action

wezterm.on('update-right-status', function(window, pane)
  window:set_right_status(window:active_workspace())
end)

local lunchWorkSpace = function(window,pane,sessionName, path)
  window:perform_action(
    act.SwitchToWorkspace {
      name = sessionName,
      spawn = {
        cwd = path,
        args = { 'nvim', '.' },
      },
    },
    pane
  )

  window:perform_action(
    act.SplitHorizontal { domain = 'CurrentPaneDomain' },
    pane
  )
  window:perform_action(
    act.AdjustPaneSize { 'Right', 15 },
    pane
  )
  window:perform_action(
    act.SpawnTab 'CurrentPaneDomain',
    pane
  )
  window:perform_action(
    act.ActivatePaneByIndex(0),
    pane
  )
end

local getWorkspaceProject = function ()
   -- Check if settings.workspace exists in workspaces table
  if workspaces[settings.workspace] then
    -- Get the corresponding workspace table from settings.workspaceProject
    local workspaceTable = settings.workspaceProject[settings.workspace]
    -- Return the projects
    return workspaceTable
  else
    -- If workspace is not found, return nil
    return nil
  end
end

local lunchWorkSpaceByProject = function(window, pane, project)
  local projects = getWorkspaceProject()
  if projects then
    lunchWorkSpace(window, pane, projects[project].projectName,projects[project].path)
  else
    window:perform_action(
      act.SwitchToWorkspace {
        name = 'default',
      },
      pane
    )
  end
end

wezterm.on('lunchWorkSpace1', function(window, pane)
  lunchWorkSpaceByProject(window,pane, "project1");
end)
wezterm.on('lunchWorkSpace2', function(window, pane)
  lunchWorkSpaceByProject(window,pane, "project2");
end)

config.keys = {
  -- Switch to the default workspace
  -- Create a new workspace with a random name and switch to it
  { key = 'i', mods = 'CTRL|SHIFT', action = act.SwitchToWorkspace },
  -- Show the launcher in fuzzy selection mode and have it list all workspaces
  -- and allow activating one.
  {
    key = '9',
    mods = 'ALT',
    action = act.ShowLauncherArgs {
      flags = 'FUZZY|WORKSPACES',
    },
  },
  {
    key = '0',
    mods = 'ALT',
    action = act.SwitchToWorkspace {
      name = 'default',
    },
  },
  {
    key = '1',
    mods = 'ALT',
    action = act.EmitEvent 'lunchWorkSpace1'
  },
  {
    key = '2',
    mods = 'ALT',
    action = act.EmitEvent 'lunchWorkSpace2'
  },
  {
    key = 'W',
    mods = 'CTRL|SHIFT',
    action = act.PromptInputLine {
      description = wezterm.format {
        { Attribute = { Intensity = 'Bold' } },
        { Foreground = { AnsiColor = 'Fuchsia' } },
        { Text = 'Enter name for new workspace' },
      },
      action = wezterm.action_callback(function(window, pane, line)
        -- line will be `nil` if they hit escape without entering anything
        -- An empty string if they just hit enter
        -- Or the actual line of text they wrote
        if line then
          window:perform_action(
            act.SwitchToWorkspace {
              name = line,
            },
            pane
          )
        end
      end),
    },
  },
}

return config
