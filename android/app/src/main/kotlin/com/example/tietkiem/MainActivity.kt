package vn.duytien.tietkiem

import android.content.ComponentName
import android.content.Intent
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tietkiem/bank_notifications/methods"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "isAccessGranted" -> result.success(hasNotificationAccess())
                "openAccessSettings" -> {
                    startActivity(Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS))
                    result.success(null)
                }
                "consumePendingEvents" -> {
                    result.success(BankNotificationBridge.consumePending(applicationContext))
                }
                else -> result.notImplemented()
            }
        }

        EventChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "tietkiem/bank_notifications/events"
        ).setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
                BankNotificationBridge.eventSink = events
            }

            override fun onCancel(arguments: Any?) {
                BankNotificationBridge.eventSink = null
            }
        })
    }

    private fun hasNotificationAccess(): Boolean {
        val flat = Settings.Secure.getString(
            contentResolver,
            "enabled_notification_listeners"
        ) ?: return false
        val expected = ComponentName(this, BankNotificationListenerService::class.java)
            .flattenToString()
        return flat.split(':').any { it == expected }
    }
}
