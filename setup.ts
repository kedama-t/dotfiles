import { defineCommand, runMain } from "citty";
import { homedir } from "node:os";
import { existsSync } from "node:fs";
import { cp, mkdir, readFile, rm, symlink } from "node:fs/promises";
import { dirname, join } from "node:path";

type OsType = "macos" | "debian" | "rhel" | "linux";
type PkgManager = "brew" | "apt" | "dnf" | "yum";

type ToolContext = {
  os: OsType;
  pkgManager?: PkgManager;
  dryRun: boolean;
  yes: boolean;
};

type Tool = {
  id: string;
  name: string;
  getInstalledVersion: () => Promise<string | null>;
  getLatestVersion: () => Promise<string | null>;
  install: (ctx: ToolContext) => Promise<boolean>;
};

const scriptDir = import.meta.dir;
const dotfilesDir = scriptDir;
const home = homedir();

const color = {
  green: (s: string) => `\x1b[32m${s}\x1b[0m`,
  yellow: (s: string) => `\x1b[33m${s}\x1b[0m`,
  red: (s: string) => `\x1b[31m${s}\x1b[0m`,
  cyan: (s: string) => `\x1b[36m${s}\x1b[0m`,
};

function info(msg: string): void {
  console.log(`${color.cyan("[INFO]")} ${msg}`);
}

function warn(msg: string): void {
  console.log(`${color.yellow("[WARN]")} ${msg}`);
}

function ok(msg: string): void {
  console.log(`${color.green("[OK]")} ${msg}`);
}

function fail(msg: string): void {
  console.log(`${color.red("[ERR]")} ${msg}`);
}

function runShell(cmd: string): { success: boolean; stdout: string; stderr: string; code: number } {
  const result = Bun.spawnSync({
    cmd: ["/bin/bash", "-lc", cmd],
    stdout: "pipe",
    stderr: "pipe",
  });

  return {
    success: result.exitCode === 0,
    stdout: result.stdout.toString().trim(),
    stderr: result.stderr.toString().trim(),
    code: result.exitCode,
  };
}

function commandExists(command: string): boolean {
  return runShell(`command -v ${command}`).success;
}

function parseFirstVersion(text: string): string | null {
  const m = text.match(/(\d+\.\d+\.\d+)/) || text.match(/(\d+\.\d+)/);
  return m?.[1] ?? null;
}

function normalizeVersion(version: string): string {
  return version.replace(/^v/i, "").trim();
}

function compareVersions(a: string, b: string): number {
  const aParts = normalizeVersion(a).split(/[^0-9]+/).filter(Boolean).map(Number);
  const bParts = normalizeVersion(b).split(/[^0-9]+/).filter(Boolean).map(Number);
  const len = Math.max(aParts.length, bParts.length);

  for (let i = 0; i < len; i += 1) {
    const x = aParts[i] ?? 0;
    const y = bParts[i] ?? 0;
    if (x > y) return 1;
    if (x < y) return -1;
  }

  return 0;
}

async function fetchGithubLatestTag(owner: string, repo: string): Promise<string | null> {
  try {
    const res = await fetch(`https://api.github.com/repos/${owner}/${repo}/releases/latest`, {
      headers: { Accept: "application/vnd.github+json" },
    });
    if (!res.ok) return null;
    const json = (await res.json()) as { tag_name?: string };
    return json.tag_name ? normalizeVersion(json.tag_name) : null;
  } catch {
    return null;
  }
}

async function fetchNpmLatestVersion(pkg: string): Promise<string | null> {
  try {
    const encoded = pkg.replace("/", "%2F");
    const res = await fetch(`https://registry.npmjs.org/${encoded}/latest`);
    if (!res.ok) return null;
    const json = (await res.json()) as { version?: string };
    return json.version ?? null;
  } catch {
    return null;
  }
}

async function getGlobalPackageVersion(pkg: string): Promise<string | null> {
  const roots: string[] = [
    join(home, ".bun", "install", "global", "node_modules"),
    "/usr/local/lib/node_modules",
    "/opt/homebrew/lib/node_modules",
  ];

  if (commandExists("npm")) {
    const npmRoot = runShell("npm root -g");
    if (npmRoot.success && npmRoot.stdout) roots.unshift(npmRoot.stdout);
  }

  for (const root of roots) {
    const pkgJson = join(root, pkg, "package.json");
    if (!existsSync(pkgJson)) continue;
    try {
      const raw = await readFile(pkgJson, "utf-8");
      const json = JSON.parse(raw) as { version?: string };
      if (json.version) return json.version;
    } catch {
      // ignore and continue
    }
  }

  return null;
}

