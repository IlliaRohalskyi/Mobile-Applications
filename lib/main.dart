import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyScreen(),
    );
  }
}

class MyScreen extends StatefulWidget {
  const MyScreen({super.key});
  final String movieUri =
      'https://670ef2d6-dbdd-454c-b4d7-6960afb18cc2.mock.pstmn.io/movies';

  @override
  State<MyScreen> createState() => _MyHttpWidgetState();
}

class Movie {
  final String title;
  final String director;
  final List<String> images;

  Movie({required this.title, required this.director, required this.images});

  factory Movie.fromJson(Map<String, dynamic> json) {
    return Movie(
      title: json['Title'],
      director: json['Director'],
      images: json['Images'] != null
          ? (json['Images'] as List).cast<String>()
          : const [],
    );
  }

  Map<String, dynamic> toJson() => {
        'Title': title,
        'Director': director,
      };
}

class MovieListTile extends StatelessWidget {
  final Movie movie;

  const MovieListTile({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MovieDetailsScreen(movie: movie),
        ),
      ),
      child: ListTile(
        leading: movie.images.isNotEmpty
            ? CircleAvatar(
                backgroundImage: NetworkImage(movie.images.first),
              )
            : const Icon(Icons.movie),
        title: Text(movie.title),
        subtitle: Text(movie.director),
      ),
    );
  }
}

class _MyHttpWidgetState extends State<MyScreen> {
  final movieUri =
      'https://670ef2d6-dbdd-454c-b4d7-6960afb18cc2.mock.pstmn.io/movies';
  List<Movie> movies = [];

  Future<List<Movie>> _loadMovies() async {
    final response = await http.get(Uri.parse(widget.movieUri));
    var returnValue = <Movie>[];

    if (response.statusCode == 200) {
      final movies = jsonDecode(response.body) as List;
      returnValue = List.generate(movies.length,
          (index) => Movie.fromJson(movies[index] as Map<String, dynamic>));
    }
    return returnValue;
  }

  @override
  void initState() {
    super.initState();
    _loadMovies().then((data) => setState(() => movies = data));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Movies'),
      ),
      body: ListView.builder(
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return MovieListTile(movie: movie);
        },
      ),
    );
  }
}

class MovieDetailsScreen extends StatelessWidget {
  final Movie movie;

  const MovieDetailsScreen({super.key, required this.movie});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(movie.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Title: ${movie.title}'),
            const SizedBox(height: 16.0),
            Text('Director: ${movie.director}'),
          ],
        ),
      ),
    );
  }
}
