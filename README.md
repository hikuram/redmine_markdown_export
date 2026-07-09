# Redmine Markdown Export

A small Redmine plugin that turns the standard issue copy action into an issue Markdown copy action.

On issue detail pages, the visible Redmine `Copy` action keeps the current Redmine theme and localized label, but its click behavior is replaced with `Copy Markdown`. The original issue duplication URL is preserved and added to the action menu as `Duplicate issue`.

The plugin intentionally targets only issue detail pages and does not export issue lists.

## Features

- Issue detail page only
- Reuses the standard Redmine issue `Copy` link instead of adding a custom large button
- Copies one issue as Markdown to the clipboard
- Adds the original issue duplication action to the action menu as `Duplicate issue`
- Markdown output for issue metadata, visible custom fields, description, attachments, and comment notes
- Attachment entries include absolute Markdown links
- Comment change details such as status changes are intentionally omitted
- No database migration
- No external network access

## UI Behavior

On an issue detail page:

```text
Visible action row:
- Copy
```

The visible label remains Redmine's standard localized label, such as `Copy` or `コピー`. Clicking it fetches:

```text
/issues/:id.md
```

and copies the Markdown response to the clipboard.

The original Redmine issue duplication action is moved into the action menu:

```text
Action menu:
- Copy link
- Duplicate issue
- Delete issue
```

`Duplicate issue` is intentionally English-only. The plugin does not override Redmine core translations.

## Compatibility

| Redmine | Status |
|---------|--------|
| 7.0     | Expected, tested manually in one environment |
| 6.0 / 6.1 | Expected |
| 5.0+    | Expected from the original plugin baseline, but not the main target |
| 4.x     | Not supported |

The JavaScript identifies the original issue duplication link by URL shape rather than by visible text, so it is not dependent on the UI language.

## Installation

Copy this plugin into Redmine's `plugins` directory using this directory name:

```text
redmine_markdown_export
```

Example:

```bash
cd /path/to/redmine/plugins
unzip redmine_markdown_export.zip
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

Open an issue detail page and click the standard `Copy` action in the visible action row.

The link text is not changed permanently. During the operation it may briefly show:

```text
Building...
Copied
Copy failed
```

Direct access to `/issues/:id.md` returns the Markdown text response. The plugin does not add a download link and does not handle `/issues.md` issue-list export.

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
4. The injected JavaScript does not access external hosts.
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
4. `hooks.rb` patches the issue detail page action row in the browser:
   - Finds the standard Redmine issue duplication link by URL.
   - Stores its original URL.
   - Replaces its click behavior with Markdown copy.
   - Adds `Duplicate issue` to the action menu using the stored URL.

## Uninstall

```bash
cd /path/to/redmine/plugins
rm -rf redmine_markdown_export
```

Restart Redmine. No database rollback is required.

## License

[MIT](LICENSE)
