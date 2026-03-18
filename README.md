# Redmine Markdown Export

A Redmine plugin that exports issues as Markdown files.

Append `.md` to any issue URL to download it as a Markdown document.

## Features

- **Single issue export** — metadata, description, attachments, and comments
- **Issue list export** — current query/filter results as a Markdown table
- **One-click download** — adds a Markdown button to the "Also available in" area
- **Custom field support** — all visible custom fields included in export

## Compatibility

| Redmine | Status |
|---------|--------|
| 5.0+    | ✅     |
| 4.x     | ❌     |

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/wellbia/redmine_markdown_export.git
```

> **Note**: The directory must be named `redmine_markdown_export`. The plugin will not be recognized under a different name.

Restart Redmine:

```bash
# Standard
bundle exec rails server

# Docker
docker compose restart redmine
```

No database migration required — this plugin does not use any tables.

## Usage

### Append `.md` to the URL

```
GET /issues/123.md     → download issue #123 as Markdown
GET /issues.md         → download issue list as Markdown
```

Query parameter style also works:

```
GET /issues/123?format=md
GET /issues?format=md
```

### Click the button

A `Markdown` link is automatically added to the **"Also available in"** area at the bottom of issue list and detail pages, next to CSV, PDF, and Atom.

## Output Examples

### Single issue (`/issues/123.md`)

```markdown
# #123: Login returns 500 error

| Field | Value |
|---|---|
| **Project** | MyProject |
| **Tracker** | Bug |
| **Status** | New |
| **Priority** | High |
| **Author** | Alice |
| **Assigned to** | Bob |

## Description

POST request on the login page returns a 500 error.
Steps to reproduce: ...

## Attachments

- screenshot.png (245.3 KB) - Alice, 2026-03-18

## Comments

### Bob - 2026-03-18 10:30

Confirmed. Looks like a DB connection pool issue.
```

### Issue list (`/issues.md`)

```markdown
# MyProject - Issues

**Date**: 2026-03-18

| # | Tracker | Subject | Status | Priority | Assigned To | Updated On |
|---|---|---|---|---|---|---|
| 123 | Bug | Login returns 500 error | New | High | Bob | 2026-03-18 |
| 124 | Feature | Dashboard redesign | In Progress | Normal | - | 2026-03-17 |
```

## How It Works

```
plugins/redmine_markdown_export/
├── init.rb                                  # MIME type registration, patch loading
├── app/views/issues/
│   ├── index.md.erb                         # Issue list template
│   └── show.md.erb                          # Issue detail template
└── lib/redmine_markdown_export/
    ├── hooks.rb                             # Markdown button injection
    ├── issues_controller_patch.rb           # .md format request handling
    └── formatting_helper.rb                 # Markdown escape helpers
```

1. `init.rb` registers the `text/markdown` MIME type as `:md`
2. A `before_action` is prepended to `IssuesController` to intercept `.md` format requests
3. Issue data is rendered through ERB templates and sent as a `.md` file via `send_data`
4. A `view_layouts_base_body_bottom` hook injects the Markdown download button into the page

## Uninstall

```bash
cd /path/to/redmine/plugins
rm -rf redmine_markdown_export
```

Restart Redmine. No database rollback required.

## Contributing

1. Fork
2. Create feature branch (`git checkout -b feature/my-feature`)
3. Commit (`git commit -am 'Add my feature'`)
4. Push (`git push origin feature/my-feature`)
5. Pull Request

Bug reports and feature requests are welcome on [Issues](https://github.com/wellbia/redmine_markdown_export/issues).

## License

[MIT](LICENSE)
