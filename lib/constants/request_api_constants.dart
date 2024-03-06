import '../data/transportation_mode.dart';

const geocodeResultsLimit = 5;

const kMapboxRoutePrecision = 6;
const kGraphhopperRoutePrecision = 5;

const kMapboxRouteGeometryKey = 'geometry';
const kGraphhopperRouteGeometryKey = 'points';

const kDefaultTransportationMode = TransportationMode.gravel_cycling; // TODO CHANGE BACK

const String staticMapStyle = 'streets-v12';
const int kStaticMapWidth = 1200;
const int kStaticMapHeight = 700;

const String kRouteTypeGraphhopper = 'gh';
const String kRouteTypeMapbox = 'mb';

const int kMaxTitleLength = 50;
