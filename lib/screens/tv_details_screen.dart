import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../models/tv_model.dart';
import '../services/tmdb_api_service.dart';

class TvDetailsScreen extends StatefulWidget {
  final TvSeries tvSeries;

  const TvDetailsScreen({super.key, required this.tvSeries});

  @override
  State<TvDetailsScreen> createState() => _TvDetailsScreenState();
}

class _TvDetailsScreenState extends State<TvDetailsScreen> {
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
    debugPrint('📺 [Trailer] Loading TV trailer for ID: ${widget.tvSeries.id}');

    try {
      final trailerKey =
      await _apiService.getTvSeriesTrailer(widget.tvSeries.id);

      debugPrint('📦 [Trailer] TMDB returned key: $trailerKey');

      if (!mounted || trailerKey == null || trailerKey.isEmpty) {
        debugPrint('❌ [Trailer] No trailer available');

        setState(() {
          _hasTrailer = false;
          _isLoadingTrailer = false;
        });
        return;
      }

      debugPrint('✅ [Trailer] Using videoId: $trailerKey');

      setState(() {
        _youtubeController = YoutubePlayerController(
          initialVideoId: trailerKey, // TMDB key == YouTube video ID
          flags: const YoutubePlayerFlags(
            autoPlay: false,
            mute: false,
          ),
        );
        _hasTrailer = true;
        _isLoadingTrailer = false;
      });
    } catch (e, stackTrace) {
      debugPrint('💥 [Trailer] Error loading TV trailer');
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
    debugPrint('🧹 [Trailer] Disposing TV YoutubePlayerController');
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
                widget.tvSeries.name,
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
              background: widget.tvSeries.backdropPath != null
                  ? Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.tvSeries.backdropUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      color: Colors.grey[300],
                      child: const Center(
                        child: Icon(Icons.tv, size: 70),
                      ),
                    ),
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
                  child: Icon(Icons.tv, size: 80),
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
                      if (widget.tvSeries.posterPath != null)
                        ClipRRect(
                          borderRadius: BorderRadius.circular(12),
                          child: Image.network(
                            widget.tvSeries.posterUrl,
                            width: 120,
                            height: 180,
                            fit: BoxFit.cover,
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
                                  widget.tvSeries.voteAverage
                                      .toStringAsFixed(1),
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
                                  widget.tvSeries.firstAirDate,
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
                    const Center(child: CircularProgressIndicator())
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
                            onReady: () => debugPrint(
                                '▶️ [Trailer] TV player ready'),
                          ),
                        ),
                        const SizedBox(height: 24),
                      ],
                    )
                  else
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

                  const Text(
                    'Synopsis',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    widget.tvSeries.overview.isNotEmpty
                        ? widget.tvSeries.overview
                        : 'Aucun synopsis disponible.',
                    style: const TextStyle(fontSize: 16, height: 1.5),
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
