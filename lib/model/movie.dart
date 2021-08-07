class Movie {
  String? title;
  String? year;
  String? imdbID;
  String? type;
  String? poster;

  Movie({this.title, this.year, this.poster,this.imdbID, this.type});

  factory Movie.fromMap(Map<String, dynamic> map) {
    return new Movie(
      title: map['Title'] as String?,
      year: map['Year'] as String?,
      imdbID: map['imdbID'] as String?,
      type: map['Type'] as String?,
      poster: map['Poster'] as String?,
    );
  }

}