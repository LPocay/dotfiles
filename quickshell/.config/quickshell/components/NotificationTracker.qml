import Quickshell
import QtQuick

Scope {
    id: root
    required property var notification
    required property var manager
    Connections {
        target: root.notification
        function onClosed() { root.manager.closed(root.notification); }
        function onSummaryChanged() { update.restart(); }
        function onBodyChanged() { update.restart(); }
        function onAppNameChanged() { update.restart(); }
        function onAppIconChanged() { update.restart(); }
        function onImageChanged() { update.restart(); }
        function onUrgencyChanged() { update.restart(); }
        function onActionsChanged() { update.restart(); }
        function onExpireTimeoutChanged() { update.restart(); }
        function onHintsChanged() { update.restart(); }
        function onTransientChanged() { update.restart(); }
        function onHasInlineReplyChanged() { update.restart(); }
        function onInlineReplyPlaceholderChanged() { update.restart(); }
    }
    Timer { id: update; interval: 0; onTriggered: root.manager.update(root.notification) }
}
