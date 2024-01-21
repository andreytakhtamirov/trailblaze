import '../data/transportation_mode.dart';

const geocodeResultsLimit = 5;

const kMapboxRoutePrecision = 6;
const kGraphhopperRoutePrecision = 5;

const kMapboxRouteGeometryKey = 'geometry';
const kGraphhopperRouteGeometryKey = 'points';

const kDefaultTransportationMode = TransportationMode.none;
const double kMinFeatureDistanceMeters = 1000;
const double kMaxFeatureDistanceMeters = 20000;
const double kDefaultFeatureDistanceMeters = 2000;