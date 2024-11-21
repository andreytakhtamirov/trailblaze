enum SearchFeatureType {
  coordinates('coordinates'),
  category('category'),
  poi('poi'),
  address('address'),
  place('place'),
  neighborhood('neighborhood'),
  history('history'),
  userLocation('userLocation');

  final String value;

  const SearchFeatureType(this.value);
}

SearchFeatureType getFeatureTypeFromString(String value) {
  return SearchFeatureType.values.firstWhere(
    (mode) => mode.toString() == 'SearchFeatureType.$value',
    orElse: () => SearchFeatureType.address,
  );
}
