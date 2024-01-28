import 'dart:convert';
import 'dart:developer';

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:mapbox_search/mapbox_search.dart';
import 'package:polyline_codec/polyline_codec.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:trailblaze/constants/map_constants.dart';
import 'package:trailblaze/constants/request_api_constants.dart';
import 'package:trailblaze/constants/route_info_constants.dart';
import 'package:trailblaze/data/profile.dart';
import 'package:trailblaze/data/trailblaze_route.dart';
import 'package:trailblaze/managers/credential_manager.dart';
import 'package:trailblaze/managers/profile_manager.dart';
import 'package:trailblaze/requests/route_metrics.dart';
import 'package:trailblaze/requests/user_profile.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:http/http.dart' as http;
import 'package:trailblaze/util/static_image_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';

class RouteInfoPanel extends ConsumerStatefulWidget {
  const RouteInfoPanel({
    Key? key,
    required this.route,
    this.hideSaveRoute = false,
  }) : super(key: key);
  final TrailblazeRoute? route;
  final bool hideSaveRoute;

  @override
  ConsumerState<RouteInfoPanel> createState() => _RouteInfoPanelState();
}

class _RouteInfoPanelState extends ConsumerState<RouteInfoPanel> {
  late TrackballBehavior _elevationTrackball;
  http.Client _client = http.Client();
  bool _isFetchingMetrics = false;
  String? _savedRouteId;
  bool _isLoadingRouteUpdate = false;

  @override
  initState() {
    super.initState();
    _elevationTrackball = TrackballBehavior(enable: true);
    setState(() {
      _isFetchingMetrics = false;
    });
    _fetchMetricsIfNeeded();
  }

