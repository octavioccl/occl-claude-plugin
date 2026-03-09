# occl-claude-plugin

Personal Claude Code plugin — skills, sub-agents, commands, hooks, and utility scripts.

---

## Repository Structure

```
occl-claude-plugin/
├── .claude-plugin/
│   └── plugin.json              # Plugin manifest (required by Claude Code)
├── agents/
│   └── investiq/                # InvestIQ project sub-agents
├── commands/                    # Slash command definitions (.md files)
├── hooks/
│   └── hooks.json               # Hook event handlers (create when needed)
├── scripts/                     # Utility scripts (not a Claude plugin component)
│   ├── statusline-command.sh    # Active status line script
│   └── statusline-command-old.sh
└── skills/                      # Agent skills (<name>/SKILL.md structure)
```

> **Important:** Only `plugin.json` goes inside `.claude-plugin/`. All other directories (`agents/`, `skills/`, `commands/`, `hooks/`) must be at the **plugin root**, not inside `.claude-plugin/`.

---

## Installation

### Option 1 — Dev/local mode (no marketplace needed)

Load the plugin for a single session using `--plugin-dir`:

```bash
claude --plugin-dir ~/Github/occl-claude-plugin
```

Load multiple plugins at once:

```bash
claude --plugin-dir ~/Github/occl-claude-plugin --plugin-dir ~/Github/other-plugin
```

### Option 2 — Permanent user-scope install

Once the plugin is published in a marketplace, install it permanently across all projects:

```bash
claude plugin install occl-claude-plugin --scope user
```

### Option 3 — Project-scope install (shared with team via git)

```bash
claude plugin install occl-claude-plugin --scope project
```

This writes to `.claude/settings.json` so anyone who clones the project gets the plugin.

### Scopes explained

| Scope | Settings file | Available |
|---|---|---|
| `user` | `~/.claude/settings.json` | All your projects |
| `project` | `.claude/settings.json` | Everyone on the project |
| `local` | `.claude/settings.local.json` | You only, gitignored |

### Verify the plugin loaded

After starting Claude Code, run:

```bash
/help        # skills should appear namespaced as /occl-claude-plugin:<skill>
/agents      # agents should be listed
```

Or use debug mode to see full plugin load details:

```bash
claude --debug --plugin-dir ~/Github/occl-claude-plugin
```

---

## Plugin Manifest

**`.claude-plugin/plugin.json`** — the file that makes this a Claude Code plugin. Without it, Claude Code treats the directory as a plain folder.

```json
{
  "name": "occl-claude-plugin",
  "version": "1.0.0",
  "description": "...",
  "author": { ... },
  "repository": "https://github.com/octavioccl/occl-claude-plugin"
}
```

**Bump the version in `plugin.json` every time you make changes** — Claude Code uses the version to decide whether to update cached copies. If the version doesn't change, users won't get your updates.

---

## Developing New Features

### Adding a Skill

Skills live in `skills/<name>/SKILL.md`. The folder name becomes the skill name, prefixed with the plugin namespace (e.g., `skills/review/` → `/occl-claude-plugin:review`).

```bash
mkdir -p skills/my-skill
```

```markdown
# skills/my-skill/SKILL.md
---
name: my-skill
description: What this skill does and when Claude should use it automatically.
---

Instructions for Claude when this skill is invoked...
```

**Frontmatter fields:**

| Field | Required | Description |
|---|---|---|
| `name` | Yes | Skill identifier |
| `description` | Yes | Shown in `/help`; also used by Claude to decide when to auto-invoke |
| `disable-model-invocation` | No | Set `true` to prevent Claude from auto-running this skill |

Skills can include supporting files alongside `SKILL.md`:

```
skills/my-skill/
├── SKILL.md
├── reference.md   # optional additional context
└── scripts/       # optional helper scripts
```

Use `$ARGUMENTS` in `SKILL.md` to capture text the user types after the skill name:

```markdown
Process the following input: "$ARGUMENTS"
```

Test it: `/occl-claude-plugin:my-skill some input here`

---

### Adding a Command

Commands are simpler than skills — just a single `.md` file in `commands/`:

```bash
touch commands/my-command.md
```

```markdown
# commands/my-command.md
Do something specific when invoked as /occl-claude-plugin:my-command.
```

