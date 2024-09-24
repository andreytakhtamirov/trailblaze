enum SearchFeatureType {
  category('category'),
  poi('poi'),
  address('address'),
  place('place'),
  neighborhood('neighborhood'),
  history('history');

  final String value;

  const SearchFeatureType(this.value);
}

SearchFeatureType getFeatureTypeFromString(String value) {
  return SearchFeatureType.values.firstWhere(
    (mode) => mode.toString() == 'SearchFeatureType.$value',
    orElse: () => SearchFeatureType.address,
  );
}
