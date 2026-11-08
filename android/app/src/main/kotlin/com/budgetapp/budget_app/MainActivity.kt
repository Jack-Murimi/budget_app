package com.budgetapp.budget_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.database.Cursor
import android.net.Uri
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val securityChannel = "budget_app/security"
    private val deepLinkChannel = "budget_app/deep_link"
    private val widgetChannel = "budget_app/widget"
    private val smsChannel = "budget_app/sms"
    private var pendingLink: String? = null
    private var eventSink: EventChannel.EventSink? = null

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        // Security: FLAG_SECURE
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, securityChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setSecureFlag" -> {
                        val enable = call.argument<Boolean>("enable") ?: false
                        if (enable) window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        else window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // Widget data: Dart writes spend+balance, we refresh all widget instances
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, widgetChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "updateWidgetData" -> {
                        val manager = AppWidgetManager.getInstance(context)
                        val ids = manager.getAppWidgetIds(
                            ComponentName(context, BudgetWidget::class.java)
                        )
                        for (id in ids) {
                            BudgetWidget.updateWidget(context, manager, id)
                        }
                        result.success(null)
                    }
                    else -> result.notImplemented()
                }
            }

        // SMS inbox reader
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "readMpesaSms" -> {
                        try {
                            result.success(readMpesaSmsMessages())
                        } catch (e: Exception) {
                            result.error("SMS_ERROR", e.message, null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }

        // Deep links: stream initial + new intents to Dart
        EventChannel(flutterEngine.dartExecutor.binaryMessenger, deepLinkChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, sink: EventChannel.EventSink?) {
                    eventSink = sink
                    pendingLink?.let { sink?.success(it); pendingLink = null }
                }
                override fun onCancel(arguments: Any?) { eventSink = null }
            })

        // Capture launch intent
        intent?.data?.toString()?.let { pendingLink = it }
    }

    private fun readMpesaSmsMessages(): List<Map<String, Any>> {
        val messages = mutableListOf<Map<String, Any>>()
        val uri = Uri.parse("content://sms/inbox")
        val projection = arrayOf("_id", "address", "body", "date")
        // Filter: address contains MPESA (case-insensitive) or body contains Confirmed
        val selection = "address LIKE ? OR body LIKE ?"
        val selectionArgs = arrayOf("%MPESA%", "%Confirmed%")
        val cursor: Cursor? = context.contentResolver.query(
            uri, projection, selection, selectionArgs, "date DESC"
        )
        cursor?.use { c ->
            val idIdx = c.getColumnIndex("_id")
            val addrIdx = c.getColumnIndex("address")
            val bodyIdx = c.getColumnIndex("body")
            val dateIdx = c.getColumnIndex("date")
            while (c.moveToNext()) {
                messages.add(mapOf(
                    "id" to c.getString(idIdx),
                    "address" to (c.getString(addrIdx) ?: ""),
                    "body" to (c.getString(bodyIdx) ?: ""),
                    "date" to c.getLong(dateIdx),
                ))
            }
        }
        return messages
    }

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.data?.toString()?.let { link ->
            if (eventSink != null) eventSink?.success(link)
            else pendingLink = link
        }
    }
}
