package com.example.nutrivogo

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            "nutrivogo/platform"
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                "applicationSupportDirectory" -> result.success(filesDir.absolutePath)
                else -> result.notImplemented()
            }
        }
    }
}
