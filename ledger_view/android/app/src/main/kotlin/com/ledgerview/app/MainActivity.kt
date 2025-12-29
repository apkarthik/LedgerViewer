package com.ledgerview.app

import android.content.Intent
import android.net.Uri
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ledgerview.app/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "shareToWhatsApp" -> {
                    val filePath = call.argument<String>("filePath")
                    val phoneNumber = call.argument<String>("phoneNumber")
                    val message = call.argument<String>("message")
                    val mimeType = call.argument<String>("mimeType") ?: "application/pdf"
                    
                    if (filePath != null && phoneNumber != null) {
                        val success = shareToWhatsApp(filePath, phoneNumber, message ?: "", mimeType)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "filePath and phoneNumber are required", null)
                    }
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun shareToWhatsApp(filePath: String, phoneNumber: String, message: String, mimeType: String): Boolean {
        return try {
            val file = File(filePath)
            if (!file.exists()) {
                return false
            }

            // Get content URI using FileProvider
            val contentUri = FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                file
            )

            // Create intent for WhatsApp
            val intent = Intent(Intent.ACTION_SEND).apply {
                type = mimeType
                putExtra(Intent.EXTRA_STREAM, contentUri)
                putExtra(Intent.EXTRA_TEXT, message)
                putExtra("jid", "$phoneNumber@s.whatsapp.net") // WhatsApp-specific extra for contact
                setPackage("com.whatsapp") // Target WhatsApp specifically
                addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
            }

            // Try to start WhatsApp
            startActivity(intent)
            true
        } catch (e: Exception) {
            // If WhatsApp is not installed or something fails, try WhatsApp Business
            try {
                val file = File(filePath)
                val contentUri = FileProvider.getUriForFile(
                    this,
                    "${applicationContext.packageName}.fileprovider",
                    file
                )

                val intent = Intent(Intent.ACTION_SEND).apply {
                    type = mimeType
                    putExtra(Intent.EXTRA_STREAM, contentUri)
                    putExtra(Intent.EXTRA_TEXT, message)
                    putExtra("jid", "$phoneNumber@s.whatsapp.net")
                    setPackage("com.whatsapp.w4b") // WhatsApp Business
                    addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }

                startActivity(intent)
                true
            } catch (e2: Exception) {
                false
            }
        }
    }
}
