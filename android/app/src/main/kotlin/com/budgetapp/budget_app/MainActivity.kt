package com.budgetapp.budget_app

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.Intent
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val securityChannel = "budget_app/security"
    private val deepLinkChannel = "budget_app/deep_link"
    private val widgetChannel = "budget_app/widget"
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
                        // SharedPreferences already written by Flutter (flutter_shared_prefs).
                        // Just trigger a widget refresh.
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

    override fun onNewIntent(intent: Intent) {
        super.onNewIntent(intent)
        intent.data?.toString()?.let { link ->
            if (eventSink != null) eventSink?.success(link)
            else pendingLink = link
        }
    }
}
