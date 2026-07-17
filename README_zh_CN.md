# 简体中文插件
[![Jenkins Plugin](https://img.shields.io/jenkins/plugin/v/localization-zh-cn.svg)](https://plugins.jenkins.io/localization-zh-cn)
[![Jenkins Plugin Installs](https://img.shields.io/jenkins/plugin/i/localization-zh-cn.svg?color=blue)](https://plugins.jenkins.io/localization-zh-cn)
[![Gitter](https://badges.gitter.im/jenkinsci/localization-zh-cn-plugin.svg)](https://gitter.im/jenkinsci/localization-zh-cn-plugin)


本插件包括 Jenkins 核心以及插件的中文本地化。查看 [JEP-216](https://github.com/jenkinsci/jep/blob/master/jep/216/README.adoc) 了解设计细节。

# 仓库结构

这个仓库里确实同时包含了 Jenkins 本体和一部分插件的汉化，但不是无边界混放，而是按目录拆开的：

- `core/src/main/resources/`：Jenkins core
- `cli/src/main/resources/`：Jenkins CLI
- `plugins/<plugin-id>/src/main/resources/`：各插件自己的汉化资源

后续维护时，优先依赖目录结构区分归属，而不是在每个资源文件里重复写注释。

更完整的维护说明见 [docs/resource-layout.md](docs/resource-layout.md)。

# 入门教程

这里有一些关于 [如何为 Jenkins 插件贡献本地化](https://www.jenkins.io/doc/developer/internationalization/) 的教程。

[jcli](https://github.com/jenkins-zh/jenkins-cli) 可以帮助你快速地把插件上传到你的 Jenkins 中。命令为：`jcli plugin upload`。

# 贡献

如果，你对本地化感兴趣，请首先查看 [中文本地化 SIG](https://www.jenkins.io/sigs/chinese-localization/)。

中文资源文件统一使用 UTF-8（无 BOM），直接保留可读的中文字符，不要使用 `native2ascii` 转换。

注意，每位贡献者都应该遵循[翻译规范](specification.md)。

# Actions

我们使用 [git-backup-actions](https://github.com/jenkins-zh/git-backup-actions/) 来备份当前仓库到 
[gitee](https://gitee.com/jenkins-zh/localization-zh-cn-plugin).
