package com.ttfd.owlsonic

import android.os.StatFs
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        // `owlsonic/storage`: free space of the volume holding a path, so
        // offline downloads never fill the device.
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "owlsonic/storage")
            .setMethodCallHandler { call, result ->
                val path = call.argument<String>("path")
                if (call.method != "freeBytes" || path == null) {
                    result.notImplemented()
                    return@setMethodCallHandler
                }
                try {
                    result.success(StatFs(path).availableBytes)
                } catch (error: IllegalArgumentException) {
                    result.success(null)
                }
            }
    }
}
