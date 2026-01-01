package com.example.ocr_plugin

import android.content.Context
import android.graphics.BitmapFactory
import android.util.Log
import com.equationl.paddleocr4android.CpuPowerMode
import com.equationl.paddleocr4android.OCR
import com.equationl.paddleocr4android.OcrConfig
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result
import kotlinx.coroutines.*
import java.io.File
import java.io.FileOutputStream
import java.io.IOException

class OcrPlugin: FlutterPlugin, MethodCallHandler {
    private lateinit var channel : MethodChannel
    private lateinit var context: Context
    private var ocrEngine: OCR? = null

    private val pluginScope = CoroutineScope(Dispatchers.Main + SupervisorJob())

    companion object {
        private const val TAG = "OcrPlugin_FINAL"
    }

    override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
        this.context = flutterPluginBinding.applicationContext
        channel = MethodChannel(flutterPluginBinding.binaryMessenger, "ocr_plugin_channel")
        channel.setMethodCallHandler(this)
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "init" -> {
                pluginScope.launch(Dispatchers.IO) {
                    handleInit(call, result)
                }
            }
            "recognizeText" -> {
                pluginScope.launch(Dispatchers.IO) {
                    handleRecognizeText(call, result)
                }
            }
            "release" -> handleRelease(result)
            else -> result.notImplemented()
        }
    }

    // 这个函数现在可以复制任何指定的 asset 文件夹
    private fun copyAssetsDirToInternalStorage(assetDirName: String): String? {
        val destDir = File(context.filesDir, assetDirName)
        
        // 简单起见，每次都检查。可以优化为只检查一次。
        if (destDir.exists() && destDir.listFiles()?.isNotEmpty() == true) {
            Log.i(TAG, "Directory '$assetDirName' already exists in internal storage. Skipping copy.")
            return destDir.absolutePath
        }

        Log.i(TAG, "Copying assets from '$assetDirName' to '${destDir.absolutePath}'...")
        destDir.mkdirs()

        try {
            val assetManager = context.assets
            val assetFiles = assetManager.list(assetDirName)
            if (assetFiles.isNullOrEmpty()) {
                Log.e(TAG, "Failed to find assets in directory: '$assetDirName'")
                return null
            }

            for (fileName in assetFiles) {
                val assetFilePath = "$assetDirName/$fileName"
                val destFile = File(destDir, fileName)
                assetManager.open(assetFilePath).use { inputStream ->
                    FileOutputStream(destFile).use { outputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
            }
            Log.i(TAG, "Successfully copied directory '$assetDirName'.")
            return destDir.absolutePath
        } catch (e: IOException) {
            Log.e(TAG, "Failed to copy assets directory '$assetDirName'.", e)
            destDir.deleteRecursively()
            return null
        }
    }

    private suspend fun handleInit(call: MethodCall, result: Result) {
        try {
            // 步骤 1: 只复制 models 文件夹到内部存储
            val modelsDirAbsPath = copyAssetsDirToInternalStorage("models")

            if (modelsDirAbsPath == null) {
                pluginScope.launch(Dispatchers.Main) {
                    result.error("INIT_FAILED", "Failed to copy models from assets.", null)
                }
                return
            }
            
            val args = call.arguments as? Map<String, Any>
            
            // 步骤 2: 组装最终的配置
            // 模型使用绝对路径，标签使用 assets 相对路径
            val config = OcrConfig(
                modelPath = modelsDirAbsPath,               // ✅ 使用绝对路径
                labelPath = "labels/ppocr_keys_v1.txt",     // ✅ 使用 assets 相对路径，给库它想要的东西
                detModelFilename = "det.nb",
                recModelFilename = "opt.nb",
                clsModelFilename = "cls.nb",
                cpuThreadNum = args?.get("cpuThreadNum") as? Int ?: 4,
                cpuPowerMode = CpuPowerMode.valueOf(args?.get("cpuPowerMode") as? String ?: "LITE_POWER_HIGH"),
                isRunCls = true,
                scoreThreshold = (args?.get("scoreThreshold") as? Double)?.toFloat() ?: 0.1f
            )

            Log.d(TAG, "Initializing OCR with HYBRID config: $config")

            ocrEngine = OCR(context)
            ocrEngine?.initModelSync(config)?.fold(
                onSuccess = { isSuccess ->
                    pluginScope.launch(Dispatchers.Main) {
                        if (isSuccess) {
                            Log.i(TAG, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                            Log.i(TAG, "!!!   SUCCESS! OCR Engine initialized finally!   !!!")
                            Log.i(TAG, "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!")
                            result.success(true)
                        } else {
                            Log.e(TAG, "initModelSync returned 'false'.")
                            result.error("INIT_FAILED", "initModelSync returned false.", null)
                        }
                    }
                },
                onFailure = { throwable ->
                    pluginScope.launch(Dispatchers.Main) {
                        Log.e(TAG, "initModelSync FAILED with exception.", throwable)
                        result.error("INIT_FAILED_EXCEPTION", throwable.message, throwable.toString())
                    }
                }
            )
        } catch (e: Exception) {
            pluginScope.launch(Dispatchers.Main) {
                Log.e(TAG, "An unhandled exception occurred in handleInit.", e)
                result.error("INIT_EXCEPTION", "An exception occurred in the init method.", e.toString())
            }
        }
    }

    private suspend fun handleRecognizeText(call: MethodCall, result: Result) {
        if (ocrEngine == null) {
            withContext(Dispatchers.Main) {
                result.error("NOT_INITIALIZED", "OCR engine not initialized. Call init() first.", null)
            }
            return
        }

        val imagePath = call.argument<String>("imagePath")
        if (imagePath.isNullOrEmpty()) {
             withContext(Dispatchers.Main) {
                result.error("INVALID_ARGUMENT", "Image path cannot be null or empty.", null)
            }
            return
        }
        
        try {
            val bitmap = BitmapFactory.decodeFile(imagePath)
            if (bitmap == null) {
                withContext(Dispatchers.Main) {
                    result.error("DECODE_FAILED", "Failed to decode image file to bitmap: $imagePath", null)
                }
                return
            }

            ocrEngine!!.runSync(bitmap).fold(
                onSuccess = { ocrResult ->
                    val resultList = ocrResult.outputRawResult.map { model ->
                        mapOf(
                            "text" to model.label,
                            "confidence" to model.confidence,
                            "points" to model.points.map { point -> listOf(point.x, point.y) }
                        )
                    }
                    val finalResult = mapOf(
                        "simpleText" to ocrResult.simpleText,
                        "inferenceTime" to ocrResult.inferenceTime,
                        "rawResult" to resultList
                    )
                    withContext(Dispatchers.Main) {
                        result.success(finalResult)
                    }
                },
                onFailure = { throwable ->
                    withContext(Dispatchers.Main) {
                        result.error("OCR_FAILED", throwable.message, throwable.toString())
                    }
                }
            )
        } catch (e: Exception) {
            withContext(Dispatchers.Main) {
                result.error("OCR_EXCEPTION", "An exception occurred during OCR processing.", e.toString())
            }
        }
    }

    private fun handleRelease(result: Result) {
        ocrEngine?.releaseModel()
        ocrEngine = null
        Log.i(TAG, "OCR Engine released.")
        result.success(true)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        ocrEngine?.releaseModel()
        ocrEngine = null
        pluginScope.cancel()
    }
}