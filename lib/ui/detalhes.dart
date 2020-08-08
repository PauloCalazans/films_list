import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

class Detalhes extends StatefulWidget {
  final String imdbID;

  const Detalhes({Key key, this.imdbID}) : super(key: key);

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<Detalhes> {

  MovieDetails _movieDetails;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  _doInit() async {
    final movie = await _popularList();
    setState(() {
      _movieDetails = movie;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<MovieDetails> _popularList() async {
    final timeout = Duration(seconds: 60);
    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      "http://www.omdbapi.com/?apikey=27b47c25&i=${widget.imdbID}&plot=full", // url base
      headers: <String, String>{
        "Content-type": "application/json",
        "Accept": "application/json",
        //Coloque aqui a autenticação caso haja
      },
    ).timeout(timeout).catchError((err) {
      print('Erro na busca dos filmes $err');
      return null;
    });

    MovieDetails vo = new MovieDetails();
    vo.title = jsonDecode(response.body)['Title'];
    vo.year = int.tryParse(jsonDecode(response.body)['Year']);
    vo.imdbID = jsonDecode(response.body)['imdbID'];
    vo.type = jsonDecode(response.body)['Type'];
    vo.poster = jsonDecode(response.body)['Poster'];
    vo.genre = jsonDecode(response.body)['Genre'];
    vo.actors = jsonDecode(response.body)['Actors'];
    vo.released = jsonDecode(response.body)['Released'];
    vo.plot = jsonDecode(response.body)['Plot'];
    vo.country = jsonDecode(response.body)['Country'];
    vo.production = jsonDecode(response.body)['Production'];
    vo.director = jsonDecode(response.body)['Director'];

    setState(() {
      _isLoading = false;
    });

    return vo;
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Detalhes';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent, strokeWidth: 5,))
      : Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0, left: 8.0),
                        child: CachedNetworkImage(
                          height: MediaQuery.of(context).size.height * .45,
                          fit: BoxFit.fitHeight,
                          imageUrl: _movieDetails.poster,
                          placeholder: (context, url) => const CircularProgressIndicator(backgroundColor: Colors.blueAccent,),
                          errorWidget: (context, url, error) => Center(child: Icon(Icons.movie_filter, size: 120,)),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Text('Título: ${_movieDetails.title}'),
                            SizedBox(height: 4.0,),
                            Text('Ano: ${_movieDetails.year}'),
                            SizedBox(height: 4.0,),
                            Text('Tipo: ${_movieDetails.type}'),
                            SizedBox(height: 4.0,),
                            Text('Ators: ${_movieDetails.actors}'),
                            SizedBox(height: 4.0,),
                            Text('Diretor: ${_movieDetails.director}'),
                            SizedBox(height: 4.0,),
                            Text('País: ${_movieDetails.country}'),
                            SizedBox(height: 4.0,),
                            Text('Produtora: ${_movieDetails.production}'),
                            SizedBox(height: 4.0,),
                            Text('Gênero: ${_movieDetails.genre}'),
                            SizedBox(height: 4.0,),
                            Text('Sinopse: ${_movieDetails.plot}', textAlign: TextAlign.justify,),
                          ],
                        ),
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


class MovieDetails {
  String title;
  int year;
  String released;
  String runtime;
  String genre;
  String director;
  String writter;
  String actors;
  String plot;
  String country;
  String imdbID;
  String type;
  String poster;
  String production;

  MovieDetails({
      this.title,
      this.year,
      this.released,
      this.runtime,
      this.genre,
      this.director,
      this.writter,
      this.actors,
      this.plot,
      this.country,
      this.imdbID,
      this.type,
      this.poster,
      this.production});
}