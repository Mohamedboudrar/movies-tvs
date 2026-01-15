import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../services/favorite_service.dart';
import '../services/tmdb_api_service.dart';
import 'favorites_screen.dart';
import 'movie_details_screen.dart';
import 'tv_details_screen.dart';

class FavouriteSearchDelegate extends SearchDelegate {
  final FavouritesService _favService = FavouritesService();
  final TmdbApiService _apiService = TmdbApiService();

  @override
  String get searchFieldLabel => 'Rechercher dans les favoris';

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) => _buildSearchResults(context);

  @override
  Widget buildSuggestions(BuildContext context) => _buildSearchResults(context);

  Widget _buildSearchResults(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _favService.getFavourites(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }

        final results = snapshot.data!.docs.where((doc) {
          final title = (doc['title'] as String).toLowerCase();
          return title.contains(query.toLowerCase());
        }).toList();

        if (results.isEmpty) {
          return const Center(child: Text('Aucun résultat'));
        }

        return GridView.builder(
          padding: const EdgeInsets.all(16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            childAspectRatio: 0.62,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: results.length,
          itemBuilder: (context, index) {
            final doc = results[index];
            final data = doc.data() as Map<String, dynamic>;

            return FavouriteCard(
              posterPath: data['posterPath'],
              title: data['title'],
              type: data['type'],
              onTap: () async {
                final int id = data['id'];

                if (data['type'] == 'movie') {
                  final Movie movie =
                  await _apiService.getMovieDetails(id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          MovieDetailsScreen(movie: movie),
                    ),
                  );
                } else {
                  final TvSeries tv =
                  await _apiService.getTvSeriesDetails(id);

                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) =>
                          TvDetailsScreen(tvSeries: tv),
                    ),
                  );
                }
              },
            );
          },
        );
      },
    );
  }
}
