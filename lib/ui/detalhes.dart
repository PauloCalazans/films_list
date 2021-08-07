import 'package:cached_network_image/cached_network_image.dart';
import 'package:films_list/model/movie_detail.dart';
import 'package:films_list/repository/repository.dart';
import 'package:flutter/material.dart';

class Detalhes extends StatefulWidget {
  final String? imdbID;

  Detalhes({required this.imdbID});

  @override
  _MyPageState createState() => _MyPageState();
}

class _MyPageState extends State<Detalhes> {

  MovieDetails _movieDetails = MovieDetails();
  bool _isLoading = false;

  final Repository repository = Repository();

  @override
  void initState() {
    super.initState();
    if(mounted) {
      _doInit();
    }
  }

  _doInit() async {
    setState(() {
      _isLoading = true;
    });

    final aux = await repository.movieDetails(widget.imdbID);

    setState(() { //atribui valor e finaliza o loading
      _movieDetails = aux;
      _isLoading = false;
    });

  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final String title = 'Detalhes';
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Visibility(
        visible: _isLoading,
        child: Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent[100], strokeWidth: 5,)),
        replacement: Center(
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
                            imageUrl: _movieDetails.poster ?? '',
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
      )
    );
  }
}