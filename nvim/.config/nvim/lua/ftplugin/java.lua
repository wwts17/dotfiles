local jdtls = require "jdtls"

local mason_bin = vim.fn.stdpath "data" .. "/mason/bin/jdtls"
if vim.fn.executable(mason_bin) ~= 1 then
  vim.notify("jdtls not found, run :MasonInstall jdtls", vim.log.levels.WARN)
  return
end

-- Run jdtls on JDK 21 and projects on JDK 17.
local function sdkman_java(major)
  local candidates = vim.fn.glob(vim.fn.expand("$HOME/.sdkman/candidates/java/" .. major .. ".*-tem"), false, true)
  if #candidates == 0 then
    vim.notify("SDKMAN JDK " .. major .. " not found", vim.log.levels.WARN)
    return nil
  end
  return candidates[#candidates]
end

local jdk21 = sdkman_java(21)
local jdk17 = sdkman_java(17)
if not jdk21 or not jdk17 then
  return
end

-- Separate workspaces keep project classpaths isolated.
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "cache" .. "/jdtls-workspaces/" .. project_name

local config = {
  cmd = { mason_bin, "-data", workspace_dir },

  cmd_env = { JAVA_HOME = jdk21 },

  root_dir = vim.fs.dirname(
    vim.fs.find({ "gradlew", "mvnw", "pom.xml", "build.gradle", "build.gradle.kts", ".git" }, {
      upward = true,
    })[1] or vim.fn.expand "%:p:h"
  ),

  settings = {
    java = {
      eclipse = { downloadSources = true },
      maven = { downloadSources = true },
      configuration = {
        updateBuildConfiguration = "interactive",
        runtimes = {
          { name = "JavaSE-17", path = jdk17 },
        },
      },
      implementationsCodeLens = { enabled = true },
      referencesCodeLens = { enabled = true },
      signatureHelp = { enabled = true },
      format = { enabled = true },
      completion = {
        importOrder = { "java", "javax", "com", "org" },
      },
    },
  },

  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)
