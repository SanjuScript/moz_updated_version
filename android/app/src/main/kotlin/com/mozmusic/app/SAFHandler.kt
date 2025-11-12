package com.mozmusic.app

import android.app.Activity
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.provider.DocumentsContract
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.PluginRegistry

class SAFHandler(
    private val context: Context,
    private var activity: Activity?
) : MethodChannel.MethodCallHandler, PluginRegistry.ActivityResultListener {
    
    companion object {
        const val CHANNEL_NAME = "com.mozmusic.app/saf"
        private const val REQUEST_CODE_OPEN_DOCUMENT_TREE = 1001
    }

    private var pendingResult: MethodChannel.Result? = null
    private val grantedUris = mutableSetOf<Uri>()

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "requestDirectoryAccess" -> {
                pendingResult = result
                requestDirectoryAccess()
            }
            
            "hasAccessToFile" -> {
                val filePath = call.argument<String>("filePath")
                if (filePath != null) {
                    result.success(hasAccessToFile(filePath))
                } else {
                    result.error("INVALID_ARGUMENT", "File path is null", null)
                }
            }
            
            "isDirectoryCovered" -> {
                val dirPath = call.argument<String>("dirPath")
                if (dirPath != null) {
                    result.success(isDirectoryCovered(dirPath))
                } else {
                    result.error("INVALID_ARGUMENT", "Directory path is null", null)
                }
            }
            
            "releaseAllPermissions" -> {
                releaseAllPermissions()
                result.success(true)
            }
            
            else -> result.notImplemented()
        }
    }

    private fun requestDirectoryAccess() {
        val intent = Intent(Intent.ACTION_OPEN_DOCUMENT_TREE).apply {
            flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                    Intent.FLAG_GRANT_WRITE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PERSISTABLE_URI_PERMISSION or
                    Intent.FLAG_GRANT_PREFIX_URI_PERMISSION
        }
        
        activity?.startActivityForResult(intent, REQUEST_CODE_OPEN_DOCUMENT_TREE)
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?): Boolean {
        if (requestCode == REQUEST_CODE_OPEN_DOCUMENT_TREE) {
            if (resultCode == Activity.RESULT_OK && data != null) {
                val uri = data.data
                if (uri != null) {
                    // Take persistable URI permission
                    val takeFlags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                            Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                    
                    try {
                        context.contentResolver.takePersistableUriPermission(uri, takeFlags)
                        grantedUris.add(uri)
                        pendingResult?.success(uri.toString())
                    } catch (e: Exception) {
                        pendingResult?.error("PERMISSION_ERROR", e.message, null)
                    }
                } else {
                    pendingResult?.error("NO_URI", "No URI returned", null)
                }
            } else {
                pendingResult?.error("CANCELLED", "User cancelled", null)
            }
            pendingResult = null
            return true
        }
        return false
    }

    private fun hasAccessToFile(filePath: String): Boolean {
        // Get all persisted URI permissions
        val persistedUris = context.contentResolver.persistedUriPermissions
        
        for (permission in persistedUris) {
            if (isFileUnderUri(filePath, permission.uri)) {
                return true
            }
        }
        return false
    }

    private fun isDirectoryCovered(dirPath: String): Boolean {
        val persistedUris = context.contentResolver.persistedUriPermissions
        
        for (permission in persistedUris) {
            if (isPathUnderUri(dirPath, permission.uri)) {
                return true
            }
        }
        return false
    }

    private fun isFileUnderUri(filePath: String, uri: Uri): Boolean {
        // Extract the path from the tree URI
        val treeDocumentId = DocumentsContract.getTreeDocumentId(uri)
        val treePath = extractPathFromDocumentId(treeDocumentId)
        
        return filePath.startsWith(treePath)
    }

    private fun isPathUnderUri(dirPath: String, uri: Uri): Boolean {
        val treeDocumentId = DocumentsContract.getTreeDocumentId(uri)
        val treePath = extractPathFromDocumentId(treeDocumentId)
        
        return dirPath.startsWith(treePath) || treePath.startsWith(dirPath)
    }

    private fun extractPathFromDocumentId(documentId: String): String {
        // Document ID format: "primary:Music" or "primary:Music/subfolder"
        val parts = documentId.split(":")
        if (parts.size >= 2) {
            val relativePath = parts[1]
            // Convert to absolute path
            return "/storage/emulated/0/$relativePath"
        }
        return ""
    }

    private fun releaseAllPermissions() {
        val persistedUris = context.contentResolver.persistedUriPermissions
        for (permission in persistedUris) {
            try {
                val flags = Intent.FLAG_GRANT_READ_URI_PERMISSION or
                        Intent.FLAG_GRANT_WRITE_URI_PERMISSION
                context.contentResolver.releasePersistableUriPermission(permission.uri, flags)
            } catch (e: Exception) {
                e.printStackTrace()
            }
        }
        grantedUris.clear()
    }

    fun setActivity(activity: Activity?) {
        this.activity = activity
    }

    // Get DocumentFile for a given file path using granted URIs
    fun getDocumentFileForPath(filePath: String): DocumentFile? {
        val persistedUris = context.contentResolver.persistedUriPermissions
        
        for (permission in persistedUris) {
            if (isFileUnderUri(filePath, permission.uri)) {
                val treeDocumentId = DocumentsContract.getTreeDocumentId(permission.uri)
                val treePath = extractPathFromDocumentId(treeDocumentId)
                
                // Get relative path
                val relativePath = filePath.removePrefix(treePath).removePrefix("/")
                
                // Navigate to the file
                var docFile = DocumentFile.fromTreeUri(context, permission.uri)
                
                if (relativePath.isNotEmpty()) {
                    val pathParts = relativePath.split("/")
                    for (part in pathParts) {
                        docFile = docFile?.findFile(part)
                        if (docFile == null) break
                    }
                }
                
                return docFile
            }
        }
        return null
    }
}