package io.jenkins.plugins.gitlabserverconfig.servers.GitLabServer

import io.jenkins.plugins.gitlabserverconfig.servers.GitLabServer
import lib.CredentialsTagLib
import lib.FormTagLib
import org.apache.commons.lang3.RandomStringUtils;

def f = namespace(FormTagLib)
def c = namespace(CredentialsTagLib)

f.entry(title: _("Display Name"), field: "name", "description": "服务的唯一名称") {
    f.textbox(default: String.format("gitlab-%s", RandomStringUtils.randomNumeric(GitLabServer.SHORT_NAME_LENGTH)))
}

f.entry(title: _("Server URL"), field: "serverUrl", "description": "GitLab 服务器的 URL") {
    f.textbox(default: GitLabServer.GITLAB_SERVER_URL, checkMethod: 'post')
}

f.entry(title: _("Credentials"), field: "credentialsId", "description": "用于访问 GitLab API 的个人访问令牌") {
    c.select(context: app)
}

f.entry(title: _("Web Hook"), field: "manageWebHooks", "description": "是否要在 Jenkins 服务器上自动管理 GitLab Web Hook？") {
    f.checkbox(title: _("Manage Web Hooks"))
}

f.entry(title: _("System Hook"), field: "manageSystemHooks", "description": "是否要在 Jenkins 服务器上自动管理 GitLab System Hook？") {
    f.checkbox(title: _("Manage System Hooks"))
}

f.entry(title: _("Secret Token"), field: "webhookSecretCredentialsId", "description": "在 GitLab 服务器上设置 Hook URL 时使用的密钥令牌") {
    c.select(context: app)
}

f.entry(title: _("Root URL for hooks"), field: "hooksRootUrl", "description": "Hook URL 使用的 Jenkins 根 URL（若不同于公开 Jenkins 根 URL）") {
    f.textbox()
}

f.advanced() {
    f.entry(title: _("Immediate Web Hook trigger"), field: "immediateHookTrigger", "description": "收到 GitLab Web Hook 后立即触发构建") {
        f.checkbox(title: _("Immediate Web Hook trigger"))
    }
    f.entry(title: _("Web Hook trigger delay"), field: "hookTriggerDelay", "description": "GitLab Web Hook 构建触发使用的延迟秒数（默认 GitLab 缓存超时）") {
        f.textbox()
    }
}

f.validateButton(
    title: _("Test connection"),
    progress: _("Testing.."),
    method: "testConnection",
    with: "serverUrl,credentialsId"
)
