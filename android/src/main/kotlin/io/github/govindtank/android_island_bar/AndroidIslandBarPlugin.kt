package io.github.govindtank.android_island_bar

import android.app.Activity
import android.content.ComponentName
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.media.MediaMetadata
import android.media.session.MediaController
import android.media.session.MediaSessionManager
import android.os.BatteryManager
import android.os.Build
import android.provider.Settings
import android.view.DisplayCutout
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * AndroidIslandBarPlugin
 * Bridges native Android DisplayCutout geometry (bounding rects, safe insets, cutout type)
 * to Flutter for pixel-perfect punch-hole camera cutout hugging.
 */
class AndroidIslandBarPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private var activity: Activity? = null

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "android_island_bar")
        channel.setMethodCallHandler(this)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "getPlatformVersion" -> {
                result.success("Android ${Build.VERSION.RELEASE}")
            }
            "getCutoutInfo" -> {
                result.success(getCutoutInfo())
            }
            "getBatteryInfo" -> {
                result.success(getBatteryInfo())
            }
            "getMediaSnapshot" -> {
                result.success(getMediaSnapshot())
            }
            "openMediaAccessSettings" -> {
                val currentActivity = activity
                if (currentActivity == null) {
                    result.error("NO_ACTIVITY", "The Flutter activity is not attached.", null)
                } else {
                    currentActivity.startActivity(
                        Intent(Settings.ACTION_NOTIFICATION_LISTENER_SETTINGS)
                    )
                    result.success(null)
                }
            }
            "controlMedia" -> {
                val action = call.argument<String>("action")
                if (action == null) {
                    result.error("INVALID_ACTION", "A media action is required.", null)
                } else {
                    result.success(controlMedia(action))
                }
            }
            else -> {
                result.notImplemented()
            }
        }
    }

    private fun getMediaSnapshot(): Map<String, Any?> {
        val currentActivity = activity ?: return mediaUnavailable(false)
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) {
            return mediaUnavailable(false)
        }

        val manager = currentActivity.getSystemService(Context.MEDIA_SESSION_SERVICE)
            as? MediaSessionManager ?: return mediaUnavailable(false)
        val component = ComponentName(currentActivity, MediaAccessNotificationListener::class.java)

        val sessions = try {
            manager.getActiveSessions(component)
        } catch (_: SecurityException) {
            return mediaUnavailable(false)
        }

        val controller = sessions.firstOrNull { it.metadata != null && isActive(it) }
            ?: sessions.firstOrNull { it.metadata != null }
            ?: return mapOf("accessGranted" to true, "hasSession" to false)
        val metadata = controller.metadata
        val state = controller.playbackState
        val packageName = controller.packageName ?: ""
        val appLabel = try {
            currentActivity.packageManager
                .getApplicationLabel(currentActivity.packageManager.getApplicationInfo(packageName, 0))
                .toString()
        } catch (_: Exception) {
            packageName
        }

        return mapOf(
            "accessGranted" to true,
            "hasSession" to true,
            "title" to (metadata?.getString(MediaMetadata.METADATA_KEY_TITLE) ?: ""),
            "artist" to (metadata?.getString(MediaMetadata.METADATA_KEY_ARTIST)
                ?: metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM_ARTIST) ?: ""),
            "album" to (metadata?.getString(MediaMetadata.METADATA_KEY_ALBUM) ?: ""),
            "packageName" to packageName,
            "appLabel" to appLabel,
            "isPlaying" to (state?.state == android.media.session.PlaybackState.STATE_PLAYING
                || state?.state == android.media.session.PlaybackState.STATE_BUFFERING),
            "positionMs" to (state?.position ?: 0L),
            "durationMs" to (metadata?.getLong(MediaMetadata.METADATA_KEY_DURATION) ?: 0L)
        )
    }

    private fun isActive(controller: MediaController): Boolean {
        val state = controller.playbackState?.state
        return state == android.media.session.PlaybackState.STATE_PLAYING
            || state == android.media.session.PlaybackState.STATE_BUFFERING
    }

    private fun controlMedia(action: String): Boolean {
        val currentActivity = activity ?: return false
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.LOLLIPOP) return false
        val manager = currentActivity.getSystemService(Context.MEDIA_SESSION_SERVICE)
            as? MediaSessionManager ?: return false
        val component = ComponentName(currentActivity, MediaAccessNotificationListener::class.java)
        val controller = try {
            manager.getActiveSessions(component).firstOrNull { it.metadata != null && isActive(it) }
                ?: manager.getActiveSessions(component).firstOrNull { it.metadata != null }
        } catch (_: SecurityException) {
            return false
        } ?: return false

        when (action) {
            "play" -> controller.transportControls.play()
            "pause" -> controller.transportControls.pause()
            "playPause" -> if (isActive(controller)) controller.transportControls.pause()
            else controller.transportControls.play()
            "next" -> controller.transportControls.skipToNext()
            "previous" -> controller.transportControls.skipToPrevious()
            else -> return false
        }
        return true
    }

    private fun mediaUnavailable(accessGranted: Boolean): Map<String, Any?> = mapOf(
        "accessGranted" to accessGranted,
        "hasSession" to false
    )

    private fun getBatteryInfo(): Map<String, Any?> {
        val currentActivity = activity ?: return emptyMap()
        val batteryStatus: Intent? = IntentFilter(Intent.ACTION_BATTERY_CHANGED).let { filter ->
            currentActivity.registerReceiver(null, filter)
        }
        val level: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_LEVEL, -1) ?: -1
        val scale: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_SCALE, -1) ?: -1
        val batteryPct: Int = if (level >= 0 && scale > 0) ((level.toFloat() / scale.toFloat()) * 100).toInt() else -1
        val status: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_STATUS, -1) ?: -1
        val isCharging: Boolean = status == BatteryManager.BATTERY_STATUS_CHARGING || status == BatteryManager.BATTERY_STATUS_FULL
        val chargePlug: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_PLUGGED, -1) ?: -1
        val isFastCharge: Boolean = chargePlug == BatteryManager.BATTERY_PLUGGED_AC
        val tempTenths: Int = batteryStatus?.getIntExtra(BatteryManager.EXTRA_TEMPERATURE, 0) ?: 0
        val temperatureC: Double = tempTenths / 10.0

        return mapOf(
            "percent" to batteryPct,
            "isCharging" to isCharging,
            "temperatureC" to temperatureC,
            "isFastCharge" to isFastCharge
        )
    }

    private fun getCutoutInfo(): Map<String, Any?> {
        val currentActivity = activity ?: return mapOf(
            "hasCutout" to false,
            "cutoutType" to "none",
            "safeInsetTop" to 0.0,
            "safeInsetBottom" to 0.0,
            "safeInsetLeft" to 0.0,
            "safeInsetRight" to 0.0,
            "rects" to emptyList<Map<String, Double>>()
        )

        val metrics = currentActivity.resources.displayMetrics
        val density = metrics.density.toDouble()
        val screenWidthPx = metrics.widthPixels

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
            val window = currentActivity.window
            val windowInsets = window?.decorView?.rootWindowInsets
            val displayCutout = windowInsets?.displayCutout

            if (displayCutout != null) {
                val rects = displayCutout.boundingRects
                val rectList = mutableListOf<Map<String, Double>>()
                var cutoutType = "center_punch"

                for (rect in rects) {
                    val leftDp = rect.left / density
                    val topDp = rect.top / density
                    val rightDp = rect.right / density
                    val bottomDp = rect.bottom / density
                    val widthDp = (rect.right - rect.left) / density
                    val heightDp = (rect.bottom - rect.top) / density

                    val centerX = (rect.left + rect.right) / 2.0
                    val screenCenterX = screenWidthPx / 2.0

                    if (rect.top == 0 && widthDp > 100) {
                        cutoutType = "notch"
                    } else if (centerX < screenCenterX - 45 * density) {
                        cutoutType = "left_punch"
                    } else if (centerX > screenCenterX + 45 * density) {
                        cutoutType = "right_punch"
                    } else {
                        cutoutType = "center_punch"
                    }

                    rectList.add(
                        mapOf(
                            "left" to leftDp,
                            "top" to topDp,
                            "right" to rightDp,
                            "bottom" to bottomDp,
                            "width" to widthDp,
                            "height" to heightDp,
                            "centerX" to (centerX / density),
                            "centerY" to ((rect.top + rect.bottom) / 2.0 / density)
                        )
                    )
                }

                return mapOf(
                    "hasCutout" to rects.isNotEmpty(),
                    "cutoutType" to cutoutType,
                    "safeInsetTop" to (displayCutout.safeInsetTop / density),
                    "safeInsetBottom" to (displayCutout.safeInsetBottom / density),
                    "safeInsetLeft" to (displayCutout.safeInsetLeft / density),
                    "safeInsetRight" to (displayCutout.safeInsetRight / density),
                    "rects" to rectList
                )
            }
        }

        return mapOf(
            "hasCutout" to false,
            "cutoutType" to "none",
            "safeInsetTop" to 0.0,
            "safeInsetBottom" to 0.0,
            "safeInsetLeft" to 0.0,
            "safeInsetRight" to 0.0,
            "rects" to emptyList<Map<String, Double>>()
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
    }
}
