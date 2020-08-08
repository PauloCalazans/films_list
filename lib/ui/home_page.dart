import 'dart:async';
import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:films_list/ui/detalhes.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<HomePage> {

  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  String _movieFiltered = "";

  bool _isLoading = false;

  List<Movie> _list = List();
  final GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _doInit();
  }

  _doInit() async {
    final SharedPreferences _mPrefs = await _prefs;
    _movieFiltered = _mPrefs.getString("movieFiltered");

    if(_movieFiltered == null || _movieFiltered.isEmpty) {
      _movieFiltered = "avengers";
      await _mPrefs.setString("movieFiltered", _movieFiltered);
    }

    _searchController.text = _movieFiltered;
    _popularList(_movieFiltered);
  }

  @override
  void dispose() {
    super.dispose();
  }

  _popularList(String title) async {
    final timeout = Duration(seconds: 60);
    final List<Movie> list = List();

    setState(() {
      _isLoading = true;
    });

    final response = await http.get(
      "http://www.omdbapi.com/?apikey=27b47c25&s=${title}", // url base
      headers: <String, String>{
        "Content-type": "application/json",
        "Accept": "application/json",
        //Coloque aqui a autenticação caso haja
      },
    ).timeout(timeout).catchError((err) {
      print('Erro na busca dos filmes $err');
    });

    final responseArray = jsonDecode(response.body)['Search'] as List;

    for(int i = 0; i < responseArray.length; i++) {
      Movie vo = new Movie();
      vo.title = jsonDecode(response.body)['Search'][i]['Title'];
      vo.year = int.tryParse(jsonDecode(response.body)['Search'][i]['Year']);
      vo.imdbID = jsonDecode(response.body)['Search'][i]['imdbID'];
      vo.type = jsonDecode(response.body)['Search'][i]['Type'];
      vo.poster = jsonDecode(response.body)['Search'][i]['Poster'];

      print(jsonDecode(response.body)['Search'][i]['Title']);

      list.add(vo);
    }
    setState(() {
      _isLoading = false;
      _list = list;
    });

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
                          Text(title, style: TextStyle(fontSize: 16, color: Colors.black),),
                          Padding(
                            padding: const EdgeInsets.only(left: 4.0),
                            child: Icon(Icons.local_movies, size: 14, color: Colors.black,),
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
                                    prefixIcon: Icon(Icons.search),
                                    hintText: "Buscar"
                                ),
                                onChanged: (value) async {
                                  await Future.delayed(const Duration(milliseconds: 400), () {
                                    if(value.length > 1) {
                                      _popularList(value);
                                    }
                                  });
                                },
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
        body: RefreshIndicator(
          key: _refreshIndicatorKey,
          child: Visibility(
            visible: !_isLoading,
            replacement: Center(child: CircularProgressIndicator(backgroundColor: Colors.lightBlue,),),
            child: Column(
              children: <Widget>[
                Container(
                  width: MediaQuery.of(context).size.width,
                  child: Card(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        padding: const EdgeInsets.only(top: 8.0, bottom: 8.0, left: 16.0, right: 16.0),
                        child: Center(child: Text(_list.length <= 1 ? "${_list.length} Resultado" : "${_list.length} Resultados", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),)),
                      ),
                    ),
                  ),
                ),

                Expanded(
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    controller: ScrollController(),
                    physics: const AlwaysScrollableScrollPhysics(),
                    itemCount: _list.length,
                    itemBuilder: (context, index) {
                      if(_list != null) {
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
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    CachedNetworkImage(
                                      height: MediaQuery.of(context).size.height * .45,
                                      width: MediaQuery.of(context).size.width * .6,
                                      fit: BoxFit.fill,
                                      imageUrl: _list[index].poster,
                                      placeholder: (context, url) => const CircularProgressIndicator(backgroundColor: Colors.blueAccent, strokeWidth: 5,),
                                      errorWidget: (context, url, error) => Center(child: Icon(Icons.movie_filter, size: 120,)),
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.start,
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: <Widget>[
                                        SizedBox(height: 4.0),
                                        Text('Titulo: ${_list[index].title}'),
                                        SizedBox(height: 4.0),
                                        Text('Ano Lançamento: ${_list[index].year}'),
                                        SizedBox(height: 4.0),
                                        Text('Tipo: ${_list[index].type}'),
                                        SizedBox(height: 4.0)
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => Detalhes(imdbID: _list[index].imdbID,)));
                          },
                        );
                      } else {
                        return Center(child: CircularProgressIndicator());
                      }
                    }
                  ),
                ),
              ],
            ),
          ),
          onRefresh: () async => _popularList(_movieFiltered),
        ),
      ),
      resizeToAvoidBottomPadding: false,// evitar que o teclado aperto o conteúdo
    );
  }
}

class Movie {
  String title;
  int year;
  String imdbID;
  String type;
  String poster;

  Movie({this.title, this.year, this.poster,this.imdbID, this.type});

}