async function detectOsAsync(): Promise<OsType> {
  if (process.platform === "darwin") return "macos";
  if (process.platform !== "linux") return "linux";

  try {
    const raw = await Bun.file("/etc/os-release").text();
    const idLine = raw
      .split("\n")
      .find((line) => line.startsWith("ID="))
      ?.replace("ID=", "")
      .replace(/"/g, "")
      .trim();

    if (!idLine) return "linux";
    if (["ubuntu", "debian"].includes(idLine)) return "debian";
    if (["centos", "rhel", "fedora", "rocky", "almalinux"].includes(idLine)) return "rhel";

    return "linux";
  } catch {
    return "linux";
  }
}

function detectPackageManager(os: OsType): PkgManager | undefined {
  if (os === "macos") return "brew";
  if (os === "debian") return "apt";
  if (os === "rhel") {
    if (commandExists("dnf")) return "dnf";
    if (commandExists("yum")) return "yum";
  }
  return undefined;
}

async function askYesNo(question: string, defaultYes: boolean, yesFlag: boolean): Promise<boolean> {
  if (yesFlag) return true;

  const hint = defaultYes ? "[Y/n]" : "[y/N]";
  while (true) {
    const answer = prompt(`${question} ${hint} `)?.trim().toLowerCase() ?? "";
    if (!answer) return defaultYes;
    if (["y", "yes"].includes(answer)) return true;
    if (["n", "no"].includes(answer)) return false;
    console.log("Please answer with y or n.");
  }
}

async function runInstallStep(name: string, command: string, dryRun: boolean): Promise<boolean> {
  if (dryRun) {
    info(`[dry-run] ${name}: ${command}`);
    return true;
  }

  info(`${name}: ${command}`);
  const result = Bun.spawnSync({
    cmd: ["/bin/bash", "-lc", command],
    stdout: "inherit",
    stderr: "inherit",
    stdin: "inherit",
  });

  return result.exitCode === 0;
}

function getNeovimInstallCommand(ctx: ToolContext): string | null {
  const { pkgManager } = ctx;
  if (!pkgManager) return null;
  if (pkgManager === "brew") return "brew install neovim";
  if (pkgManager === "apt") {
    return "sudo apt update && sudo apt install -y software-properties-common && sudo add-apt-repository ppa:neovim-ppa/unstable -y && sudo apt update && sudo apt install -y neovim";
  }
  if (pkgManager === "dnf") return "sudo dnf install -y neovim";
  if (pkgManager === "yum") return "sudo yum install -y neovim";
  return null;
}

function getEzaInstallCommand(ctx: ToolContext): string | null {
  const { pkgManager } = ctx;
  if (!pkgManager) return null;
  if (pkgManager === "brew") return "brew install eza";
  if (pkgManager === "apt") return "sudo apt update && sudo apt install -y eza";
  if (pkgManager === "dnf") return "sudo dnf install -y eza";
  if (pkgManager === "yum") return "sudo yum install -y eza";
  return null;
}

async function ensureParentDir(path: string): Promise<void> {
  await mkdir(dirname(path), { recursive: true });
}

async function createSymlink(source: string, target: string, force: boolean, dryRun: boolean): Promise<void> {
  if (!existsSync(source)) {
    warn(`Skipped symlink (source missing): ${source}`);
    return;
  }

  if (dryRun) {
    info(`[dry-run] link ${target} -> ${source}`);
    return;
  }

  await ensureParentDir(target);

  if (existsSync(target)) {
    const ls = runShell(`if [ -L '${target}' ]; then readlink '${target}'; fi`);
    if (ls.success && ls.stdout === source) {
      info(`Symlink already exists: ${target}`);
      return;
    }

    if (!force) {
      warn(`Target exists, skipped (use --force): ${target}`);
      return;
    }

    const backupPath = `${target}.backup`;
    if (!existsSync(backupPath)) {
      await runInstallStep("backup", `cp -R '${target}' '${backupPath}'`, false);
    }
    await rm(target, { recursive: true, force: true });
  }

  await symlink(source, target);
  ok(`Linked: ${target}`);
}

async function copyPathWithPrompt(source: string, target: string, dryRun: boolean, yesFlag: boolean): Promise<void> {
  if (!existsSync(source)) {
    warn(`Skipped copy (source missing): ${source}`);
    return;
  }

  if (dryRun) {
    info(`[dry-run] copy ${source} -> ${target}`);
    return;
  }

  await ensureParentDir(target);

  if (existsSync(target)) {
    const shouldOverwrite = await askYesNo(`Target exists. Overwrite with copy? ${target}`, false, yesFlag);
    if (!shouldOverwrite) {
      warn(`Copy skipped by user: ${target}`);
      return;
    }
    await rm(target, { recursive: true, force: true });
  }

  await cp(source, target, { recursive: true });
  ok(`Copied: ${target}`);
}

async function createDotfileSymlinks(force: boolean, dryRun: boolean, yesFlag: boolean): Promise<void> {
  info("Config setup");

  await createSymlink(join(dotfilesDir, "nvim"), join(home, ".config", "nvim"), force, dryRun);
  await createSymlink(join(dotfilesDir, "zsh", ".zshrc"), join(home, ".zshrc"), force, dryRun);

  await copyPathWithPrompt(join(dotfilesDir, "claude"), join(home, ".claude"), dryRun, yesFlag);
  await copyPathWithPrompt(join(dotfilesDir, "codex"), join(home, ".codex"), dryRun, yesFlag);

  if (commandExists("nvim")) {
    await runInstallStep("lazy.nvim sync", "nvim --headless '+Lazy! sync' +qa", dryRun);
  }
}

async function createTools(ctx: ToolContext): Promise<Tool[]> {
  return [
    {
      id: "neovim",
      name: "Neovim (0.11+)",
      getInstalledVersion: async () => {
        if (!commandExists("nvim")) return null;
        const out = runShell("nvim --version | head -n1");
        return parseFirstVersion(out.stdout);
      },
      getLatestVersion: async () => fetchGithubLatestTag("neovim", "neovim"),
      install: async (innerCtx) => {
        const cmd = getNeovimInstallCommand(innerCtx);
        if (!cmd) {
          fail("No supported package manager found for Neovim install.");
          return false;
        }
        return runInstallStep("Install Neovim", cmd, innerCtx.dryRun);
      },
    },
    {
      id: "uv",
      name: "uv (Python package/project manager)",
      getInstalledVersion: async () => {
        if (!commandExists("uv")) return null;
        const out = runShell("uv --version");
        return parseFirstVersion(out.stdout);
      },
      getLatestVersion: async () => fetchGithubLatestTag("astral-sh", "uv"),
      install: async (innerCtx) => runInstallStep("Install uv", "curl -LsSf https://astral.sh/uv/install.sh | sh", innerCtx.dryRun),
    },
    {
      id: "claude",
      name: "Claude Code (Anthropic CLI)",
      getInstalledVersion: async () => {
        const pkgVer = await getGlobalPackageVersion("@anthropic-ai/claude-code");
        if (pkgVer) return pkgVer;
        if (!commandExists("claude")) return null;
        return parseFirstVersion(runShell("claude --version").stdout);
      },
      getLatestVersion: async () => fetchNpmLatestVersion("@anthropic-ai/claude-code"),
      install: async (innerCtx) => runInstallStep("Install Claude Code", "bun add -g @anthropic-ai/claude-code", innerCtx.dryRun),
    },
    {
      id: "codex",
      name: "Codex CLI",
      getInstalledVersion: async () => {
        const pkgVer = await getGlobalPackageVersion("@openai/codex");
        if (pkgVer) return pkgVer;
        if (!commandExists("codex")) return null;
        return parseFirstVersion(runShell("codex --version").stdout);
      },
      getLatestVersion: async () => fetchNpmLatestVersion("@openai/codex"),
      install: async (innerCtx) => runInstallStep("Install Codex CLI", "bun add -g @openai/codex", innerCtx.dryRun),
    },
    {
      id: "gemini",
      name: "Gemini CLI",
      getInstalledVersion: async () => {
        const pkgVer = await getGlobalPackageVersion("@google/gemini-cli");
        if (pkgVer) return pkgVer;
        if (!commandExists("gemini")) return null;
        return parseFirstVersion(runShell("gemini --version").stdout);
      },
      getLatestVersion: async () => fetchNpmLatestVersion("@google/gemini-cli"),
      install: async (innerCtx) => runInstallStep("Install Gemini CLI", "bun add -g @google/gemini-cli", innerCtx.dryRun),
    },
    {
      id: "kami",
      name: "@kami-pkm/kami",
      getInstalledVersion: async () => getGlobalPackageVersion("@kami-pkm/kami"),
      getLatestVersion: async () => fetchNpmLatestVersion("@kami-pkm/kami"),
      install: async (innerCtx) => runInstallStep("Install @kami-pkm/kami", "bun add -g @kami-pkm/kami", innerCtx.dryRun),
    },
    {
      id: "eza",
      name: "eza",
      getInstalledVersion: async () => {
        if (!commandExists("eza")) return null;
        const out = runShell("eza --version");
        return parseFirstVersion(out.stdout);
      },
      getLatestVersion: async () => fetchGithubLatestTag("eza-community", "eza"),
      install: async (innerCtx) => {
        const cmd = getEzaInstallCommand(innerCtx);
        if (!cmd) {
          fail("No supported package manager found for eza install.");
          return false;
        }
        return runInstallStep("Install eza", cmd, innerCtx.dryRun);
      },
    },
  ];
}

const main = defineCommand({
  meta: {
    name: "setup",
    description: "Interactive installer for dotfiles tools (except Bun bootstrap)",
  },
  args: {
    dryRun: {
      type: "boolean",
      description: "Show commands without executing",
      default: false,
    },
    force: {
      type: "boolean",
      description: "Force overwrite for symlink targets (nvim/zshrc)",
      default: false,
    },
    yes: {
      type: "boolean",
      description: "Install without interactive confirmations",
      default: false,
    },
  },
  async run({ args }) {
    const os = await detectOsAsync();
    const pkgManager = detectPackageManager(os);

    info(`OS: ${os}`);
    info(`Package manager: ${pkgManager ?? "not-detected"}`);

    if (!commandExists("bun")) {
      fail("Bun is not installed. Run ./setup.sh first.");
      process.exit(1);
    }

    ok(`Bun: ${runShell("bun --version").stdout}`);

    const ctx: ToolContext = {
      os,
      pkgManager,
      dryRun: Boolean(args.dryRun),
      yes: Boolean(args.yes),
    };

    const tools = await createTools(ctx);
    const results: Array<{ name: string; status: "installed" | "skipped" | "failed" }> = [];

    for (const tool of tools) {
      console.log("\n--------------------------------------------------");
      info(tool.name);

      const installedVersion = await tool.getInstalledVersion();
      const latestVersion = await tool.getLatestVersion();

      if (installedVersion) {
        info(`Installed: ${installedVersion}`);
      } else {
        info("Installed: not found");
      }

      if (latestVersion) {
        info(`Latest:    ${latestVersion}`);
      } else {
        warn("Latest:    unknown (network/source unavailable)");
      }

      if (installedVersion && latestVersion && compareVersions(installedVersion, latestVersion) >= 0) {
        ok("Already latest. Skipping interaction.");
        results.push({ name: tool.name, status: "skipped" });
        continue;
      }

      const question = installedVersion
        ? `${tool.name} is not latest. Update/install now?`
        : `Install ${tool.name}?`;

      const shouldInstall = await askYesNo(question, true, ctx.yes);
      if (!shouldInstall) {
        warn(`Skipped by user: ${tool.name}`);
        results.push({ name: tool.name, status: "skipped" });
        continue;
      }

      const success = await tool.install(ctx);
      if (!success) {
        fail(`Install failed: ${tool.name}`);
        results.push({ name: tool.name, status: "failed" });
        continue;
      }

      const afterVersion = await tool.getInstalledVersion();
      if (afterVersion) {
        ok(`${tool.name} -> ${afterVersion}`);
      } else {
        ok(`${tool.name} install step finished`);
      }
      results.push({ name: tool.name, status: "installed" });
    }

    console.log("\n--------------------------------------------------");
    info("Config setup");
    await createDotfileSymlinks(Boolean(args.force), Boolean(args.dryRun), Boolean(args.yes));

    console.log("\n==================================================");
    info("Summary");
    for (const r of results) {
      if (r.status === "installed") ok(`${r.name}: installed/updated`);
      if (r.status === "skipped") warn(`${r.name}: skipped`);
      if (r.status === "failed") fail(`${r.name}: failed`);
    }

    const failedCount = results.filter((r) => r.status === "failed").length;
    if (failedCount > 0) {
      process.exit(1);
    }
  },
});

void runMain(main);
