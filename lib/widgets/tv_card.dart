import 'package:flutter/material.dart';
import '../models/tv_model.dart';
import '../screens/tv_details_screen.dart';
import '../services/favorite_service.dart';

class TvCard extends StatefulWidget {
  final TvSeries tvSeries;

  const TvCard({super.key, required this.tvSeries});

  @override
  State<TvCard> createState() => _TvCardState();
}

class _TvCardState extends State<TvCard>
    with SingleTickerProviderStateMixin {
  final FavouritesService _favouritesService = FavouritesService();

  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.3).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOut,
      ),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _toggleFavorite(bool isFav) async {
    _animationController.forward().then((_) {
      _animationController.reverse();
    });

    if (isFav) {
      await _favouritesService
          .removeFavourite(widget.tvSeries.id);
    } else {
      await _favouritesService.addFavourite(
        id: widget.tvSeries.id,
        title: widget.tvSeries.name,
        posterPath: widget.tvSeries.posterPath ?? '',
        type: 'tv',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) =>
                TvDetailsScreen(tvSeries: widget.tvSeries),
          ),
        );
      },
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Stack(
                children: [
                  ClipRRect(
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(12),
                    ),
                    child: widget.tvSeries.posterPath != null
                        ? Image.network(
                      widget.tvSeries.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) =>
                          _fallbackPoster(),
                    )
                        : _fallbackPoster(),
                  ),

                  /// ❤️ FIRESTORE FAVOURITE BUTTON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: _favouritesService
                          .isFavourite(widget.tvSeries.id),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;

                        return GestureDetector(
                          onTap: () => _toggleFavorite(isFav),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding:
                              const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black
                                    .withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color: isFav
                                    ? Colors.red
                                    : Colors.white,
                                size: 24,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),

            /// INFO
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment:
                CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.tvSeries.name,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.star,
                          color: Colors.amber,
                          size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.tvSeries.voteAverage
                            .toStringAsFixed(1),
                        style: const TextStyle(
                            fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.tvSeries.firstAirDate,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey[600],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackPoster() {
    return Container(
      color: Colors.grey[300],
      child: const Center(
        child: Icon(Icons.tv, size: 50),
      ),
    );
  }
}
