package vn.duytien.tietkiem

import android.service.notification.NotificationListenerService
import android.service.notification.StatusBarNotification
import android.util.Log
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
        val bigText = extras.getCharSequence(android.app.Notification.EXTRA_BIG_TEXT)?.toString()
        val summaryText =
            extras.getCharSequence(android.app.Notification.EXTRA_SUMMARY_TEXT)?.toString()
        val textLines = extras.getCharSequenceArray(android.app.Notification.EXTRA_TEXT_LINES)
            ?.mapNotNull { it?.toString()?.takeIf(String::isNotBlank) }
            ?.joinToString("\n")

        if (
            title.isNullOrBlank() &&
            text.isNullOrBlank() &&
            subText.isNullOrBlank() &&
            bigText.isNullOrBlank() &&
            summaryText.isNullOrBlank() &&
            textLines.isNullOrBlank()
        ) {
            return
        }

        val payload = JSONObject()
            .put("packageName", sbn.packageName)
            .put("title", title)
            .put("body", text)
            .put("subText", subText)
            .put("bigText", bigText)
            .put("summaryText", summaryText)
            .put("textLines", textLines)
            .put("postedAt", Instant.ofEpochMilli(sbn.postTime).toString())

        Log.d(
            "BankNotification",
            "posted package=${sbn.packageName} title=$title text=$text bigText=$bigText lines=$textLines"
        )
        BankNotificationBridge.emit(applicationContext, payload)
    }
}
