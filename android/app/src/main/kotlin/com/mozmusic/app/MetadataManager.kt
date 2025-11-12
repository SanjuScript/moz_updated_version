package com.mozmusic.app

import android.content.Context
import androidx.documentfile.provider.DocumentFile
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import org.jaudiotagger.audio.AudioFileIO
import org.jaudiotagger.tag.FieldKey
import org.jaudiotagger.tag.images.AndroidArtwork
import java.io.File
import java.io.FileInputStream
import java.io.FileOutputStream

class MetadataManager(
    private val context: Context,
    private val safHandler: SAFHandler
) : MethodChannel.MethodCallHandler {
    
    companion object {
        const val CHANNEL_NAME = "com.mozmusic.app/metadata"
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        try {
            when (call.method) {
                "readMetadata" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val metadata = readMetadata(filePath)
                        result.success(metadata)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null", null)
                    }
                }
                
                "writeMetadata" -> {
                    val filePath = call.argument<String>("filePath")
                    val metadata = call.argument<Map<String, Any>>("metadata")
                    if (filePath != null && metadata != null) {
                        val success = writeMetadata(filePath, metadata)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid arguments", null)
                    }
                }
                
                "updateMetadata" -> {
                    val filePath = call.argument<String>("filePath")
                    val updates = call.argument<Map<String, Any>>("updates")
                    if (filePath != null && updates != null) {
                        val success = updateMetadata(filePath, updates)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid arguments", null)
                    }
                }
                
                "extractAlbumArt" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val artBytes = extractAlbumArt(filePath)
                        result.success(artBytes)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null", null)
                    }
                }
                
                "embedAlbumArt" -> {
                    val filePath = call.argument<String>("filePath")
                    val imageBytes = call.argument<ByteArray>("imageBytes")
                    if (filePath != null && imageBytes != null) {
                        val success = embedAlbumArt(filePath, imageBytes)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "Invalid arguments", null)
                    }
                }
                
                "removeAlbumArt" -> {
                    val filePath = call.argument<String>("filePath")
                    if (filePath != null) {
                        val success = removeAlbumArt(filePath)
                        result.success(success)
                    } else {
                        result.error("INVALID_ARGUMENT", "File path is null", null)
                    }
                }
                
                "getSupportedFormats" -> {
                    val formats = listOf("mp3", "m4a", "flac", "ogg", "wav", "opus")
                    result.success(formats)
                }
                
                else -> result.notImplemented()
            }
        } catch (e: Exception) {
            result.error("ERROR", e.message, e.stackTraceToString())
        }
    }

    private fun readMetadata(filePath: String): Map<String, Any?> {
        val file = File(filePath)
        val audioFile = AudioFileIO.read(file)
        val tag = audioFile.tagOrCreateAndSetDefault
        val header = audioFile.audioHeader

        return mapOf(
            "title" to tag.getFirst(FieldKey.TITLE),
            "artist" to tag.getFirst(FieldKey.ARTIST),
            "album" to tag.getFirst(FieldKey.ALBUM),
            "albumArtist" to tag.getFirst(FieldKey.ALBUM_ARTIST),
            "genre" to tag.getFirst(FieldKey.GENRE),
            "year" to tag.getFirst(FieldKey.YEAR).toIntOrNull(),
            "trackNumber" to tag.getFirst(FieldKey.TRACK).toIntOrNull(),
            "trackTotal" to tag.getFirst(FieldKey.TRACK_TOTAL).toIntOrNull(),
            "discNumber" to tag.getFirst(FieldKey.DISC_NO).toIntOrNull(),
            "discTotal" to tag.getFirst(FieldKey.DISC_TOTAL).toIntOrNull(),
            "composer" to tag.getFirst(FieldKey.COMPOSER),
            "comment" to tag.getFirst(FieldKey.COMMENT),
            "lyrics" to tag.getFirst(FieldKey.LYRICS),
            "duration" to (header.trackLength * 1000),
            "bitrate" to header.bitRateAsNumber,
            "sampleRate" to header.sampleRateAsNumber,
            "mimeType" to header.format,
            "codec" to header.encodingType
        )
    }

    private fun writeMetadata(filePath: String, metadata: Map<String, Any>): Boolean {
        return try {
            // Step 1: Copy file to temp location
            val originalExt = File(filePath).extension
            val tempFile = File(context.cacheDir, "temp_audio_${System.currentTimeMillis()}.$originalExt")
            File(filePath).copyTo(tempFile, overwrite = true)

            // Step 2: Modify metadata in temp file
            val audioFile = AudioFileIO.read(tempFile)
            val tag = audioFile.tagOrCreateAndSetDefault

            metadata["title"]?.let { tag.setField(FieldKey.TITLE, it.toString()) }
            metadata["artist"]?.let { tag.setField(FieldKey.ARTIST, it.toString()) }
            metadata["album"]?.let { tag.setField(FieldKey.ALBUM, it.toString()) }
            metadata["albumArtist"]?.let { tag.setField(FieldKey.ALBUM_ARTIST, it.toString()) }
            metadata["genre"]?.let { tag.setField(FieldKey.GENRE, it.toString()) }
            metadata["year"]?.let { tag.setField(FieldKey.YEAR, it.toString()) }
            metadata["trackNumber"]?.let { tag.setField(FieldKey.TRACK, it.toString()) }
            metadata["composer"]?.let { tag.setField(FieldKey.COMPOSER, it.toString()) }
            metadata["comment"]?.let { tag.setField(FieldKey.COMMENT, it.toString()) }
            metadata["lyrics"]?.let { tag.setField(FieldKey.LYRICS, it.toString()) }

            audioFile.commit()

            // Step 3: Write back using SAF
            val success = writeFileUsingSAF(filePath, tempFile)

            // Step 4: Cleanup
            tempFile.delete()

            success
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun writeFileUsingSAF(originalPath: String, modifiedFile: File): Boolean {
        return try {
            // Get DocumentFile using SAF
            val documentFile = safHandler.getDocumentFileForPath(originalPath)
            
            if (documentFile != null && documentFile.exists() && documentFile.canWrite()) {
                // Write the modified file to the original location
                context.contentResolver.openOutputStream(documentFile.uri)?.use { outputStream ->
                    FileInputStream(modifiedFile).use { inputStream ->
                        inputStream.copyTo(outputStream)
                    }
                }
                true
            } else {
                false
            }
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun updateMetadata(filePath: String, updates: Map<String, Any>): Boolean {
        return writeMetadata(filePath, updates)
    }

    private fun extractAlbumArt(filePath: String): ByteArray? {
        return try {
            val file = File(filePath)
            val audioFile = AudioFileIO.read(file)
            val tag = audioFile.tagOrCreateAndSetDefault
            val artwork = tag.firstArtwork
            artwork?.binaryData
        } catch (e: Exception) {
            e.printStackTrace()
            null
        }
    }

    private fun embedAlbumArt(filePath: String, imageBytes: ByteArray): Boolean {
        return try {
            // Step 1: Copy to temp
           val originalExt = File(filePath).extension
           val tempFile = File(context.cacheDir, "temp_audio_art_${System.currentTimeMillis()}.$originalExt")
           File(filePath).copyTo(tempFile, overwrite = true)


            // Step 2: Modify in temp
            val audioFile = AudioFileIO.read(tempFile)
            val tag = audioFile.tagOrCreateAndSetDefault
            
            val tempImageFile = createTempImageFile(imageBytes)
            val artwork = AndroidArtwork.createArtworkFromFile(tempImageFile)
            tag.deleteArtworkField()
            tag.setField(artwork)
            
            audioFile.commit()
            tempImageFile.delete()

            // Step 3: Write back using SAF
            val success = writeFileUsingSAF(filePath, tempFile)
            
            // Step 4: Cleanup
            tempFile.delete()
            
            success
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun removeAlbumArt(filePath: String): Boolean {
        return try {
           val originalExt = File(filePath).extension
           val tempFile = File(context.cacheDir, "temp_audio_art_${System.currentTimeMillis()}.$originalExt")
           File(filePath).copyTo(tempFile, overwrite = true)

            val audioFile = AudioFileIO.read(tempFile)
            val tag = audioFile.tagOrCreateAndSetDefault
            tag.deleteArtworkField()
            audioFile.commit()

            val success = writeFileUsingSAF(filePath, tempFile)
            tempFile.delete()
            
            success
        } catch (e: Exception) {
            e.printStackTrace()
            false
        }
    }

    private fun createTempImageFile(imageBytes: ByteArray): File {
        val tempFile = File.createTempFile("album_art", ".jpg", context.cacheDir)
        tempFile.writeBytes(imageBytes)
        return tempFile
    }
}