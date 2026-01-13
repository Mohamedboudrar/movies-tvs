import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/movie_model.dart';
import '../models/tv_model.dart';
import '../services/tmdb_api_service.dart';
import '../widgets/movie_card.dart';
import '../widgets/tv_card.dart';
import 'favorites_screen.dart';
import 'login_screen.dart';
import 'search_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
          (route) => false,
    );
  }

  final TmdbApiService _apiService = TmdbApiService();
  List<Movie> _movies = [];
  List<TvSeries> _tvSeries = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final movies = await _apiService.getPopularMovies();
      final tvSeries = await _apiService.getPopularTvSeries();

      setState(() {
        _movies = movies;
        _tvSeries = tvSeries;
        _isLoading = false;
      });
    } catch (e) {
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
        title: const Text('Cinéma & Séries TV'),
        backgroundColor: Colors.deepPurple,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SearchScreen(),
                ),
              );
            },
          ),
        ],
      ),
      drawer: Drawer(
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.zero,
        ),
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.deepPurple,
              ),
              child: const Text(
                'Menu',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('Mon profil'),
              onTap: () {
                Navigator.pop(context); // close drawer
                /*Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ProfileScreen(),
                  ),
                );*/
              },
              trailing: Icon(Icons.arrow_right_rounded),
            ),

            ListTile(
              leading: const Icon(Icons.favorite),
              title: const Text('Mes favoris'),
              onTap: () {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const FavouritesScreen(),
                  ),
                );
              },
              trailing: Icon(Icons.arrow_right_rounded),
            ),

            const Divider(),

            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Déconnexion',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await _logout(context);
              },

            ),

          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error != null
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.error_outline, size: 60, color: Colors.red),
                      const SizedBox(height: 16),
                      Text('Erreur: $_error'),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: _loadData,
                        child: const Text('Réessayer'),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadData,
                  child: ListView(
                    padding: const EdgeInsets.all(16),
                    children: [
                      // Movies section
                      const Text(
                        'Films Populaires',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: _movies.isEmpty
                            ? const Center(child: Text('Aucun film disponible'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _movies.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: MovieCard(movie: _movies[index]),
                                  );
                                },
                              ),
                      ),
                      const SizedBox(height: 32),

                      // TV Series section
                      const Text(
                        'Séries TV Populaires',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 280,
                        child: _tvSeries.isEmpty
                            ? const Center(child: Text('Aucune série disponible'))
                            : ListView.builder(
                                scrollDirection: Axis.horizontal,
                                itemCount: _tvSeries.length,
                                itemBuilder: (context, index) {
                                  return Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    child: TvCard(tvSeries: _tvSeries[index]),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
    );
  }
}
