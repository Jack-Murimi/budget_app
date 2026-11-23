# Keep Flutter wrapper and app entry points
-keep class io.flutter.app.** { *; }
-keep class io.flutter.plugin.** { *; }
-keep class io.flutter.util.** { *; }
-keep class io.flutter.view.** { *; }
-keep class io.flutter.** { *; }
-keep class io.flutter.plugins.** { *; }

-keep class com.budgetapp.budget_app.MainActivity { *; }
-keep class com.budgetapp.budget_app.BudgetWidget { *; }

# Keep SQLite / Drift native bindings
-keep class org.sqlite.** { *; }
-keep class androidx.sqlite.** { *; }
-keep class eu.simonbinder.sqlite3_flutter_libs.** { *; }

# Flutter Play Store deferred components are unused in this app
-dontwarn com.google.android.play.core.**
