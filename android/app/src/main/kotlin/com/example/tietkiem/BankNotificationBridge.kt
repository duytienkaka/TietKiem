package vn.duytien.tietkiem

import android.content.Context
import android.os.Handler
import android.os.Looper
import io.flutter.plugin.common.EventChannel
import org.json.JSONArray
import org.json.JSONObject

object BankNotificationBridge {
    private const val PREFS_NAME = "bank_notification_bridge"
    private const val PENDING_KEY = "pending_events"
    private const val MAX_PENDING = 40

    private val mainHandler = Handler(Looper.getMainLooper())
    var eventSink: EventChannel.EventSink? = null

    fun emit(context: Context, payload: JSONObject) {
        enqueue(context, payload)
        val sink = eventSink ?: return
        val map = payloadToMap(payload)
        mainHandler.post {
            sink.success(map)
        }
    }

    fun consumePending(context: Context): List<Map<String, Any?>> {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(PENDING_KEY, "[]") ?: "[]"
        val array = JSONArray(raw)
        prefs.edit().remove(PENDING_KEY).apply()

        val items = mutableListOf<Map<String, Any?>>()
        for (index in 0 until array.length()) {
            val value = array.optJSONObject(index) ?: continue
            items.add(payloadToMap(value))
        }
        return items
    }

    private fun enqueue(context: Context, payload: JSONObject) {
        val prefs = context.getSharedPreferences(PREFS_NAME, Context.MODE_PRIVATE)
        val raw = prefs.getString(PENDING_KEY, "[]") ?: "[]"
        val array = JSONArray(raw)
        array.put(payload)
        while (array.length() > MAX_PENDING) {
            array.remove(0)
        }
        prefs.edit().putString(PENDING_KEY, array.toString()).apply()
    }

    private fun payloadToMap(payload: JSONObject): Map<String, Any?> {
        return mapOf(
            "packageName" to payload.optString("packageName"),
            "title" to payload.optString("title").ifBlank { null },
            "body" to payload.optString("body").ifBlank { null },
            "subText" to payload.optString("subText").ifBlank { null },
            "postedAt" to payload.optString("postedAt"),
        )
    }
}
