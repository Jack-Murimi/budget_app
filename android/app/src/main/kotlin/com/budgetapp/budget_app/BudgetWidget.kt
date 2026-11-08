package com.budgetapp.budget_app

import android.app.PendingIntent
import android.appwidget.AppWidgetManager
import android.appwidget.AppWidgetProvider
import android.content.Context
import android.content.Intent
import android.widget.RemoteViews

class BudgetWidget : AppWidgetProvider() {

    override fun onUpdate(
        context: Context,
        appWidgetManager: AppWidgetManager,
        appWidgetIds: IntArray
    ) {
        for (appWidgetId in appWidgetIds) {
            updateWidget(context, appWidgetManager, appWidgetId)
        }
    }

    companion object {
        private const val PREFS = "FlutterSharedPreferences"
        private const val KEY_SPEND = "flutter.widget_month_spend"
        private const val KEY_BALANCE = "flutter.widget_total_balance"

        fun updateWidget(
            context: Context,
            appWidgetManager: AppWidgetManager,
            appWidgetId: Int
        ) {
            val prefs = context.getSharedPreferences(PREFS, Context.MODE_PRIVATE)

            val spend = prefs.getString(KEY_SPEND, "—") ?: "—"
            val balance = prefs.getString(KEY_BALANCE, "—") ?: "—"

            val views = RemoteViews(context.packageName, R.layout.widget_budget)
            views.setTextViewText(R.id.widget_month_spend, spend)
            views.setTextViewText(R.id.widget_balance, balance)

            // Tap widget → open app
            val intent = Intent(context, MainActivity::class.java)
            val pendingIntent = PendingIntent.getActivity(
                context, 0, intent,
                PendingIntent.FLAG_UPDATE_CURRENT or PendingIntent.FLAG_IMMUTABLE
            )
            views.setOnClickPendingIntent(android.R.id.content, pendingIntent)

            appWidgetManager.updateAppWidget(appWidgetId, views)
        }
    }
}