  @override
  void didUpdateWidget(covariant RouteInfoPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.route?.geoJsonSource != oldWidget.route?.geoJsonSource) {
      _client.close();
      _client = http.Client();
      _fetchMetricsIfNeeded();
      setState(() {
        _savedRouteId = null;
        _isLoadingRouteUpdate = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
    _client.close();
  }

  void _fetchMetricsIfNeeded() {
    if (widget.route?.surfaceMetrics == null &&
        widget.route?.elevationMetrics == null) {
      _fetchRouteMetrics();
    }
  }

  void _onSaveRoute(
      Credentials? credentials, Profile? profile, String routeName) async {
    setState(() {
      _isLoadingRouteUpdate = true;
    });

    final waypoints = widget.route?.routeOptions['waypoints'];
    final List<MapBoxPlace> waypointsList = [];

    for (dynamic placeJson in waypoints) {
      waypointsList.add(MapBoxPlace.fromJson(json.decode(placeJson)));
    }

    final List<List<num>> coordinates;
    if (widget.route?.coordinates != null) {
      coordinates =
          StaticImageHelper.sampleCoordinates(widget.route!.coordinates!);
    } else {
      coordinates = [];
    }

    String polyline = PolylineCodec.encode(coordinates, precision: 5);
    Uri staticImageUri = StaticImageHelper.staticImageFromPolyline(
      kMapboxAccessToken,
      waypointsList.first.center?[0] ?? 0,
      waypointsList.first.center?[1] ?? 0,
      waypointsList.last.center?[0] ?? 0,
      waypointsList.last.center?[1] ?? 0,
      polyline,
    );

    final response = await saveRoute(
      credentials?.idToken ?? '',
      profile?.id ?? '',
      widget.route,
      staticImageUri.toString(),
      routeName,
    );

    setState(() {
      _isLoadingRouteUpdate = false;
    });

    response.fold(
      (error) => {
        UiHelper.showSnackBar(context, 'Failed to save route.'),
      },
      (data) => {
        setState(() {
          _savedRouteId = data;
        }),
      },
    );
  }

  void _onDeleteRoute(Credentials? credentials, Profile? profile) async {
    setState(() {
      _isLoadingRouteUpdate = true;
    });

    final response = await deleteRoute(
        credentials?.idToken ?? '', profile?.id ?? '', _savedRouteId ?? '');

    setState(() {
      _isLoadingRouteUpdate = false;
    });

    response.fold(
      (error) => {
        UiHelper.showSnackBar(context, 'Failed to delete route.'),
      },
      (data) => {
        // Route deleted successfully.
        setState(() {
          _savedRouteId = null;
        }),
      },
    );
  }

  SfCartesianChart _buildElevationChart(List<Color> palette) {
    final metrics = widget.route!.elevationMetrics!;
    final distance = widget.route!.distance;

    num maxElevation =
        metrics.reduce((value, value2) => value > value2 ? value : value2);
    num minElevation =
        metrics.reduce((value, value2) => value < value2 ? value : value2);

    // Add padding below/above for visibility.
    minElevation -= minElevation * 0.05;
    maxElevation += maxElevation * 0.05;

    return SfCartesianChart(
      trackballBehavior: _elevationTrackball,
      primaryXAxis: NumericAxis(
        minimum: 0,
        maximum: distance.toDouble(),
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
      ),
      primaryYAxis: NumericAxis(
        minimum: minElevation.toDouble(),
        maximum: maxElevation.toDouble(),
        interval: (maxElevation - minElevation) / 3,
        numberFormat: NumberFormat.compact(),
        labelFormat: '{value}m',
      ),
      series: <CartesianSeries<num, num>>[
        AreaSeries<num, num>(
          dataSource: metrics,
          xValueMapper: (p, _) => distance / (metrics.length - 1) * _,
          yValueMapper: (p, _) => p,
          color: const Color.fromRGBO(8, 142, 255, 1),
        ),
      ],
      palette: palette,
      margin: const EdgeInsets.fromLTRB(0, 0, 24, 0),
    );
  }

  List<CartesianSeries<num, String>> _getStackedBarSurfaces() {
    final surfaceMetrics = widget.route!.surfaceMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => '',
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  List<CartesianSeries<num, String>> _getStackedBarHighway() {
    final surfaceMetrics = widget.route!.highwayMetrics!;

    List<StackedBarSeries<num, String>> series =
        <StackedBarSeries<num, String>>[];

    for (var point in surfaceMetrics.entries) {
      series.add(StackedBarSeries<num, String>(
        dataSource: [point.value],
        name: point.key,
        xValueMapper: (p, _) => '',
        yValueMapper: (p, _) => p,
        legendItemText: point.key,
        legendIconType: LegendIconType.circle,
      ));
    }

    return series;
  }

  SfCartesianChart _buildChart(
      List<CartesianSeries> series, List<Color> palette) {
    return SfCartesianChart(
      tooltipBehavior: TooltipBehavior(
        activationMode: ActivationMode.singleTap,
        enable: true,
      ),
      primaryXAxis: CategoryAxis(),
      primaryYAxis: NumericAxis(
        labelFormat: '{value}m',
        numberFormat: NumberFormat.compact(),
        maximum: widget.route!.distance.toDouble() +
            widget.route!.distance.toDouble() * 0.05,
      ),
      series: series,
      palette: palette,
      legend: Legend(
        isVisible: true,
        position: LegendPosition.bottom,
        alignment: ChartAlignment.center,
        shouldAlwaysShowScrollbar: true,
      ),
      margin: const EdgeInsets.fromLTRB(24, 0, 24, 0),
    );
  }

  ExpandableNotifier _buildExpandablePanel(
      String title, SfCartesianChart chart, bool isExpanded) {
    return ExpandableNotifier(
      initialExpanded: isExpanded,
      child: ScrollOnExpand(
        child: ExpandablePanel(
          theme: const ExpandableThemeData(
            tapHeaderToExpand: true,
            tapBodyToExpand: true,
            tapBodyToCollapse: true,
            hasIcon: true,
            iconPlacement: ExpandablePanelIconPlacement.right,
            iconColor: Colors.black,
            bodyAlignment: ExpandablePanelBodyAlignment.right,
            headerAlignment: ExpandablePanelHeaderAlignment.center,
            alignment: Alignment.center,
            iconSize: 20,
            expandIcon: Icons.add_rounded,
            collapseIcon: Icons.close_rounded,
          ),
          header: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              title,
              style: const TextStyle(
                fontSize: 15.0,
              ),
            ),
          ),
          collapsed: const SizedBox(),
          expanded: SizedBox(
            height: 120,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(0, 16, 0, 0),
              child: chart,
            ),
          ),
        ),
      ),
    );
  }

  void _fetchRouteMetrics() async {
    setState(() {
      _isFetchingMetrics = true;
    });
    Map<String, dynamic>? metrics =
        await getRouteMetrics(_client, widget.route?.routeJson);

    // At this point this widget might be unmounted.
    if (mounted) {
      setState(() {
        _isFetchingMetrics = false;
      });
    }

    if (metrics == null) {
      log('Could not fetch metrics for route.');
      return;
    }

    // Only fetch surface metrics for now.
    List<dynamic>? elevationMetrics = metrics['elevationMetrics']['elevations'];
    Map<String, dynamic>? surfaceMetrics = metrics['surfaceMetrics'];
    if (mounted) {
      setState(() {
        widget.route?.elevationMetrics = elevationMetrics?.cast<num>();
        widget.route?.surfaceMetrics = surfaceMetrics?.cast<String, num>();
      });
    } else {
      // If the widget isn't mounted, update the metrics silently.
      widget.route?.elevationMetrics = elevationMetrics?.cast<num>();
      widget.route?.surfaceMetrics = surfaceMetrics?.cast<String, num>();
    }
  }

