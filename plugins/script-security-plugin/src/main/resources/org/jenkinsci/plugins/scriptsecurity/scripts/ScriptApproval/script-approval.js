function hideScript(hash) {
    document.getElementById('ps-' + hash).remove();
}
function approveScript(hash) {
    mgr.approveScript(hash);
    hideScript(hash);
}
function denyScript(hash) {
    mgr.denyScript(hash);
    hideScript(hash);
}
function hideSignature(hash) {
    document.getElementById('s-' + hash).style.display = 'none';
}
function updateApprovedSignatures(r) {
    var both = r.responseObject();
    document.getElementById('approvedSignatures').value = both[0].join('\n');
    document.getElementById('aclApprovedSignatures').value = both[1].join('\n');
    if (document.getElementById('dangerousApprovedSignatures')) {
        document.getElementById('dangerousApprovedSignatures').value = both[2].join('\n');
    }
}
function approveSignature(signature, hash) {
    mgr.approveSignature(signature, function(r) {
        updateApprovedSignatures(r);
    });
    hideSignature(hash);
}
function aclApproveSignature(signature, hash) {
    mgr.aclApproveSignature(signature, function(r) {
        updateApprovedSignatures(r);
    });
    hideSignature(hash);
}
function denySignature(signature, hash) {
    mgr.denySignature(signature);
    hideSignature(hash);
}
function clearApprovedSignatures() {
    mgr.clearApprovedSignatures(function(r) {
        updateApprovedSignatures(r);
    });
}
function clearDangerousApprovedSignatures() {
    mgr.clearDangerousApprovedSignatures(function(r) {
        updateApprovedSignatures(r);
    });
}

function renderPendingClasspathEntries(pendingClasspathEntries) {
    if (pendingClasspathEntries.length == 0) {
        document.getElementById('pendingClasspathEntries-none').style.display = '';
        Array.from(document.getElementById('pendingClasspathEntries').children).forEach(function(e){e.remove()});
        document.getElementById('pendingClasspathEntries').style.display = 'none';
    } else {
        document.getElementById('pendingClasspathEntries-none').style.display = 'none';
        Array.from(document.getElementById('pendingClasspathEntries').children).forEach(function(e){e.remove()});
        pendingClasspathEntries.forEach(function(e) {
            var block = document.createElement('p');
            block.setAttribute('id', 'pcp-' + e.hash);
            var approveButton = document.createElement('button');
            approveButton.setAttribute('class', 'approve');
            approveButton.setAttribute('hash', e.hash);
            approveButton.textContent = '批准';
            approveButton.addEventListener('click', function() {
                approveClasspathEntry(this.getAttribute('hash'));
            });
            var denyButton = document.createElement('button');
            denyButton.setAttribute('class', 'deny');
            denyButton.setAttribute('hash', e.hash);
            denyButton.textContent = '拒绝';
            denyButton.addEventListener('click', function() {
                denyClasspathEntry(this.getAttribute('hash'));
            });
            block.appendChild(approveButton);
            block.appendChild(denyButton);
            var code = document.createElement('code');
            code.setAttribute('title', e.hash);
            code.textContent = e.path;
            block.appendChild(code);

            document.getElementById('pendingClasspathEntries').appendChild(block);
        });
        document.getElementById('pendingClasspathEntries').style.display = '';
    }
}

function renderApprovedClasspathEntries(approvedClasspathEntries) {
    if (approvedClasspathEntries.length == 0) {
        document.getElementById('approvedClasspathEntries-none').style.display = '';
        Array.from(document.getElementById('approvedClasspathEntries').children).forEach(function(e){e.remove()});
        document.getElementById('approvedClasspathEntries').style.display = 'none';
        document.getElementById('approvedClasspathEntries-clear').style.display = 'none';
    } else {
        document.getElementById('approvedClasspathEntries-none').style.display = 'none';
        Array.from(document.getElementById('approvedClasspathEntries').children).forEach(function(e){e.remove()});
        approvedClasspathEntries.forEach(function(e) {
            var block = document.createElement('p');
            block.setAttribute('id', 'acp-' + e.hash);
            var deleteButton = document.createElement('button');
            deleteButton.setAttribute('class', 'delete');
            deleteButton.setAttribute('hash', e.hash);
            deleteButton.textContent = '删除';
            deleteButton.addEventListener('click', function() {
                if (confirm('确定删除这个已批准的类路径条目吗？任何正在使用它的现有脚本都需要重新运行，并重新审批该条目。')) {
                    denyApprovedClasspathEntry(this.getAttribute('hash'));
                }
            });
            block.appendChild(deleteButton);
            var code = document.createElement('code');
            code.setAttribute('title', e.hash);
            code.textContent = e.path;
            block.appendChild(code);

            document.getElementById('approvedClasspathEntries').appendChild(block);
        });
        document.getElementById('approvedClasspathEntries').style.display = '';
        document.getElementById('approvedClasspathEntries-clear').style.display = '';
    }
}

