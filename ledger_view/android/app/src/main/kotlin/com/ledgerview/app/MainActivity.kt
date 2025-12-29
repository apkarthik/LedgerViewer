package com.ledgerview.app

import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.core.content.FileProvider
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import java.io.File

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.ledgerview.app/whatsapp"
    private val TAG = "WhatsAppShare"

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
        val file = File(filePath)
        if (!file.exists()) {
            Log.e(TAG, "File does not exist: $filePath")
            return false
        }

        // Get content URI using FileProvider
        val contentUri = try {
            FileProvider.getUriForFile(
                this,
                "${applicationContext.packageName}.fileprovider",
                file
            )
        } catch (e: Exception) {
            Log.e(TAG, "Failed to get FileProvider URI for: $filePath", e)
            return false
        }

        // Try WhatsApp first
        return try {
            val intent = createWhatsAppIntent(contentUri, phoneNumber, message, mimeType, "com.whatsapp")
            startActivity(intent)
            Log.d(TAG, "Successfully opened WhatsApp")
            true
        } catch (e: Exception) {
            // If WhatsApp is not installed, try WhatsApp Business
            Log.w(TAG, "WhatsApp not available, trying WhatsApp Business", e)
            try {
                val intent = createWhatsAppIntent(contentUri, phoneNumber, message, mimeType, "com.whatsapp.w4b")
                startActivity(intent)
                Log.d(TAG, "Successfully opened WhatsApp Business")
                true
            } catch (e2: Exception) {
                Log.e(TAG, "Both WhatsApp and WhatsApp Business failed", e2)
                false
            }
        }
    }

    private fun createWhatsAppIntent(contentUri: Uri, phoneNumber: String, message: String, mimeType: String, packageName: String): Intent {
        return Intent(Intent.ACTION_SEND).apply {
            type = mimeType
            putExtra(Intent.EXTRA_STREAM, contentUri)
            putExtra(Intent.EXTRA_TEXT, message)
            putExtra("jid", "$phoneNumber@s.whatsapp.net") // WhatsApp-specific extra for contact
            setPackage(packageName)
            addFlags(Intent.FLAG_GRANT_READ_URI_PERMISSION)
            addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        }
    }
}
