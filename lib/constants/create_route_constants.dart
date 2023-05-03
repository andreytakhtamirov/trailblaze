const geocodeResultsLimit = 5;

const defaultTransportationMode = TransportationMode.walking;

/*  The types of available transportation modes.
*     The value corresponds to available profiles
*     in the Mapbox Directions API:
*     https://docs.mapbox.com/api/navigation/directions/#routing-profiles
*/
enum TransportationMode {
  walking("walking"),
  cycling("cycling");

  final String value;

  const TransportationMode(this.value);
}
