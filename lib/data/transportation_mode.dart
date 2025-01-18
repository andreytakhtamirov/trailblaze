enum TransportationMode {
  none("none"),
  walking("walking"),
  cycling("cycling"),
  walking_plus("walking_plus"),
  cycling_plus("cycling_plus"),
  gravel_cycling("gravel_cycling");

  final String value;

  const TransportationMode(this.value);
}

TransportationMode getTransportationModeFromString(String value) {
  return TransportationMode.values.firstWhere(
    (mode) => mode.toString() == 'TransportationMode.$value',
    orElse: () => TransportationMode.none,
  );
}
