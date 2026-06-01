-- Triggered when opening a .java file (Neovim ftplugin mechanism).
-- nvim-jdtls manages the jdtls process lifecycle and per-project workspace isolation.

local jdtls = require "jdtls"

-- Locate jdtls binary installed by Mason
local mason_bin = vim.fn.stdpath "data" .. "/mason/bin/jdtls"
if vim.fn.executable(mason_bin) ~= 1 then
  vim.notify("jdtls not found, run :MasonInstall jdtls", vim.log.levels.WARN)
  return
end

-- jdtls itself (the language server JVM) requires Java 21+; our shell default
-- is Java 17. Run jdtls on 21 via JAVA_HOME below, but keep compiling projects
-- with 17 via the JavaSE-17 runtime entry. Update these paths if the SDKs change.
local jdk21 = vim.fn.expand "$HOME/.sdkman/candidates/java/21.0.11-tem"
local jdk17 = vim.fn.expand "$HOME/.sdkman/candidates/java/17.0.19-tem"

-- One workspace per project under ~/.cache/nvim/jdtls-workspaces/<project>
-- avoids classpath collisions and keeps project dirs clean.
local project_name = vim.fn.fnamemodify(vim.fn.getcwd(), ":p:h:t")
local workspace_dir = vim.fn.stdpath "cache" .. "/jdtls-workspaces/" .. project_name

local config = {
  cmd = { mason_bin, "-data", workspace_dir },

  -- Mason's jdtls launcher resolves its JVM from JAVA_HOME; point it at JDK 21.
  -- This only affects the jdtls process, not the shell's default java.
  cmd_env = { JAVA_HOME = jdk21 },

  -- Walk up for project root markers; fall back to current file's dir.
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
        -- jdtls runs on JDK 21 (above), but compile/analyze projects with 17.
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

  -- Enable extensions (refactor, code generation, etc.)
  init_options = {
    bundles = {},
  },
}

jdtls.start_or_attach(config)
