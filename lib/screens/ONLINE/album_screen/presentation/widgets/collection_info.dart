import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:moz_updated_version/core/helper/cubit/player_settings_cubit.dart';
import 'package:moz_updated_version/core/helper/snackbar_helper.dart';
import 'package:moz_updated_version/core/utils/online_playback_repo/audio_playback_repository.dart';
import 'package:moz_updated_version/data/firebase/logic/playlist/playlist_cubit.dart';
import 'package:moz_updated_version/data/model/online_models/artist_model.dart';
import 'package:moz_updated_version/data/model/online_models/online_song_model.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/cubit/collection_cubit.dart';
import 'package:moz_updated_version/screens/ONLINE/album_screen/presentation/ui/collection_screen.dart';

import 'package:moz_updated_version/services/audio_handler.dart';
import 'package:moz_updated_version/services/core/app_services.dart';
import 'package:moz_updated_version/widgets/custom_cached_image.dart';

class CollectionInfo extends StatefulWidget {
  final String title;
  final String subtitle;
  final List<OnlineSongModel> songs;
  final ArtistModelOnline? artist;

  const CollectionInfo({
    super.key,
    required this.title,
    required this.subtitle,
    required this.songs,
    this.artist,
  });

  @override
  State<CollectionInfo> createState() => _CollectionInfoState();
}

class _CollectionInfoState extends State<CollectionInfo>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final totalDuration = widget.songs.fold<int>(0, (sum, song) {
      return sum + (int.tryParse(song.duration ?? '0') ?? 0);
    });

    final hours = totalDuration ~/ 3600;
    final minutes = (totalDuration % 3600) ~/ 60;
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final isArtist = widget.artist != null;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Flexible(
                child: Text(
                  widget.title,
                  style: theme.textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.w900,
                    letterSpacing: -0.5,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              if (isArtist && widget.artist!.isVerified) ...[
                const SizedBox(width: 8),
                const Icon(Icons.verified, color: Colors.white, size: 20),
              ],
            ],
          ),
          const SizedBox(height: 8),

          Text(
            widget.subtitle,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
              fontSize: 15,
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.7),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),

          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildStatChip(
                context,
                Icons.music_note_rounded,
                '${widget.songs.length} songs',
                isDark,
                theme,
              ),
              const SizedBox(width: 8),
              _buildStatChip(
                context,
                Icons.access_time_rounded,
                hours > 0 ? '${hours}h ${minutes}m' : '${minutes}m',
                isDark,
                theme,
              ),
            ],
          ),

          if (isArtist) ...[
            const SizedBox(height: 16),
            _buildArtistInfoSection(context, isDark, theme),
          ],
          if (!isArtist) SizedBox(height: 16),
          SizedBox(
            height: 56,
            child: Row(
              children: [
                Expanded(
                  flex: 3,
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          theme.primaryColor,
                          theme.primaryColor.withValues(alpha: 0.8),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(28),
                      boxShadow: [
                        BoxShadow(
                          color: theme.primaryColor.withValues(alpha: 0.3),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: ElevatedButton(
                      onPressed: widget.songs.isEmpty
                          ? null
                          : () {
                              sl<AudioPlaybackRepository>().playOnlineSong(
                                widget.songs.cast<OnlineSongModel>(),
                                startIndex: 0,
                              );
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(28),
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.play_arrow_rounded,
                            color: isDark ? Colors.white : Colors.white,
                            size: 28,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            "Play All",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: BlocBuilder<PlayerSettingsCubit, PlayerSettingsState>(
                    builder: (context, state) {
                      return IconButton(
                        onPressed: widget.songs.isEmpty
                            ? null
                            : () async {
                                final handler = sl<MozAudioHandler>();
                                final cubit = context
                                    .read<PlayerSettingsCubit>();
                                cubit.toggleShuffle();

                                final isPlaying =
                                    handler.audioSessionId != null &&
                                    handler.playbackState.value.playing;

                                if (isPlaying) return;

                                await sl<AudioPlaybackRepository>()
                                    .playOnlineSong(
                                      widget.songs.cast<OnlineSongModel>(),
                                      startIndex: 0,
                                    );
                              },
                        icon: Icon(
                          CupertinoIcons.shuffle,
                          color: state.shuffle
                              ? theme.primaryColor
                              : Colors.grey,
                          size: 24,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.15)
                        : Colors.black.withValues(alpha: 0.08),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isDark
                          ? Colors.white.withValues(alpha: 0.2)
                          : Colors.black.withValues(alpha: 0.1),
                      width: 1.5,
                    ),
                  ),
                  child: IconButton(
                    onPressed: () {
                      _showMoreOptions(context);
                    },
                    icon: Icon(
                      Icons.more_horiz_rounded,
                      color: theme.primaryColor,
                      size: 24,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtistInfoSection(
    BuildContext context,
    bool isDark,
    ThemeData theme,
  ) {
    final artist = widget.artist!;

    return Column(
      children: [
        if (artist.availableLanguages.isNotEmpty) ...[
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 6,
            runSpacing: 6,
            children: artist.availableLanguages.take(4).map((lang) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.12)
                      : Colors.black.withValues(alpha: 0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: theme.primaryColor.withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Text(
                  lang.toUpperCase(),
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: theme.primaryColor,
                    letterSpacing: 0.5,
                  ),
                ),
              );
            }).toList(),
          ),
        ],

        if (artist.topAlbums != null && artist.topAlbums!.isNotEmpty) ...[
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: artist.topAlbums!.take(5).length,
              itemBuilder: (context, index) {
                final album = artist.topAlbums![index];
                return Padding(
                  padding: EdgeInsets.only(
                    left: index == 0 ? 0 : 8,
                    right: index == artist.topAlbums!.length - 1 ? 0 : 8,
                  ),
                  child: InkWell(
                    overlayColor: WidgetStateProperty.all(Colors.transparent),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => BlocProvider(
                            create: (context) =>
                                CollectionCubitForOnline()
                                  ..loadAlbum(album.id, "album"),
                            child: const OnlineAlbumScreen(),
                          ),
                        ),
                      );
                    },
                    child: Column(
                      children: [
                        Container(
                          width: 70,
                          height: 70,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(8),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.2),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: CustomCachedImage(imageUrl: album.image!),
                          ),
                        ),
                        const SizedBox(height: 4),
                        SizedBox(
                          width: 70,
                          child: Text(
                            album.year ?? '',
                            style: theme.textTheme.bodySmall?.copyWith(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                            textAlign: TextAlign.center,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStatChip(
    BuildContext context,
    IconData icon,
    String label,
    bool isDark,
    ThemeData theme,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.1)
            : Colors.black.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: theme.colorScheme.primary),
          const SizedBox(width: 6),
          Text(
            label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  void _showMoreOptions(BuildContext context) {
    AppSnackBar.info(context, "This option will available soon");
  }
}
