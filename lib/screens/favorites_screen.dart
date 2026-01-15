import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../services/favorite_service.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_card.dart';
import 'favourite_search_delegate.dart';

class FavouritesScreen extends StatefulWidget {
  const FavouritesScreen({super.key});

  @override
  State<FavouritesScreen> createState() => _FavouritesScreenState();
}

class _FavouritesScreenState extends State<FavouritesScreen> {
  final FavouritesService _favService = FavouritesService();
  final TmdbApiService _apiService = TmdbApiService();

  bool _isLoading = true;
  String? _error;

  List<Movie> _movies = [];
  List<TvSeries> _tvSeries = [];

  @override
  void initState() {
    super.initState();
    _loadFavourites();
  }

  Future<void> _loadFavourites() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final snapshot = await _favService.getFavourites().first;

      final movies = <Movie>[];
      final tvs = <TvSeries>[];

      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final int id = data['id'];
        final String type = data['type'];

        if (type == 'movie') {
          movies.add(await _apiService.getMovieDetails(id));
        } else if (type == 'tv') {
          tvs.add(await _apiService.getTvSeriesDetails(id));
        }
      }

      if (!mounted) return;

      setState(() {
        _movies = movies;
        _tvSeries = tvs;
        _isLoading = false;
      });
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes favoris'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: FavouriteSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline,
                size: 60, color: Colors.red),
            const SizedBox(height: 16),
            Text('Erreur: $_error'),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _loadFavourites,
              child: const Text('Réessayer'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadFavourites,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (_movies.isNotEmpty) ...[
              const Text(
                'Films favoris',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _movies.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin:
                      const EdgeInsets.only(right: 12),
                      child: MovieCard(
                        movie: _movies[index],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 32),
            ],

            if (_tvSeries.isNotEmpty) ...[
              const Text(
                'Séries TV favorites',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                height: 280,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _tvSeries.length,
                  itemBuilder: (context, index) {
                    return Container(
                      width: 160,
                      margin:
                      const EdgeInsets.only(right: 12),
                      child: TvCard(
                        tvSeries: _tvSeries[index],
                      ),
                    );
                  },
                ),
              ),
            ],

            if (_movies.isEmpty && _tvSeries.isEmpty)
              const Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 80),
                  child: Text(
                    'Aucun favori ⭐',
                    style: TextStyle(fontSize: 18),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/* ======================================================================
   FavouriteCard
   SAME FILE • NO EXTRA FILE • REUSABLE IN SEARCH
   ====================================================================== */

class FavouriteCard extends StatelessWidget {
  final String posterPath;
  final String title;
  final String type; // movie | tv
  final VoidCallback onTap;

  const FavouriteCard({
    super.key,
    required this.posterPath,
    required this.title,
    required this.type,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(12),
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius:
                const BorderRadius.vertical(top: Radius.circular(12)),
                child: posterPath.isNotEmpty
                    ? Image.network(
                  'https://image.tmdb.org/t/p/w500$posterPath',
                  fit: BoxFit.cover,
                  width: double.infinity,
                  errorBuilder: (_, __, ___) =>
                      _fallbackPoster(type),
                )
                    : _fallbackPoster(type),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Icon(
                        type == 'movie' ? Icons.movie : Icons.tv,
                        size: 14,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Text(
                        type == 'movie' ? 'Film' : 'Série TV',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _fallbackPoster(String type) {
    return Container(
      color: Colors.grey[300],
      child: Center(
        child: Icon(
          type == 'movie' ? Icons.movie : Icons.tv,
          size: 50,
          color: Colors.grey[700],
        ),
      ),
    );
  }
}
