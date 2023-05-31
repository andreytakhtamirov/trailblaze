/*  The types of available transportation modes.
*     The value corresponds to available profiles
*     in the Mapbox Directions API:
*     https://docs.mapbox.com/api/navigation/directions/#routing-profiles
*/
enum TransportationMode {
  none("none"),
  walking("walking"),
  cycling("cycling"),
  gravelCycling("gravel_cycling");

  final String value;

  const TransportationMode(this.value);
}

TransportationMode getTransportationModeFromString(String value) {
  return TransportationMode.values.firstWhere(
    (mode) => mode.toString() == 'TransportationMode.$value',
    orElse: () => TransportationMode.walking,
  );
}
