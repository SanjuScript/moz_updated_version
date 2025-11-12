import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:io';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SAFManager {
  static const MethodChannel _platform = MethodChannel('com.mozmusic.app/saf');

  static final SAFManager _instance = SAFManager._internal();
  factory SAFManager() => _instance;
  SAFManager._internal();

  // Cache for granted URI permissions
  final Map<String, String> _grantedUris = {};

  /// Request persistent access to a directory
  Future<String?> requestDirectoryAccess() async {
    try {
      final String? uri = await _platform.invokeMethod(
        'requestDirectoryAccess',
      );
      if (uri != null) {
        await _saveGrantedUri(uri);
        return uri;
      }
      return null;
    } on PlatformException catch (e) {
      print('Error requesting directory access: ${e.message}');
      return null;
    }
  }

  /// Check if we have access to write to a file's directory
  Future<bool> hasAccessToFile(String filePath) async {
    try {
      final bool hasAccess = await _platform.invokeMethod('hasAccessToFile', {
        'filePath': filePath,
      });
      return hasAccess;
    } on PlatformException catch (e) {
      print('Error checking file access: ${e.message}');
      return false;
    }
  }

  /// Get the parent directory of a file
  String getParentDirectory(String filePath) {
    final lastSlash = filePath.lastIndexOf('/');
    if (lastSlash > 0) {
      return filePath.substring(0, lastSlash);
    }
    return filePath;
  }

  /// Save granted URI to preferences
  Future<void> _saveGrantedUri(String uri) async {
    final prefs = await SharedPreferences.getInstance();
    final uris = prefs.getStringList('granted_uris') ?? [];
    if (!uris.contains(uri)) {
      uris.add(uri);
      await prefs.setStringList('granted_uris', uris);
    }
  }

  /// Get all granted URIs from preferences
  Future<List<String>> getGrantedUris() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList('granted_uris') ?? [];
  }

  /// Clear all granted URIs (for settings/reset)
  Future<void> clearAllAccess() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('granted_uris');
    _grantedUris.clear();
    await _platform.invokeMethod('releaseAllPermissions');
  }

  /// Check if a directory path is covered by any granted URI
  Future<bool> isDirectoryCovered(String dirPath) async {
    try {
      final bool covered = await _platform.invokeMethod('isDirectoryCovered', {
        'dirPath': dirPath,
      });
      return covered;
    } on PlatformException catch (e) {
      print('Error checking directory coverage: ${e.message}');
      return false;
    }
  }
}

class AudioMetadataService {
  static const MethodChannel _platform = MethodChannel(
    'com.mozmusic.app/metadata',
  );

  // Singleton pattern
  static final AudioMetadataService _instance =
      AudioMetadataService._internal();
  factory AudioMetadataService() => _instance;
  AudioMetadataService._internal();

  /// Read all metadata from an audio file
  Future<AudioMetadata> readMetadata(String filePath) async {
    try {
      final Map<dynamic, dynamic> result = await _platform.invokeMethod(
        'readMetadata',
        {'filePath': filePath},
      );
      return AudioMetadata.fromMap(Map<String, dynamic>.from(result));
    } on PlatformException catch (e) {
      throw MetadataException('Failed to read metadata: ${e.message}');
    }
  }

  /// Write metadata to an audio file
  Future<bool> writeMetadata(String filePath, AudioMetadata metadata) async {
    try {
      final result = await _platform.invokeMethod('writeMetadata', {
        'filePath': filePath,
        'metadata': metadata.toMap(),
      });
      return result == true;
    } on PlatformException catch (e) {
      throw MetadataException('Failed to write metadata: ${e.message}');
    }
  }

