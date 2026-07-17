## Simplified Chinese Plugin
[![Jenkins Plugin](https://img.shields.io/jenkins/plugin/v/localization-zh-cn.svg)](https://plugins.jenkins.io/localization-zh-cn)
[![Jenkins Plugin Installs](https://img.shields.io/jenkins/plugin/i/localization-zh-cn.svg?color=blue)](https://plugins.jenkins.io/localization-zh-cn)
[![Gitter](https://badges.gitter.im/jenkinsci/localization-zh-cn-plugin.svg)](https://gitter.im/jenkinsci/localization-zh-cn-plugin)


Simplified Chinese Localization for Jenkins core and plugins.  
See [JEP-216](https://github.com/jenkinsci/jep/blob/master/jep/216/README.adoc) for design details.

## Repository Layout

This repository includes localization resources for both Jenkins core and a subset of plugins, but they are separated by directory:

- `core/src/main/resources/` for Jenkins core
- `cli/src/main/resources/` for Jenkins CLI
- `plugins/<plugin-id>/src/main/resources/` for plugin-specific resources

See [docs/resource-layout.md](docs/resource-layout.md) for the maintenance layout and rules.

## Out of the box

We offer you an out-of-the-box solution. If you're going to install a fresh Jenkins, please [check here](https://github.com/jenkins-zh/docker-zh).

## How-To Guides

Here are some guides about [how to contribute localization](https://www.jenkins.io/doc/developer/internationalization/) for a Jenkins plugin.

[jcli](https://github.com/jenkins-zh/jenkins-cli) could help you upload this plugin into your
Jenkins. The command is `jcli plugin upload`.

## Contribution

If you are interested in localization, please check [Chinese Localization SIG](https://www.jenkins.io/sigs/chinese-localization/) first.

Chinese resource files use UTF-8 without a BOM. Keep Chinese characters readable in source files and do not convert them with `native2ascii`.

Everyone should follow the [translation specification](https://github.com/jenkins-zh/translation-spec/blob/master/specification.md).

## Actions

We use [git-backup-actions](https://github.com/jenkins-zh/git-backup-actions/) to backup this repo into 
[gitee](https://gitee.com/jenkins-zh/localization-zh-cn-plugin).