Use `commands/` for quick one-off slash commands. Use `skills/` for richer skills that may include supporting files or auto-invocation by Claude.

---

### Adding an Agent

Agents are Markdown files in `agents/`. Group them by project in subdirectories.

```markdown
# agents/my-project/my-agent.md
---
name: my-agent
description: What this agent specialises in and when Claude should invoke it.
model: sonnet
tools: Read, Write, Edit, Glob, Grep, Bash
---

Detailed system prompt...
```

**Key frontmatter fields:**

| Field | Description |
|---|---|
| `name` | Agent identifier (appears in `/agents`) |
| `description` | Used by Claude to decide when to auto-invoke |
| `model` | `opus`, `sonnet`, or `haiku` |
| `tools` | Comma-separated list of allowed tools |
| `memory` | `project` to give agent access to project memory |

---

### Adding a Hook

Hooks respond to Claude Code lifecycle events. All hooks live in `hooks/hooks.json`.

```json
{
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [
          {
            "type": "command",
            "command": "${CLAUDE_PLUGIN_ROOT}/scripts/my-script.sh"
          }
        ]
      }
    ]
  }
}
```

**Always use `${CLAUDE_PLUGIN_ROOT}`** for paths inside hooks — this resolves correctly regardless of where the plugin is installed.

**Make hook scripts executable:**
```bash
chmod +x scripts/my-script.sh
```

**Available events:**

| Event | Fires when |
|---|---|
| `PreToolUse` | Before Claude uses any tool |
| `PostToolUse` | After a tool succeeds |
| `PostToolUseFailure` | After a tool fails |
| `UserPromptSubmit` | User submits a prompt |
| `SessionStart` | Session begins |
| `SessionEnd` | Session ends |
| `Stop` | Claude attempts to stop |
| `SubagentStart` / `SubagentStop` | Subagent lifecycle |
| `PreCompact` | Before history is compacted |
| `TaskCompleted` | A task is marked complete |

**Hook types:** `command` (shell), `prompt` (LLM eval), `agent` (agentic verifier).

---

### Versioning

Bump the version in `.claude-plugin/plugin.json` before pushing any change you want cached users to receive:

```
1.0.0 → 1.0.1   bug fix
1.0.0 → 1.1.0   new skill or agent
1.0.0 → 2.0.0   breaking change
```

---

## Status Line

The `scripts/` directory is not a standard plugin component — it holds utility scripts managed separately.

The active status line is `scripts/statusline-command.sh` (based on [kamranahmedse/claude-statusline](https://github.com/kamranahmedse/claude-statusline) with custom additions).

**Activate it** — ensure `~/.claude/settings.json` contains:

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/statusline-command.sh"
}
```

**Sync repo → home after changes:**
```bash
cp scripts/statusline-command.sh ~/.claude/statusline-command.sh
```

**Sync home → repo to save changes:**
```bash
cp ~/.claude/statusline-command.sh scripts/statusline-command.sh
```

The old status line is kept at `scripts/statusline-command-old.sh` for reference.

---

## Agents Reference

### InvestIQ (`agents/investiq/`)

| Agent | Model | Role |
|---|---|---|
| `team-lead` | opus | Architecture, planning, IC coordination |
| `backend-engineer` | sonnet | FastAPI / Python backend |
| `frontend-engineer` | sonnet | React / TypeScript frontend |
| `ai-data-engineer` | sonnet | LangChain RAG, VaR/Sharpe/Markowitz |
| `ux-designer` | sonnet | Design specs before any FE work |

**Install into a project:**
```bash
cp agents/investiq/*.md /path/to/project/.claude/agents/
```

---

## Troubleshooting

| Symptom | Cause | Fix |
|---|---|---|
| Plugin not loading | Invalid `plugin.json` | Check JSON syntax; run `claude --debug` |
| Skills not appearing | Wrong file location | Must be `skills/<name>/SKILL.md` at plugin root |
| Agents not showing in `/agents` | Wrong directory | Must be `agents/` at plugin root, not inside `.claude-plugin/` |
| Hooks not firing | Script not executable | `chmod +x scripts/your-script.sh` |
| Changes not picked up | Version not bumped | Increment version in `.claude-plugin/plugin.json` |
| Paths broken in hooks | Absolute paths used | Use `${CLAUDE_PLUGIN_ROOT}/...` for all plugin-internal paths |
