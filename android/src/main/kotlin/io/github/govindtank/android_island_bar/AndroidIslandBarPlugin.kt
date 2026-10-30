package io.github.govindtank.android_island_bar

import android.app.Activity
import android.os.Build
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
                val cutoutInfo = getCutoutInfo()
                result.success(cutoutInfo)
            }
            else -> {
                result.notImplemented()
            }
        }
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