  /// Update specific metadata fields
  Future<bool> updateMetadata(
    String filePath,
    Map<String, dynamic> updates,
  ) async {
    try {
      final result = await _platform.invokeMethod('updateMetadata', {
        'filePath': filePath,
        'updates': updates,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw MetadataException('Failed to update metadata: ${e.message}');
    }
  }

  /// Extract album art from audio file
  Future<Uint8List?> extractAlbumArt(String filePath) async {
    try {
      final Uint8List? artBytes = await _platform.invokeMethod(
        'extractAlbumArt',
        {'filePath': filePath},
      );
      return artBytes;
    } on PlatformException catch (e) {
      throw MetadataException('Failed to extract album art: ${e.message}');
    }
  }

  /// Embed album art into audio file
  Future<bool> embedAlbumArt(String filePath, Uint8List imageBytes) async {
    try {
      final result = await _platform.invokeMethod('embedAlbumArt', {
        'filePath': filePath,
        'imageBytes': imageBytes,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw MetadataException('Failed to embed album art: ${e.message}');
    }
  }

  /// Remove album art from audio file
  Future<bool> removeAlbumArt(String filePath) async {
    try {
      final result = await _platform.invokeMethod('removeAlbumArt', {
        'filePath': filePath,
      });
      return result == true;
    } on PlatformException catch (e) {
      throw MetadataException('Failed to remove album art: ${e.message}');
    }
  }

  /// Get supported audio formats
  Future<List<String>> getSupportedFormats() async {
    try {
      final List<dynamic> formats = await _platform.invokeMethod(
        'getSupportedFormats',
      );
      return formats.map((e) => e.toString()).toList();
    } on PlatformException catch (e) {
      throw MetadataException('Failed to get supported formats: ${e.message}');
    }
  }
}

/// Audio metadata model
class AudioMetadata {
  String? title;
  String? artist;
  String? album;
  String? albumArtist;
  String? genre;
  int? year;
  int? trackNumber;
  int? trackTotal;
  int? discNumber;
  int? discTotal;
  String? composer;
  String? comment;
  String? lyrics;
  int? duration; // in milliseconds
  int? bitrate; // in kbps
  int? sampleRate; // in Hz
  String? mimeType;
  String? codec;

  AudioMetadata({
    this.title,
    this.artist,
    this.album,
    this.albumArtist,
    this.genre,
    this.year,
    this.trackNumber,
    this.trackTotal,
    this.discNumber,
    this.discTotal,
    this.composer,
    this.comment,
    this.lyrics,
    this.duration,
    this.bitrate,
    this.sampleRate,
    this.mimeType,
    this.codec,
  });

  factory AudioMetadata.fromMap(Map<String, dynamic> map) {
    return AudioMetadata(
      title: map['title'],
      artist: map['artist'],
      album: map['album'],
      albumArtist: map['albumArtist'],
      genre: map['genre'],
      year: map['year'],
      trackNumber: map['trackNumber'],
      trackTotal: map['trackTotal'],
      discNumber: map['discNumber'],
      discTotal: map['discTotal'],
      composer: map['composer'],
      comment: map['comment'],
      lyrics: map['lyrics'],
      duration: map['duration'],
      bitrate: map['bitrate'],
      sampleRate: map['sampleRate'],
      mimeType: map['mimeType'],
      codec: map['codec'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'artist': artist,
      'album': album,
      'albumArtist': albumArtist,
      'genre': genre,
      'year': year,
      'trackNumber': trackNumber,
      'trackTotal': trackTotal,
      'discNumber': discNumber,
      'discTotal': discTotal,
      'composer': composer,
      'comment': comment,
      'lyrics': lyrics,
      'duration': duration,
      'bitrate': bitrate,
      'sampleRate': sampleRate,
      'mimeType': mimeType,
      'codec': codec,
    }..removeWhere((key, value) => value == null);
  }

  AudioMetadata copyWith({
    String? title,
    String? artist,
    String? album,
    String? albumArtist,
    String? genre,
    int? year,
    int? trackNumber,
    int? trackTotal,
    int? discNumber,
    int? discTotal,
    String? composer,
    String? comment,
    String? lyrics,
  }) {
    return AudioMetadata(
      title: title ?? this.title,
      artist: artist ?? this.artist,
      album: album ?? this.album,
      albumArtist: albumArtist ?? this.albumArtist,
      genre: genre ?? this.genre,
      year: year ?? this.year,
      trackNumber: trackNumber ?? this.trackNumber,
      trackTotal: trackTotal ?? this.trackTotal,
      discNumber: discNumber ?? this.discNumber,
      discTotal: discTotal ?? this.discTotal,
      composer: composer ?? this.composer,
      comment: comment ?? this.comment,
      lyrics: lyrics ?? this.lyrics,
      duration: this.duration,
      bitrate: this.bitrate,
      sampleRate: this.sampleRate,
      mimeType: this.mimeType,
      codec: this.codec,
    );
  }

  @override
  String toString() {
    return 'AudioMetadata(title: $title, artist: $artist, album: $album)';
  }
}

/// Custom exception for metadata operations
class MetadataException implements Exception {
  final String message;
  MetadataException(this.message);

  @override
  String toString() => 'MetadataException: $message';
}

class MetadataEditorScreen extends StatefulWidget {
  final String audioFilePath;

  const MetadataEditorScreen({Key? key, required this.audioFilePath})
    : super(key: key);

  @override
  State<MetadataEditorScreen> createState() => _MetadataEditorScreenState();
}

class _MetadataEditorScreenState extends State<MetadataEditorScreen> {
  final AudioMetadataService _metadataService = AudioMetadataService();
  final SAFManager _safManager = SAFManager();
  final _formKey = GlobalKey<FormState>();

  AudioMetadata? _metadata;
  Uint8List? _albumArt;
  bool _isLoading = true;
  bool _isSaving = false;
  String? _errorMessage;
  bool _hasDirectoryAccess = false;

  // Controllers
  late TextEditingController _titleController;
  late TextEditingController _artistController;
  late TextEditingController _albumController;
  late TextEditingController _albumArtistController;
  late TextEditingController _genreController;
  late TextEditingController _yearController;
  late TextEditingController _trackNumberController;
  late TextEditingController _composerController;
  late TextEditingController _commentController;
  late TextEditingController _lyricsController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadMetadata();
  }

  void _initializeControllers() {
    _titleController = TextEditingController();
    _artistController = TextEditingController();
    _albumController = TextEditingController();
    _albumArtistController = TextEditingController();
    _genreController = TextEditingController();
    _yearController = TextEditingController();
    _trackNumberController = TextEditingController();
    _composerController = TextEditingController();
    _commentController = TextEditingController();
    _lyricsController = TextEditingController();
  }

  Future<void> _loadMetadata() async {
    try {
      final metadata = await _metadataService.readMetadata(
        widget.audioFilePath,
      );
      final albumArt = await _metadataService.extractAlbumArt(
        widget.audioFilePath,
      );

      setState(() {
        _metadata = metadata;
        _albumArt = albumArt;
        _populateControllers();
        _isLoading = false;
      });
    } on MetadataException catch (e) {
      setState(() {
        _errorMessage = e.message;
        _isLoading = false;
      });
    }
  }

  void _populateControllers() {
    if (_metadata == null) return;

    _titleController.text = _metadata!.title ?? '';
    _artistController.text = _metadata!.artist ?? '';
    _albumController.text = _metadata!.album ?? '';
    _albumArtistController.text = _metadata!.albumArtist ?? '';
    _genreController.text = _metadata!.genre ?? '';
    _yearController.text = _metadata!.year?.toString() ?? '';
    _trackNumberController.text = _metadata!.trackNumber?.toString() ?? '';
    _composerController.text = _metadata!.composer ?? '';
    _commentController.text = _metadata!.comment ?? '';
    _lyricsController.text = _metadata!.lyrics ?? '';
  }

  Future<void> _requestDirectoryAccess() async {
    final dirPath = _safManager.getParentDirectory(widget.audioFilePath);

    final granted = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Grant Folder Access'),
        content: Text(
          'To save changes, please select the folder containing your music files.\n\n'
          'Folder: $dirPath',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Select Folder'),
          ),
        ],
      ),
    );

    if (granted == true) {
      final uri = await _safManager.requestDirectoryAccess();
      if (uri != null) {
        setState(() {
          _hasDirectoryAccess = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder access granted! You can now save changes.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Folder access denied. Cannot save changes.'),
            backgroundColor: Colors.orange,
          ),
        );
      }
    }
  }

  Future<void> _saveMetadata() async {
    if (!_formKey.currentState!.validate()) return;

    // Check if we have directory access
    if (!_hasDirectoryAccess) {
      await _requestDirectoryAccess();

      // Recheck after requesting
      _hasDirectoryAccess = await _safManager.hasAccessToFile(
        widget.audioFilePath,
      );

      if (!_hasDirectoryAccess) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cannot save without folder access'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _isSaving = true);

    try {
      final updatedMetadata = AudioMetadata(
        title: _titleController.text.trim().isEmpty
            ? null
            : _titleController.text.trim(),
        artist: _artistController.text.trim().isEmpty
            ? null
            : _artistController.text.trim(),
        album: _albumController.text.trim().isEmpty
            ? null
            : _albumController.text.trim(),
        albumArtist: _albumArtistController.text.trim().isEmpty
            ? null
            : _albumArtistController.text.trim(),
        genre: _genreController.text.trim().isEmpty
            ? null
            : _genreController.text.trim(),
        year: int.tryParse(_yearController.text.trim()),
        trackNumber: int.tryParse(_trackNumberController.text.trim()),
        composer: _composerController.text.trim().isEmpty
            ? null
            : _composerController.text.trim(),
        comment: _commentController.text.trim().isEmpty
            ? null
            : _commentController.text.trim(),
        lyrics: _lyricsController.text.trim().isEmpty
            ? null
            : _lyricsController.text.trim(),
      );

      final success = await _metadataService.writeMetadata(
        widget.audioFilePath,
        updatedMetadata,
      );

      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Metadata saved successfully'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        throw MetadataException('Failed to save metadata');
      }
    } on MetadataException catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.message}'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _artistController.dispose();
    _albumController.dispose();
    _albumArtistController.dispose();
    _genreController.dispose();
    _yearController.dispose();
    _trackNumberController.dispose();
    _composerController.dispose();
    _commentController.dispose();
    _lyricsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Metadata'),
        actions: [
          if (!_isLoading && _errorMessage == null)
            IconButton(
              icon: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.save),
              onPressed: _isSaving ? null : _saveMetadata,
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(_errorMessage!),
                ],
              ),
            )
          : Column(
              children: [
                // Access status banner
                if (!_hasDirectoryAccess)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(12),
                    color: Colors.orange.shade100,
                    child: Row(
                      children: [
                        const Icon(Icons.warning, color: Colors.orange),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Folder access required to save changes',
                            style: TextStyle(color: Colors.orange.shade900),
                          ),
                        ),
                        TextButton(
                          onPressed: _requestDirectoryAccess,
                          child: const Text('Grant Access'),
                        ),
                      ],
                    ),
                  ),

                // Form content
                Expanded(
                  child: Form(
                    key: _formKey,
                    child: ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        _buildAlbumArtSection(),
                        const SizedBox(height: 24),
                        _buildTextField(
                          'Title',
                          _titleController,
                          Icons.music_note,
                        ),
                        _buildTextField(
                          'Artist',
                          _artistController,
                          Icons.person,
                        ),
                        _buildTextField('Album', _albumController, Icons.album),
                        _buildTextField(
                          'Album Artist',
                          _albumArtistController,
                          Icons.people,
                        ),
                        _buildTextField(
                          'Genre',
                          _genreController,
                          Icons.category,
                        ),
                        _buildTextField(
                          'Year',
                          _yearController,
                          Icons.calendar_today,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Track Number',
                          _trackNumberController,
                          Icons.numbers,
                          isNumber: true,
                        ),
                        _buildTextField(
                          'Composer',
                          _composerController,
                          Icons.edit_note,
                        ),
                        _buildTextField(
                          'Comment',
                          _commentController,
                          Icons.comment,
                          maxLines: 3,
                        ),
                        _buildTextField(
                          'Lyrics',
                          _lyricsController,
                          Icons.lyrics,
                          maxLines: 5,
                        ),
                        const SizedBox(height: 24),
                        if (_metadata != null) _buildFileInfo(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildAlbumArtSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _albumArt != null
                ? Image.memory(_albumArt!, height: 200, fit: BoxFit.cover)
                : Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Icon(Icons.music_note, size: 80),
                  ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    // TODO: Implement image picker
                  },
                  icon: const Icon(Icons.add_photo_alternate),
                  label: const Text('Change'),
                ),
                if (_albumArt != null)
                  OutlinedButton.icon(
                    onPressed: () async {
                      try {
                        if (!_hasDirectoryAccess) {
                          await _requestDirectoryAccess();
                          return;
                        }
                        await _metadataService.removeAlbumArt(
                          widget.audioFilePath,
                        );
                        setState(() => _albumArt = null);
                      } catch (e) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error removing album art: $e'),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Remove'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(
    String label,
    TextEditingController controller,
    IconData icon, {
    bool isNumber = false,
    int maxLines = 1,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon),
          border: const OutlineInputBorder(),
        ),
        keyboardType: isNumber ? TextInputType.number : TextInputType.text,
        maxLines: maxLines,
      ),
    );
  }

  Widget _buildFileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const Divider(),
            _buildInfoRow('Duration', _formatDuration(_metadata!.duration)),
            _buildInfoRow('Bitrate', '${_metadata!.bitrate} kbps'),
            _buildInfoRow('Sample Rate', '${_metadata!.sampleRate} Hz'),
            _buildInfoRow('Codec', _metadata!.codec ?? 'Unknown'),
            _buildInfoRow('Format', _metadata!.mimeType ?? 'Unknown'),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String? value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value ?? 'N/A'),
        ],
      ),
    );
  }

  String _formatDuration(int? milliseconds) {
    if (milliseconds == null) return 'N/A';
    final duration = Duration(milliseconds: milliseconds);
    final minutes = duration.inMinutes;
    final seconds = duration.inSeconds % 60;
    return '$minutes:${seconds.toString().padLeft(2, '0')}';
  }
}
