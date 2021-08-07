import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:films_list/model/movie.dart';
import 'package:films_list/repository/repository.dart';
import 'package:films_list/ui/detalhes.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomePage> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  late SharedPreferences _mPrefs;
  String? _movieFiltered = "";

  List<Movie>? _listMovieAux;
  int _pages = 1;

  final _searchController = TextEditingController();
  final Repository repository = Repository();

  final StreamController<List<Movie>?> _stream = StreamController();

  final ScrollController _scrollController =  ScrollController();

  @override
  void initState() {
    _doInit();
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
    _stream.close();
  }

  _doInit() async {
    _mPrefs  = await _prefs;
    _movieFiltered = _mPrefs.getString("movieFiltered");

    if(_movieFiltered == null || _movieFiltered!.isEmpty) {
      _movieFiltered = "avengers";
      await _mPrefs.setString("movieFiltered", _movieFiltered!);
    }

    _searchController.text = _movieFiltered!;
    final aux = await repository.lisMovie(_movieFiltered, _pages);
    _stream.add(aux); // preenche a lista

    _scrollController..addListener(() async {
      if(_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
        _pages++;
        final aux = await repository.lisMovie(_movieFiltered, _pages);

        _listMovieAux!.addAll(aux.map((e) => e)); // adiciona os filmes à lista
        _stream.add(_listMovieAux); // incrementa a lista
      }
    });

  }

  _searchMovie(String title) async {

    if(title.length > 1) {
      FocusScope.of(context).requestFocus(new FocusNode()); // fecha o teclado

      setState(() {
        _pages = 1;
        _movieFiltered = title;
      });

      await _mPrefs.setString("movieFiltered", _movieFiltered!);

      final aux = await repository.lisMovie(_movieFiltered, _pages);
      _stream.add(aux);
    }
  }
  
  @override
  Widget build(BuildContext context) {
    MediaQuery.of(context).removePadding(removeTop: true);
    final String title = 'Filmes';
    
    return Scaffold(
      body: NestedScrollView(
        headerSliverBuilder: (BuildContext context, bool innerBoxIsScrolled) {
          return <Widget> [
            SliverAppBar(
              elevation: 2.0,
              titleSpacing: 0,
              expandedHeight: 120,
              pinned: true,
              floating: true,
              automaticallyImplyLeading: false,
              forceElevated: innerBoxIsScrolled,
              flexibleSpace: FlexibleSpaceBar(
                centerTitle: true,
                titlePadding: EdgeInsets.only(bottom: 72),
                title: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Row(
                        children: <Widget>[
                          Text(title, style: TextStyle(fontSize: 16, color: Colors.white),),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.local_movies, size: 14, color: Colors.white,),
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              bottom: PreferredSize(
                  preferredSize: const Size.fromHeight(72),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: <Widget>[

                      Container(
                        margin: EdgeInsets.only(left: 12, right: 12, bottom: 8, top: 2),
                        padding: EdgeInsets.only(left: 8, right: 4),
                        height: 48,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          border: Border.all(
                              width: 0.5
                          ),
                        ),
                        child: Row(
                          children: <Widget>[

                            Expanded(
                              child: TextField(
                                controller: _searchController,
                                decoration: InputDecoration(
                                    border: InputBorder.none,
                                    prefixIcon: IconButton(
                                      icon: Icon(Icons.search), color: Colors.white,
                                      onPressed: () => _searchMovie(_searchController.text),
                                    ),
                                    hintText: "Buscar"
                                ),
                                onSubmitted: (_) => _searchMovie(_searchController.text),
                              ),
                            ),

                            Container(width: 16),
                          ],
                        ),
                      ),

                    ],
                  )
              ),
            ),

          ];
        },
        body: StreamBuilder<List<Movie>?>( //Listener da Stream
          stream: _stream.stream,
          builder: (context, snapshot) {

            if(snapshot.hasData) {
              _listMovieAux = snapshot.data; //Manter os valores durante o incremento da lista
              final list = snapshot.data!;

              return Column(
                children: <Widget>[
                  Container(
                    width: MediaQuery.of(context).size.width,
                    child: Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Container(
                          padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                          child: Center(child: Text(list.length <= 1 ? "${list.length} Resultado" : "${list.length} Resultados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                        ),
                      ),
                    ),
                  ),

                  Expanded(
                    child: ListView.builder(
                      scrollDirection: Axis.horizontal,
                      controller: _scrollController,
                      physics: const AlwaysScrollableScrollPhysics(),
                      itemCount: list.length,
                      itemBuilder: (context, index) {

                        return InkWell(
                          child: Center(
                            child: Card(
                              elevation: 3.0,
                              borderOnForeground: true,
                              shadowColor: Colors.black,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(20))),
                              margin: const EdgeInsets.all(8),
                              child: Padding(
                                padding: const EdgeInsets.all(18.0),
                                child: Container(
                                  height: MediaQuery.of(context).size.height * .6,
                                  width: MediaQuery.of(context).size.width * .6,
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: <Widget>[

                                      Container(
                                        height: MediaQuery.of(context).size.height * .45,
                                        width: MediaQuery.of(context).size.width * .6,
                                        child: CachedNetworkImage(
                                          fit: BoxFit.fill,
                                          imageUrl: list[index].poster ?? '',
                                          placeholder: (context, url) => Center(child: const CircularProgressIndicator(backgroundColor: Colors.blueAccent, strokeWidth: 5,)),
                                          errorWidget: (context, url, error) => Center(child: Icon(Icons.movie_filter, size: 120,)),
                                        ),
                                      ),
                                      Column(
                                        mainAxisAlignment: MainAxisAlignment.start,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: <Widget>[
                                          SizedBox(height: 4.0),
                                          Text('Titulo: ${list[index].title}'),
                                          SizedBox(height: 4.0),
                                          Text('Ano Lançamento: ${list[index].year}'),
                                          SizedBox(height: 4.0),
                                          Text('Tipo: ${list[index].type}'),
                                          SizedBox(height: 4.0)
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Detalhes(imdbID: list[index].imdbID)));
                          },
                        );
                      }
                    ),
                  ),
                ],
              );
            } else {
              return Center(child: CircularProgressIndicator(backgroundColor: Colors.blueAccent[100],),);
            }
          }
        ),
      ),
      resizeToAvoidBottomInset: false,// evitar que o teclado aperte o conteúdo
    );
  }
}
