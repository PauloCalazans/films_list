import 'dart:convert';

import 'package:films_list/model/movie.dart';
import 'package:films_list/model/movie_detail.dart';
import 'package:http/http.dart' as http;

final timeout = Duration(seconds: 60);
int totalResults = 10;

class Repository {

  Future<List<Movie>> lisMovie(String movie, int page) async {

    final List<Movie> listResponse = List();
    final url = "http://www.omdbapi.com/?apikey=27b47c25&s=$movie&page=$page"; // url base

    try {
      final response = await http.get(
        url, // url base
        headers: <String, String>{
          "Content-type": "application/json",
          "Accept": "application/json",
          //Coloque aqui a autenticação caso haja
        },
      ).timeout(timeout);

      if(jsonDecode(response.body)['Response'] == 'True') {

        final aux = jsonDecode(response.body)['Search'] as List;

        for(int i = 0; i < aux.length; i++) {
          listResponse.add(Movie.fromMap(aux[i]));
        }

        return listResponse;
      }

      return null;

    } catch (e) {
      print('Erro na busca dos filmes $e');
      return null;
    }

  }

  Future<MovieDetails> movieDetails(String imdbID) async {

    try {

      final response = await http.get(
        "http://www.omdbapi.com/?apikey=27b47c25&i=$imdbID&plot=full", // url base
        headers: <String, String>{
          "Content-type": "application/json",
          "Accept": "application/json",
          //Coloque aqui a autenticação caso haja
        },
      ).timeout(timeout);

      if(jsonDecode(response.body)['Response'] == 'True') {
        return MovieDetails.fromMap(jsonDecode(response.body));
      }

      return null;
    } catch(e) {
      print('Erro ao buscar por ID $e');
      return null;
    }

  }
}