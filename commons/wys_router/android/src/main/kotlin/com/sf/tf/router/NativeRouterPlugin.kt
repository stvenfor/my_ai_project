package com.sf.tf.router

import android.content.Context
import android.content.Intent
import android.net.Uri
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class NativeRouterPlugin : FlutterPlugin, MethodChannel.MethodCallHandler {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        context = binding.applicationContext
        channel = MethodChannel(binding.binaryMessenger, CHANNEL_NAME)
        sharedChannel = channel
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        if (call.method != OPEN_NATIVE_ROUTE) {
            result.notImplemented()
            return
        }

        val path = call.argument<String>("path")?.trim().orEmpty()
        if (path.isEmpty()) {
            result.error("INVALID_NATIVE_ROUTE", "原生页面路径不能为空", null)
            return
        }

        try {
            val builder = Uri.parse(toRouteUrl(path)).buildUpon()
            call.argument<Map<String, Any?>>("arguments")?.forEach { (key, value) ->
                if (value != null) builder.appendQueryParameter(key, value.toString())
            }
            val intent = Intent(Intent.ACTION_VIEW, builder.build()).apply {
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                setPackage(context.packageName)
            }
            context.startActivity(intent)
            result.success(true)
        } catch (error: Throwable) {
            result.error("OPEN_NATIVE_ROUTE_FAILED", error.message, path)
        }
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        if (sharedChannel === channel) sharedChannel = null
    }

    private fun toRouteUrl(path: String): String {
        return if (path.contains("://")) path else "tffanclub://com.sf.tf${if (path.startsWith('/')) path else "/$path"}"
    }

    companion object {
        private var sharedChannel: MethodChannel? = null
        private const val CHANNEL_NAME = "com.tf.flutter/native_router"
        private const val OPEN_NATIVE_ROUTE = "openNativeRoute"

        @JvmStatic
        fun openFlutterRoute(route: String, arguments: Map<String, Any?> = emptyMap()) {
            sharedChannel?.invokeMethod(
                "openFlutterRoute",
                mapOf("route" to route, "arguments" to arguments),
            )
        }
    }
}
