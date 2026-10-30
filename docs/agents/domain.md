# Domain Docs

How the engineering skills should consume this repo's domain documentation when exploring the codebase.

## Before exploring, read these

- **`GLOSSARY.md`** at the repo root, or
- **`GLOSSARY-MAP.md`** at the repo root if it exists — it points at one `GLOSSARY.md` per context. Read each one relevant to the topic.
- **`docs/adr/`** — read ADRs that touch the area you're about to work in. In multi-context repos, also check `src/<context>/docs/adr/` for context-scoped decisions.

If any of these files don't exist, proceed silently. Don't flag their absence or suggest creating them upfront; the domain-modeling skill creates them lazily when terms or decisions are resolved.

## File structure

Single-context repo:

```text
/
├── GLOSSARY.md
├── docs/adr/
└── src/
```

Multi-context repo (presence of `GLOSSARY-MAP.md` at root):

```text
/
├── GLOSSARY-MAP.md
├── docs/adr/                     # system-wide decisions
└── src/
    ├── ordering/
    │   ├── GLOSSARY.md
    │   └── docs/adr/
    └── billing/
        ├── GLOSSARY.md
        └── docs/adr/
```

## Use the glossary's vocabulary

Use terms as defined in `GLOSSARY.md` when writing issue titles, proposals, hypotheses, or test names. If a needed concept is missing, note the gap rather than inventing terminology.

## Flag ADR conflicts

If an output contradicts an existing ADR, surface it explicitly rather than silently overriding it.
