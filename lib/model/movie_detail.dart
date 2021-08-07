class MovieDetails {
  String? title;
  String? year;
  String? released;
  String? runtime;
  String? genre;
  String? director;
  String? writter;
  String? actors;
  String? plot;
  String? country;
  String? imdbID;
  String? type;
  String? poster;
  String? production;

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

  factory MovieDetails.fromMap(Map<String, dynamic> map) {
    return new MovieDetails(
      title: map['Title'] as String?,
      year: map['Year'] as String?,
      released: map['Released'] as String?,
      runtime: map['Runtime'] as String?,
      genre: map['Genre'] as String?,
      director: map['Director'] as String?,
      writter: map['Writter'] as String?,
      actors: map['Actors'] as String?,
      plot: map['Plot'] as String?,
      country: map['Country'] as String?,
      imdbID: map['imdbID'] as String?,
      type: map['Type'] as String?,
      poster: map['Poster'] as String?,
      production: map['Production'] as String?,
    );
  }
}