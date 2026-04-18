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

class MainActivity : FlutterActivity() {
    private val CHANNEL = "com.example.launcher/apps"
    private var methodChannel: MethodChannel? = null

    private val packageReceiver = object : BroadcastReceiver() {
        override fun onReceive(context: Context?, intent: Intent?) {
            methodChannel?.invokeMethod("appsChanged", null)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        val filter = IntentFilter().apply {
            addAction(Intent.ACTION_PACKAGE_ADDED)
            addAction(Intent.ACTION_PACKAGE_REMOVED)
            addDataScheme("package")
        }
        registerReceiver(packageReceiver, filter)
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


