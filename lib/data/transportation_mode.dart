/*  The types of available transportation modes.
*     The value corresponds to available profiles
*     in the Mapbox Directions API:
*     https://docs.mapbox.com/api/navigation/directions/#routing-profiles,
*     as well as custom profiles in the private Trailblaze API.
*/
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
