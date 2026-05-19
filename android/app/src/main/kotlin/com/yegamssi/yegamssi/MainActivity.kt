package com.yegamssi.yegamssi

import android.appwidget.AppWidgetManager
import android.content.ComponentName
import android.content.ContentValues
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.os.Build
import android.os.Environment
import android.provider.MediaStore
import com.yegamssi.yegamssi.alarm.AlarmScheduler
import com.yegamssi.yegamssi.widget.YegamssiWidget
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private var lastCaptureUri: Uri? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // AlarmManager 기반 위젯 갱신 알람 등록 (앱 설치/재시작 후 보장)
        AlarmScheduler.schedule(this)
    }

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            APP_CONTROL_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_CLOSE_APP -> {
                    runOnUiThread {
                        finishAffinity()
                        finishAndRemoveTask()
                    }
                    result.success(null)
                }
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            WIDGET_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_IS_WIDGET_INSTALLED -> result.success(isWidgetInstalled())
                METHOD_REQUEST_PIN_WIDGET -> result.success(requestPinWidget())
                else -> result.notImplemented()
            }
        }

        MethodChannel(
            flutterEngine.dartExecutor.binaryMessenger,
            CAPTURE_CHANNEL,
        ).setMethodCallHandler { call, result ->
            when (call.method) {
                METHOD_SAVE_PNG -> {
                    val bytes = call.argument<ByteArray>("bytes")
                    val fileName = call.argument<String>("fileName")
                    if (bytes == null || fileName.isNullOrBlank()) {
                        result.error("INVALID_ARGUMENT", "캡처 저장 정보가 올바르지 않습니다.", null)
                        return@setMethodCallHandler
                    }

                    runCatching {
                        savePngToPictures(bytes, fileName)
                    }.onSuccess { uri ->
                        lastCaptureUri = uri
                        result.success(uri.toString())
                    }.onFailure { error ->
                        result.error("SAVE_FAILED", error.message, null)
                    }
                }
                METHOD_OPEN_CAPTURE_FOLDER -> {
                    result.success(openCaptureFolder())
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun isWidgetInstalled(): Boolean {
        val manager = AppWidgetManager.getInstance(this)
        val provider = ComponentName(this, YegamssiWidget::class.java)
        return manager.getAppWidgetIds(provider).isNotEmpty()
    }

    private fun requestPinWidget(): Boolean {
        if (Build.VERSION.SDK_INT < Build.VERSION_CODES.O) {
            return false
        }
        val manager = AppWidgetManager.getInstance(this)
        if (!manager.isRequestPinAppWidgetSupported) {
            return false
        }
        val provider = ComponentName(this, YegamssiWidget::class.java)
        return manager.requestPinAppWidget(provider, null, null)
    }

    private fun savePngToPictures(bytes: ByteArray, fileName: String): Uri {
        val resolver = contentResolver
        val safeFileName = if (fileName.endsWith(".png", ignoreCase = true)) {
            fileName
        } else {
            "$fileName.png"
        }

        val values = ContentValues().apply {
            put(MediaStore.Images.Media.DISPLAY_NAME, safeFileName)
            put(MediaStore.Images.Media.MIME_TYPE, "image/png")
            if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                put(
                    MediaStore.Images.Media.RELATIVE_PATH,
                    "${Environment.DIRECTORY_PICTURES}/Yegamssi",
                )
                put(MediaStore.Images.Media.IS_PENDING, 1)
            }
        }

        val uri = resolver.insert(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, values)
            ?: error("캡처 파일을 생성하지 못했습니다.")

        resolver.openOutputStream(uri)?.use { output ->
            output.write(bytes)
        } ?: error("캡처 파일을 열지 못했습니다.")

        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
            values.clear()
            values.put(MediaStore.Images.Media.IS_PENDING, 0)
            resolver.update(uri, values, null, null)
        }

        return uri
    }

    private fun openCaptureFolder(): Boolean {
        val savedImageUri = lastCaptureUri
        if (savedImageUri != null) {
            val imageIntent = Intent(Intent.ACTION_VIEW).apply {
                setDataAndType(savedImageUri, "image/png")
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            }
            if (runCatching {
                    startActivity(Intent.createChooser(imageIntent, "예감씨 캡처 열기"))
                    true
                }.getOrDefault(false)
            ) {
                return true
            }
        }

        val galleryIntent = Intent(Intent.ACTION_VIEW).apply {
            setDataAndType(MediaStore.Images.Media.EXTERNAL_CONTENT_URI, "image/*")
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
        return runCatching {
            startActivity(Intent.createChooser(galleryIntent, "예감씨 캡처 열기"))
            true
        }.getOrDefault(false)
    }

    companion object {
        private const val APP_CONTROL_CHANNEL = "yegamssi/app_control"
        private const val METHOD_CLOSE_APP = "closeApp"
        private const val WIDGET_CHANNEL = "yegamssi/widget"
        private const val METHOD_IS_WIDGET_INSTALLED = "isWidgetInstalled"
        private const val METHOD_REQUEST_PIN_WIDGET = "requestPinWidget"
        private const val CAPTURE_CHANNEL = "yegamssi/capture"
        private const val METHOD_SAVE_PNG = "savePng"
        private const val METHOD_OPEN_CAPTURE_FOLDER = "openCaptureFolder"
    }
}
