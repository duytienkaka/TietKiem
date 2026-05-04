package vn.duytien.tietkiem

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import org.json.JSONObject
import java.time.Instant

class BankNotificationListenerService : NotificationListenerService() {
    override fun onNotificationPosted(sbn: StatusBarNotification) {
        if (sbn.packageName == packageName) {
            return
        }

        val extras = sbn.notification.extras
        val title = extras.getCharSequence(android.app.Notification.EXTRA_TITLE)?.toString()
        val text = extras.getCharSequence(android.app.Notification.EXTRA_TEXT)?.toString()
        val subText = extras.getCharSequence(android.app.Notification.EXTRA_SUB_TEXT)?.toString()

        if (title.isNullOrBlank() && text.isNullOrBlank() && subText.isNullOrBlank()) {
            return
        }

        val payload = JSONObject()
            .put("packageName", sbn.packageName)
            .put("title", title)
            .put("body", text)
            .put("subText", subText)
            .put("postedAt", Instant.ofEpochMilli(sbn.postTime).toString())

        BankNotificationBridge.emit(applicationContext, payload)
    }
}
