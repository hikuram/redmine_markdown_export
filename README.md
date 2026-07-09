# Redmine Markdown Export

A small Redmine plugin that adds a `Markdown Copy` button to issue detail pages.

The button fetches the current issue as Markdown and copies the result to the clipboard. The plugin intentionally targets only issue detail pages and does not export issue lists.

## Features

- Issue detail page only
- One-click Markdown copy
- Markdown output for issue metadata, visible custom fields, description, attachments, and comment notes
- Attachment entries include absolute Markdown links
- Comment change details such as status changes are intentionally omitted
- No database migration
- No external network access

## Compatibility

| Redmine | Status |
|---------|--------|
| 5.0+    | Expected |
| 4.x     | Not supported |

## Installation

```bash
cd /path/to/redmine/plugins
git clone https://github.com/wellbia/redmine_markdown_export.git
```

If you install this customized version manually, keep the plugin directory name as follows:

```text
redmine_markdown_export
```

Restart Redmine:

```bash
# Standard
bundle exec rails server

# Docker
docker compose restart redmine
```

No database migration is required.

## Usage

Open an issue detail page and click `Markdown Copy`.

Internally, the button fetches:

```text
/issues/:id.md
```

and copies the response text to the clipboard.

Direct access to `/issues/:id.md` returns the Markdown text response, but the plugin does not add a download link and does not handle `/issues.md` issue-list export.

## Output Shape

```markdown
# #123 Example issue

## Issue

- **Project**: Example project
- **Tracker**: Task
- **Status**: New
- **Priority**: Normal
- **Author**: Alice
- **Assigned to**: Bob
- **URL**: https://redmine.example.com/issues/123

## Description

Issue description text.

## Attachments

- [example.pdf](https://redmine.example.com/attachments/download/1/example.pdf) (120.0 KB) - Alice, 2026-07-09 09:00

## Comments

### 2026-07-09 09:30 Bob

Comment text.
```

## Security Checks Before Production Use

Verify the following in your actual Redmine environment:

1. A user without issue visibility cannot access `/issues/:id.md`.
2. Private notes are not included for users who cannot see them.
3. Attachment links still require the normal Redmine permission checks.
4. The copy button JavaScript does not access external hosts.
5. The organization accepts raw Markdown text, including any raw HTML already present in issue descriptions or comments.

## How It Works

```text
plugins/redmine_markdown_export/
|-- init.rb
|-- app/views/issues/
|   `-- show.md.erb
`-- lib/redmine_markdown_export/
    |-- formatting_helper.rb
    |-- hooks.rb
    `-- issues_controller_patch.rb
```

1. `init.rb` registers `text/markdown` as the `:md` format.
2. `issues_controller_patch.rb` handles `.md` only for `IssuesController#show`.
3. `show.md.erb` renders one issue as a single Markdown document.
4. `hooks.rb` injects the `Markdown Copy` button into issue detail pages.

## Uninstall

```bash
cd /path/to/redmine/plugins
rm -rf redmine_markdown_export
```

Restart Redmine. No database rollback is required.

## License

[MIT](LICENSE)
