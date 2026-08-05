# Toolchain Standards

1. **Node.js Ecosystem:**
   - Node versions managed via `fnm`.
   - Packages installed and scripts executed via `pnpm`.
   - Do NOT use `npm`, `yarn`, or `nvm`.

2. **Java Ecosystem:**
   - JDK and Maven versions managed via `SDKMAN!`.
   - Builds executed via `mvn`.
   - Do NOT use Homebrew for JDK installations.

3. **Python Ecosystem:**
   - Packages and virtual environments managed via `pixi`.
   - Global tools installed via `pixi global install`.
   - Do NOT use `pip`, `conda`, or standard `venv`.
