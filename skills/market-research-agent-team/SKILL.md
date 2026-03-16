---
name: market-research-agent-team
description: Orchestrates a 4-agent parallel research team to deeply investigate a product idea or app improvement opportunity. Each agent researches a specific dimension (Business & Product, Financial & Cost, Technical Architecture, Devil's Advocate) in parallel using deep web research, then an Opus lead synthesizes findings into a structured markdown report. Use when the user wants to research a new app idea, validate a product concept, or explore improvements to an existing app. Triggers on requests like "research this idea", "investigate this feature", "do a deep dive on [topic]", "analyze this opportunity", or when a JIRA/Linear ticket number is provided for research. For existing app improvements, the user may share code or a codebase path for agents to review before researching.
---

# Market Research Agent Team

## Overview

Spawn 4 parallel research agents + 1 Opus lead synthesizer. Agents do deep web research across their domain, then the lead aggregates findings into a single markdown report.

## Inputs

Gather these before starting (ask if missing):

- **Topic / idea**: The app concept or improvement to research (or a JIRA/Linear ticket number to fetch context from)
- **App context** *(existing app improvements only)*: codebase path or pasted code — share with Agent 3 (and optionally Agent 1) before researching
- **Output path**: Where to write the final report (e.g., `docs/research/<topic-slug>.md`)
- **Team name**: Short slug for the agent team (e.g., `kan-75-research`)

## Agent Team Composition

Spawn all 4 agents **in parallel**, then run synthesis after all complete.

---

### Agent 1 — Business & Product

**Focus**: Market opportunity, user needs, competitive landscape, go-to-market.

**Research tasks**:
- Who are the target users and what pain points does this solve?
- Who are the existing competitors? How do they position, price, and differentiate?
- What is the market size (TAM/SAM/SOM) and growth trajectory?
- What are the key product risks and adoption barriers?
- Are there existing integrations, partnerships, or ecosystems to leverage?
- What features do users most request in competing products (App Store reviews, Reddit, Twitter)?

**Sources to search**: Product reviews, competitor websites, App Store/Play Store listings, Product Hunt, Reddit communities, founder interviews, industry reports.

---

### Agent 2 — Financial & Cost

**Focus**: Revenue models, pricing benchmarks, cost structure, unit economics.

**Research tasks**:
- What monetization models work in this space (subscription, usage-based, freemium, one-time)?
- What do competitors charge? What price points do users accept?
- What are the key cost drivers (infrastructure, compliance, third-party APIs, support)?
- What is the estimated CAC, LTV, and payback period for comparable products?
- Are there licensing, regulatory, or compliance costs?
- What funding or grants are available if applicable?

**Sources to search**: SaaS pricing pages, financial blogs, startup benchmarks, API pricing pages, regulatory guidance, indie hacker revenue reports.

---

### Agent 3 — Technical Architecture

**Focus**: Implementation feasibility, tech stack options, integrations, build vs. buy decisions.

**Research tasks**:
- What are the leading technical approaches to implement this?
- Which third-party APIs, SDKs, or platforms are available and how do they compare?
- What are the integration complexity, rate limits, and reliability concerns?
- What are the security, compliance, or data residency requirements?
- What is a realistic MVP scope from a technical standpoint?
- *(If existing code provided)*: Review code first — identify what needs to change, what can be reused, and what gaps exist.

**Sources to search**: Official API/SDK docs, GitHub repos, developer forums, Stack Overflow, tech blogs, architecture case studies.

---

### Agent 4 — Devil's Advocate

**Focus**: Risks, failure modes, counterarguments, reasons this could fail.

**Research tasks**:
- What are the strongest reasons NOT to build this?
- What have similar products tried and failed? Why?
- Are there regulatory, legal, or ethical landmines?
- What assumptions does this idea rely on that could be wrong?
- What would need to be true for this to succeed, and how likely is each condition?

**Sources to search**: Startup post-mortems, negative reviews, regulatory news, skeptical analyses, failed competitor case studies.

---

## Lead Synthesis (Opus)

After all 4 agents complete, synthesize their outputs into the final report. Use `model: opus` for this step.

### Report structure

```markdown
# [Topic] — Research Report

> Generated: [date] | Team: [team-name]

## Executive Summary
2–3 paragraph synthesis of key findings and recommendation.

## Go / No-Go Recommendation
Clear recommendation with confidence level and key conditions.

## Agent Findings

### Business & Product
[Key insights from Agent 1]

### Financial & Cost
[Pricing and cost data from Agent 2]

### Technical Architecture
[Implementation path from Agent 3]

### Devil's Advocate
[Key risks and failure modes from Agent 4]

## Key Risks & Mitigations
Top risks with mitigation strategies.

## Recommended Next Steps
Prioritized action items to validate or build.

## Sources
URLs referenced by agents.
```

## Execution Flow

```
1. Collect inputs (topic, context, output path, team name)
2. Spawn Agents 1–4 in parallel
   └─ If existing app: share code/path with Agent 3 (and Agent 1 if relevant)
3. Wait for all 4 agents to complete
4. Lead (Opus) synthesizes → writes final report to output path
5. Notify user with report path and Go/No-Go recommendation
```
