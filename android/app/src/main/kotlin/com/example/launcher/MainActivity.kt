package com.example.launcher

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.ApplicationInfo
import android.content.pm.PackageManager
import android.graphics.Bitmap
import android.graphics.Canvas
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.os.Build
import android.os.Bundle
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.ByteArrayOutputStream
import java.util.Calendar

import android.app.NotificationManager
import android.content.ComponentName
import android.content.pm.LauncherApps
import android.content.pm.ShortcutInfo
import android.os.UserHandle
import android.os.UserManager
import androidx.core.app.NotificationManagerCompat

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.launcher/apps"
    private var methodChannel: MethodChannel? = null

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            methodChannel?.invokeMethod("appsChanged", null)
        }
    }

    private val notificationReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            val data = mapOf(
                "packageName" to intent?.getStringExtra("packageName"),
                "title" to intent?.getStringExtra("title"),
                "text" to intent?.getStringExtra("text"),
                "id" to intent?.getIntExtra("id", -1)
            )
            val method = if (intent?.action == "com.example.launcher.NOTIFICATION") "onNotificationPosted" else "onNotificationRemoved"
            methodChannel?.invokeMethod(method, data)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addDataScheme("package")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(packageReceiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(packageReceiver, filter)
        }

        val nFilter = IntentFilter().apply {
            addAction("com.example.launcher.NOTIFICATION")
            addAction("com.example.launcher.NOTIFICATION_REMOVED")
        }
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(notificationReceiver, nFilter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(notificationReceiver, nFilter)
        }
    }



    override fun onDestroy() {
        super.onDestroy()
        unregisterReceiver(packageReceiver)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        methodChannel = MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
        methodChannel?.setMethodCallHandler { call, result ->
            when (call.method) {
                "getInstalledApps" -> {
                    val apps = fetchApps()
                    result.success(apps)
                }
                "launchApp" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        launchApp(packageName)
                        result.success(true)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                "isDefaultLauncher" -> {
                    result.success(isDefaultLauncher())
                }
                "openLauncherSettings" -> {
                    openLauncherSettings()
                    result.success(true)
                }
                "checkUsagePermission" -> {
                    result.success(hasUsagePermission())
                }
                "openUsageSettings" -> {
                    openUsageSettings()
                    result.success(true)
                }
                "getUsageStats" -> {
                    result.success(getUsageStats())
                }
                "openAppInfo" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        openAppInfo(packageName)
                        result.success(true)
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                "getShortcuts" -> {
                    val packageName = call.argument<String>("packageName")
                    if (packageName != null) {
                        result.success(getShortcuts(packageName))
                    } else {
                        result.error("INVALID_PACKAGE", "Package name is null", null)
                    }
                }
                "launchShortcut" -> {
                    val packageName = call.argument<String>("packageName")
                    val shortcutId = call.argument<String>("shortcutId")
                    if (packageName != null && shortcutId != null) {
                        launchShortcut(packageName, shortcutId)
                        result.success(true)
                    } else {
                        result.error("INVALID_ARGUMENTS", "Package name or shortcut ID is null", null)
                    }
                }
                "checkNotificationPermission" -> {
                    result.success(isNotificationServiceEnabled())
                }
                "openNotificationSettings" -> {
                    openNotificationSettings()
                    result.success(true)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun fetchApps(): List<Map<String, Any>> {
        val pm = packageManager
        val apps = pm.getInstalledApplications(PackageManager.GET_META_DATA)
        return apps.filter { pm.getLaunchIntentForPackage(it.packageName) != null }.map {
            val category = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.O) {
                it.category
            } else {
                -1
            }
            mapOf(
                "name" to it.loadLabel(pm).toString(),
                "packageName" to it.packageName,
                "icon" to drawableToBytes(it.loadIcon(pm)),
                "category" to category
            )
        }
    }

    private fun launchApp(packageName: String) {
        val intent = packageManager.getLaunchIntentForPackage(packageName)
        if (intent != null) {
            intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            startActivity(intent)
        }
    }

    private fun openAppInfo(packageName: String) {
        val intent = Intent(Settings.ACTION_APPLICATION_DETAILS_SETTINGS)
        intent.data = android.net.Uri.parse("package:$packageName")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun isDefaultLauncher(): Boolean {
        val intent = Intent(Intent.ACTION_MAIN)
        intent.addCategory(Intent.CATEGORY_HOME)
        val res = packageManager.resolveActivity(intent, PackageManager.MATCH_DEFAULT_ONLY)
        return res != null && packageName == res.activityInfo.packageName
    }

    private fun openLauncherSettings() {
        val intent = Intent(Settings.ACTION_HOME_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun hasUsagePermission(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        val mode = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            appOps.unsafeCheckOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        } else {
            appOps.checkOpNoThrow(AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName)
        }
        return mode == AppOpsManager.MODE_ALLOWED
    }

    private fun openUsageSettings() {
        val intent = Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS)
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun getUsageStats(): Map<String, Long> {
        val usageStatsManager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val calendar = Calendar.getInstance()
        calendar.add(Calendar.DAY_OF_YEAR, -1)
        val stats = usageStatsManager.queryAndAggregateUsageStats(calendar.timeInMillis, System.currentTimeMillis())
        
        return stats.mapValues { it.value.totalTimeInForeground }
    }

    private fun getShortcuts(packageName: String): List<Map<String, String>> {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return emptyList()
        
        val launcherApps = getSystemService(Context.LAUNCHER_APPS_SERVICE) as LauncherApps
        val query = LauncherApps.ShortcutQuery()
        query.setPackage(packageName)
        query.setQueryFlags(LauncherApps.ShortcutQuery.FLAG_MATCH_DYNAMIC or LauncherApps.ShortcutQuery.FLAG_MATCH_MANIFEST or LauncherApps.ShortcutQuery.FLAG_MATCH_PINNED)
        
        try {
            val shortcuts = launcherApps.getShortcuts(query, Process.myUserHandle())
            return shortcuts?.map {
                mapOf(
                    "id" to it.id,
                    "label" to (it.shortLabel?.toString() ?: "Shortcut")
                )
            } ?: emptyList()
        } catch (e: Exception) {
            return emptyList()
        }
    }

    private fun launchShortcut(packageName: String, shortcutId: String) {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.N_MR1) return
        
        val launcherApps = getSystemService(Context.LAUNCHER_APPS_SERVICE) as LauncherApps
        launcherApps.startShortcut(packageName, shortcutId, null, null, Process.myUserHandle())
    }

    private fun isNotificationServiceEnabled(): Boolean {
        val pkgName = packageName
        val flat = Settings.Secure.getString(contentResolver, "enabled_notification_listeners")
        if (!flat.isNullOrEmpty()) {
            val names = flat.split(":")
            for (name in names) {
                val cn = ComponentName.unflattenFromString(name)
                if (cn != null && pkgName == cn.packageName) return true
            }
        }
        return false
    }

    private fun openNotificationSettings() {
        val intent = Intent("android.settings.ACTION_NOTIFICATION_LISTENER_SETTINGS")
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        startActivity(intent)
    }

    private fun drawableToBytes(drawable: Drawable): ByteArray {
        val bitmap = if (drawable is BitmapDrawable) {
            drawable.bitmap
        } else {
            val bmp = Bitmap.createBitmap(
                drawable.intrinsicWidth.coerceAtLeast(1),
                drawable.intrinsicHeight.coerceAtLeast(1),
                Bitmap.Config.ARGB_8888
            )
            val canvas = Canvas(bmp)
            drawable.setBounds(0, 0, canvas.width, canvas.height)
            drawable.draw(canvas)
            bmp
        }
        val stream = ByteArrayOutputStream()
        bitmap.compress(Bitmap.CompressFormat.PNG, 100, stream)
        return stream.toByteArray()
    }
}



