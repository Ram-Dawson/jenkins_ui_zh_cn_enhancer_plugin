# Localization Resource Layout

This repository contains Simplified Chinese localization resources for Jenkins core and a subset of plugins.

The resources are intentionally kept in a single plugin repository, but they are split by upstream ownership and path so that future maintenance stays traceable.

## Directory layout

### Jenkins core

Core resources live under:

- `core/src/main/resources/hudson/`
- `core/src/main/resources/jenkins/`
- `core/src/main/resources/lib/`

These paths mirror the resource paths from Jenkins core.

### Jenkins CLI module

CLI resources live under:

- `cli/src/main/resources/`

These paths mirror the resource paths from the Jenkins CLI module.

### Plugin-specific resources

Plugin resources live under:

- `plugins/<plugin-id>/src/main/resources/`

Examples:

- `plugins/credentials-plugin/src/main/resources/`
- `plugins/script-security-plugin/src/main/resources/`

Each plugin keeps its own subtree so that translations can be reviewed, compared, and updated independently.

## Maintenance rules

### 1. Preserve upstream-relative paths

When adding or updating a translation, keep the same relative path as the upstream resource.

This makes it easier to:

- trace a page back to its source repository
- compare local changes with upstream English resources
- copy or review updates in batches

### 2. Use directory structure before adding comments

Do not add repetitive comments to every translation file just to explain whether it belongs to core or a plugin.

The directory path already answers that:

- `core/...` means Jenkins core
- `cli/...` means Jenkins CLI
- `plugins/<plugin-id>/...` means that plugin

Comments are only useful when a file uses a less obvious route, such as a same-path Jelly or JavaScript override.

### 3. Treat special same-path overrides as explicit exceptions

Most translations should stay in:

- `*_zh_CN.properties`
- `*_zh_CN.html`

If a page contains direct English text in Jelly, or a browser-side script creates user-visible English text dynamically, and it cannot be cleanly handled by standard page resources, place a same-path override in the matching subtree.

Examples:

- `core/src/main/resources/hudson/model/UsageStatistics/help-usageStatisticsCollected.jelly`
- `core/src/main/resources/hudson/model/View/_api.jelly`
- `plugins/credentials-plugin/src/main/resources/lib/credentials/select/select.js`

These files are special-case view-level or script-level localization and should be kept rare and deliberate.

### 4. Keep scanning rules separate from runtime files

Workflow notes, scan rules, and case classification belong in documentation, not inline resource comments.

Use documentation for:

- case1 / case2 / case3 rules
- scan heuristics
- maintenance conventions
- progress tracking

Use resource files only for localized content.

## Practical lookup guide

When you find untranslated text in Jenkins UI:

1. Decide whether it belongs to core or a plugin.
2. Go to the matching subtree in this repository.
3. Check whether it is a standard page resource (`*_zh_CN.properties` / `*_zh_CN.html`).
4. If not, check whether it is a special Jelly override case.
5. Keep the final file in the same upstream-relative location.

This structure is meant to keep “mixed in one repo” from becoming “mixed together without boundaries”.
