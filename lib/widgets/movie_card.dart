import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../screens/movie_details_screen.dart';
import '../services/favorite_service.dart';

class MovieCard extends StatefulWidget {
  final Movie movie;

  const MovieCard({super.key, required this.movie});

  @override
  State<MovieCard> createState() => _MovieCardState();
}

class _MovieCardState extends State<MovieCard>
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
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
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
      await _favouritesService.removeFavourite(widget.movie.id);
    } else {
      await _favouritesService.addFavourite(
        id: widget.movie.id,
        title: widget.movie.title,
        posterPath: widget.movie.posterPath ?? '',
        type: 'movie',
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
                MovieDetailsScreen(movie: widget.movie),
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
                    child: widget.movie.posterPath != null
                        ? Image.network(
                      widget.movie.posterUrl,
                      fit: BoxFit.cover,
                      width: double.infinity,
                      errorBuilder: (_, __, ___) {
                        return _fallbackPoster();
                      },
                    )
                        : _fallbackPoster(),
                  ),

                  /// ❤️ FIRESTORE FAVOURITE BUTTON
                  Positioned(
                    top: 8,
                    right: 8,
                    child: StreamBuilder<bool>(
                      stream: _favouritesService
                          .isFavourite(widget.movie.id),
                      builder: (context, snapshot) {
                        final isFav = snapshot.data ?? false;

                        return GestureDetector(
                          onTap: () => _toggleFavorite(isFav),
                          child: ScaleTransition(
                            scale: _scaleAnimation,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.5),
                                shape: BoxShape.circle,
                              ),
                              child: Icon(
                                isFav
                                    ? Icons.favorite
                                    : Icons.favorite_border,
                                color:
                                isFav ? Colors.red : Colors.white,
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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.movie.title,
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
                          color: Colors.amber, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.movie.voteAverage
                            .toStringAsFixed(1),
                        style: const TextStyle(fontSize: 12),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    widget.movie.releaseDate,
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
        child: Icon(Icons.movie, size: 50),
      ),
    );
  }
}