function renderClasspaths(r) {
    renderPendingClasspathEntries(r.responseObject()[0]);
    renderApprovedClasspathEntries(r.responseObject()[1]);
}

function approveClasspathEntry(hash) {
    mgr.approveClasspathEntry(hash, function(r) {
        renderClasspaths(r);
    });
}
function denyClasspathEntry(hash) {
    mgr.denyClasspathEntry(hash, function(r) {
        renderClasspaths(r);
    });
}
function denyApprovedClasspathEntry(hash) {
    mgr.denyApprovedClasspathEntry(hash, function(r) {
        renderClasspaths(r);
    });
}
function clearApprovedClasspathEntries() {
    mgr.clearApprovedClasspathEntries(function(r) {
        renderClasspaths(r);
    });
}

document.addEventListener('DOMContentLoaded', function() {
    mgr.getClasspathRenderInfo(function(r) {
        renderClasspaths(r);
    });

    const approveScriptButtons = document.querySelectorAll('.ps-context button.approve');
    approveScriptButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            approveScript(button.dataset.hash);
        });
    });

    const denyScriptButtons = document.querySelectorAll('.ps-context button.deny');
    denyScriptButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            denyScript(button.dataset.hash);
        });
    });

    const deprecatedApprovedScriptsClearButton = document.querySelector('#deprecated-approvedScripts-clear button');
    if (deprecatedApprovedScriptsClearButton) {
        deprecatedApprovedScriptsClearButton.addEventListener('click', function () {
            if (confirm('确定删除所有已弃用的审批记录吗？所有现有脚本都需要重新入队并重新审批。')) {
                mgr.clearDeprecatedApprovedScripts();
                document.getElementById('deprecated-approvedScripts-clear').style.display = 'none';
            }
        });
    }

    const approvedScriptsClearButton = document.querySelector('#approvedScripts-clear button');
    approvedScriptsClearButton.addEventListener('click', function () {
        if (confirm('确定删除所有审批记录吗？所有现有脚本都需要重新入队并重新审批。')) {
            mgr.clearApprovedScripts();
        }
    });

    const approveSignatureButtons = document.querySelectorAll('.s-context button.approve');
    approveSignatureButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            approveSignature(button.dataset.signature, button.dataset.hash);
        });
    });

    const aclApproveSignatureButtons = document.querySelectorAll('.s-context button.acl-approve');
    aclApproveSignatureButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            aclApproveSignature(button.dataset.signature, button.dataset.hash);
        });
    });

    const denySignatureButtons = document.querySelectorAll('.s-context button.deny');
    denySignatureButtons.forEach(function (button) {
        button.addEventListener('click', function () {
            denySignature(button.dataset.signature, button.dataset.hash);
        });
    });

    const approvedSignaturesClearButton = document.querySelector('#approvedSignatures-clear button');
    approvedSignaturesClearButton.addEventListener('click', function () {
        if (confirm('确定删除所有审批记录吗？所有现有脚本都需要重新运行，并重新审批签名。')) {
            clearApprovedSignatures();
        }
    });

    const dangerousApprovedSignaturesClearButton = document.querySelector('#dangerousApprovedSignatures-clear button');
    if (dangerousApprovedSignaturesClearButton) {
        dangerousApprovedSignaturesClearButton.addEventListener('click', function () {
            clearDangerousApprovedSignatures();
        });
    }

    const deprecatedApprovedClasspathsClearButton = document.querySelector('#deprecated-approvedClasspaths-clear-btn button');
    if (deprecatedApprovedClasspathsClearButton) {
        deprecatedApprovedClasspathsClearButton.addEventListener('click', function () {
            if (confirm('该操作会安排到后台线程执行。你可以在系统日志中跟踪进度。')) {
                mgr.convertDeprecatedApprovedClasspathEntries();
                document.getElementById('deprecated-approvedClasspaths-clear-btn').style.display = 'none';
                document.getElementById('deprecated-approvedClasspaths-clear-spinner').style.display = '';
            }
        });
    }

    const approvedClasspathEntriesClearButton = document.querySelector('#approvedClasspathEntries-clear button');
    approvedClasspathEntriesClearButton.addEventListener('click', function () {
        if (confirm('确定删除所有审批记录吗？所有使用类路径的现有脚本都需要重新运行，并重新审批相关条目。')) {
            clearApprovedClasspathEntries();
        }
    });
});