  String _saveRouteButtonText() {
    if (_isLoadingRouteUpdate && _savedRouteId == null) {
      return 'Saving...';
    } else if (_isLoadingRouteUpdate && _savedRouteId != null) {
      return 'Deleting...';
    } else if (!_isLoadingRouteUpdate && _savedRouteId == null) {
      return 'Save Route';
    } else {
      return 'Saved';
    }
  }

  IconData _saveRouteButtonIcon() {
    if (!_isLoadingRouteUpdate && _savedRouteId == null) {
      return Icons.add_circle_outline_rounded;
    } else if (!_isLoadingRouteUpdate && _savedRouteId != null) {
      return Icons.add_circle_rounded;
    } else {
      return Icons.access_time_rounded;
    }
  }

  Color _saveRouteButtonForeground() {
    if (!_isLoadingRouteUpdate && _savedRouteId == null) {
      return Theme.of(context).colorScheme.primary;
    } else if (!_isLoadingRouteUpdate && _savedRouteId != null) {
      return Theme.of(context).colorScheme.tertiary;
    } else {
      return Colors.black;
    }
  }

  void _onSaveRouteClick(Credentials? credentials, Profile? profile) async {
    if (_isLoadingRouteUpdate) {
      return;
    }
    if (_savedRouteId == null) {
      final routeName = await UiHelper.showStringInputDialog(
        context,
        'Route Name',
        'Enter a name for your route',
        kMaxTitleLength,
      );

      if (routeName != null) {
        _onSaveRoute(credentials, profile, routeName);
      }
    } else {
      bool? confirmed = await UiHelper.showConfirmationDialog(
        context,
        'Delete Route?',
        'Are you sure you want to delete this route?',
        'Delete',
        'Cancel',
        Colors.red,
        Colors.white,
      );

      if (confirmed ?? false) {
        _onDeleteRoute(credentials, profile);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = ref.watch(profileProvider);
    final credentials = ref.watch(credentialsProvider);

    return Expanded(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  const Expanded(
                    child: Text(
                      'Route Info',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  if (!widget.hideSaveRoute && credentials != null)
                    Expanded(
                      child: IconButtonSmall(
                        text: _saveRouteButtonText(),
                        icon: _saveRouteButtonIcon(),
                        foregroundColor: _saveRouteButtonForeground(),
                        onTap: () => {_onSaveRouteClick(credentials, profile)},
                      ),
                    )
                  else
                    const SizedBox(),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(0, 4, 0, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Duration',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.black,
                        ),
                      ),
                      Text(
                        'Distance',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        FormatHelper.formatDuration(widget.route!.duration),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                      Text(
                        FormatHelper.formatDistance(widget.route!.distance),
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            _isFetchingMetrics == false &&
                    widget.route!.elevationMetrics != null &&
                    widget.route!.surfaceMetrics != null
                ? Column(
                    children: [
                      _buildExpandablePanel(
                        'Elevation',
                        _buildElevationChart(kChartPalette1),
                        true,
                      ),
                      _buildExpandablePanel(
                        'Surface Types',
                        _buildChart(_getStackedBarSurfaces(), kChartPalette1),
                        false,
                      ),
                      // Not supported in every mode
                      widget.route!.highwayMetrics != null
                          ? _buildExpandablePanel(
                              'Highway Types',
                              _buildChart(
                                  _getStackedBarHighway(), kChartPalette2),
                              false,
                            )
                          : const SizedBox(),
                    ],
                  )
                : _isFetchingMetrics == true &&
                        widget.route!.elevationMetrics == null &&
                        widget.route!.surfaceMetrics == null
                    ? const Center(
                        child: Column(
                          children: [
                            Text('Fetching route metrics'),
                            SizedBox(
                              height: 24,
                            ),
                            CircularProgressIndicator(),
                          ],
                        ),
                      )
                    : const Center(
                        child: Text('Could not fetch route metrics'),
                      ),
          ],
        ),
      ),
    );
  }
}
