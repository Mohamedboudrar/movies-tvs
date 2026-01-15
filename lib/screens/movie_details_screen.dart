import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/movie_model.dart';
import '../services/tmdb_api_service.dart';


class MovieDetailsScreen extends StatefulWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  State<MovieDetailsScreen> createState() => _MovieDetailsScreenState();
}

class _MovieDetailsScreenState extends State<MovieDetailsScreen> {
  final TmdbApiService _apiService = TmdbApiService();
  YoutubePlayerController? _youtubeController;
  bool _isLoadingTrailer = true;
  bool _hasTrailer = false;

  @override
  void initState() {
    super.initState();
    _loadTrailer();
  }


  Future<void> _loadTrailer() async {
    debugPrint('🎬 [Trailer] Loading trailer for movie ID: ${widget.movie.id}');

    try {
      final trailerKey =
      await _apiService.getMovieTrailer(widget.movie.id);

      debugPrint('📦 [Trailer] TMDB returned key: $trailerKey');

      if (!mounted) {
        debugPrint('⚠️ [Trailer] Widget not mounted anymore');
        return;
      }

      if (trailerKey == null || trailerKey.isEmpty) {
        debugPrint('❌ [Trailer] No trailer key available');

        setState(() {
          _hasTrailer = false;
          _isLoadingTrailer = false;
        });
        return;
      }

      debugPrint('✅ [Trailer] Using videoId: $trailerKey');

      final controller = YoutubePlayerController(
        initialVideoId: trailerKey,
        flags: const YoutubePlayerFlags(
          autoPlay: false,
          mute: false,
        ),
      );

      debugPrint('🎮 [Trailer] YoutubePlayerController created');

      setState(() {
        _youtubeController = controller;
        _hasTrailer = true;
        _isLoadingTrailer = false;
      });
    } catch (e, stackTrace) {
      debugPrint('💥 [Trailer] Exception occurred');
      debugPrint('Error: $e');
      debugPrint('StackTrace: $stackTrace');

      if (mounted) {
        setState(() {
          _hasTrailer = false;
          _isLoadingTrailer = false;
        });
      }
    }
  }


  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                widget.movie.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 3.0,
                      color: Color.fromARGB(255, 0, 0, 0),
                    ),
                  ],
                ),
              ),
              background: widget.movie.backdropPath != null
                  ? Stack(
                      fit: StackFit.expand,
                      children: [
                        Image.network(
                          widget.movie.backdropUrl,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return Container(
                              color: Colors.deepPurple,
                              child: const Center(
                                child: Icon(Icons.movie, size: 80),
                              ),
                            );
                          },
                        ),
                        Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                              colors: [
                                Colors.transparent,
                                Colors.black.withOpacity(0.7),
                              ],
                            ),
                          ),
                        ),
                      ],
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.movie, size: 80),
                      ),
                    ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      if (widget.movie.posterPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.movie.posterUrl,
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                width: 120,
                                height: 180,
                                color: Colors.grey[300],
                                child: const Icon(Icons.movie),
                              );
                            },
                          ),
                        ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.star,
                                    color: Colors.amber, size: 24),
                                const SizedBox(width: 4),
                                Text(
                                  widget.movie.voteAverage.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const Text(
                                  ' / 10',
                                  style: TextStyle(
                                    fontSize: 16,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                const Icon(Icons.calendar_today, size: 16),
                                const SizedBox(width: 4),
                                Text(
                                  widget.movie.releaseDate,
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (_isLoadingTrailer)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else if (_hasTrailer && _youtubeController != null)
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Bande-annonce',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: YoutubePlayer(
                            controller: _youtubeController!,
                            showVideoProgressIndicator: true,
                            progressIndicatorColor: Colors.red,
                            onReady: () {
                              debugPrint('▶️ [Trailer] Player ready');
                            },
                            onEnded: (data) {
                              debugPrint('⏹️ [Trailer] Video ended: ${data.videoId}');
                            },
                          )


                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  else
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.grey[200],
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.info_outline, color: Colors.grey),
                              SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  'Aucune bande-annonce disponible',
                                  style: TextStyle(color: Colors.grey),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    ),
                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.movie.overview.isNotEmpty
                        ? widget.movie.overview
                        : 'Aucun synopsis disponible.',
                    style: const TextStyle(
                      fontSize: 16,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
