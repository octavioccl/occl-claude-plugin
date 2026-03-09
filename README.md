# occl-claude-plugin

Personal Claude Code configuration — skills, sub-agents, commands, hooks, and scripts.

## Structure

```
occl-claude-plugin/
├── agents/          # Sub-agent definitions (copy to .claude/agents/ in target project)
│   └── investiq/    # InvestIQ project agents
├── commands/        # Slash command definitions
├── hooks/           # Claude Code hook scripts
├── scripts/         # Utility scripts
│   ├── statusline-command.sh      # Active status line (kamranahmedse-based + customisations)
│   └── statusline-command-old.sh  # Previous status line (for reference)
└── skills/          # Skill definitions
```

## Status Line

The active status line script is `scripts/statusline-command.sh`.

To activate, ensure `~/.claude/settings.json` contains:

```json
"statusLine": {
  "type": "command",
  "command": "bash ~/.claude/statusline-command.sh"
}
```

To switch to the old one, change the command to `bash ~/.claude/statusline-command-old.sh`.

**Sync script to home:**
```bash
cp scripts/statusline-command.sh ~/.claude/statusline-command.sh
```

## Agents

Agents are project-scoped. Copy the desired agent files into your project's `.claude/agents/` directory.

**InvestIQ agents:**
```bash
cp agents/investiq/*.md /path/to/InvestIQ/.claude/agents/
```

| Agent | Model | Role |
|---|---|---|
| `team-lead` | opus | Architecture, planning, IC coordination |
| `backend-engineer` | sonnet | FastAPI / Python backend |
| `frontend-engineer` | sonnet | React / TypeScript frontend |
| `ai-data-engineer` | sonnet | LangChain RAG, VaR/Sharpe/Markowitz |
| `ux-designer` | sonnet | Design specs before FE work |

## Skills

Copy skills to `~/.claude/skills/` (global) or `.claude/skills/` (project-scoped).

## Hooks

Hook scripts live in `hooks/`. Register them in `~/.claude/settings.json` under the `hooks` key.

## Commands

Slash command definitions live in `commands/`. Register them in `~/.claude/settings.json` under the `commands` key.
