import 'dart:convert';
import 'dart:developer';
import 'dart:math' as math;

import 'package:auth0_flutter/auth0_flutter.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:expandable/expandable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
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
import 'package:trailblaze/util/chart_helper.dart';
import 'package:trailblaze/util/firebase_helper.dart';
import 'package:trailblaze/util/format_helper.dart';
import 'package:http/http.dart' as http;
import 'package:trailblaze/util/static_image_helper.dart';
import 'package:trailblaze/util/ui_helper.dart';
import 'package:trailblaze/widgets/buttons/more_button.dart';
import 'package:trailblaze/widgets/map/icon_button_small.dart';

class RouteInfoPanel extends ConsumerStatefulWidget {
  const RouteInfoPanel({
    Key? key,
    required this.route,
    required this.panelHeight,
    required this.onPreviewMetric,
    required this.onSetHeight,
    required this.isPanelFullyOpen,
    this.hideSaveRoute = false,
  }) : super(key: key);
  final TrailblazeRoute? route;
  final bool hideSaveRoute;
  final bool isPanelFullyOpen;
  final double panelHeight;
  final void Function(MetricType type) onPreviewMetric;
  final void Function(double height) onSetHeight;

  @override
  ConsumerState<RouteInfoPanel> createState() => _RouteInfoPanelState();
}

class _RouteInfoPanelState extends ConsumerState<RouteInfoPanel> {
  late TrackballBehavior _elevationTrackball;
  http.Client _client = http.Client();
  bool _isFetchingMetrics = false;
  String? _savedRouteId;
  bool _isLoadingRouteUpdate = false;
  bool _setHeight = false;
  double? _smallCardHeight;
  final GlobalKey _metricsKey = GlobalKey();
  final GlobalKey _surfaceMetricKey = GlobalKey();
  final GlobalKey _roadClassMetricKey = GlobalKey();

  @override
  initState() {
    super.initState();
    _elevationTrackball = TrackballBehavior(
        enable: true,
        builder: (context, trackballDetails) {
          return ChartHelper.trackballBuilder(
            context,
            widget.route?.elevationMetrics?[trackballDetails.pointIndex!],
          );
        });
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
      waypointsList.first.center?.lat ?? 0,
      waypointsList.first.center?.long ?? 0,
      waypointsList.last.center?.lat ?? 0,
      waypointsList.last.center?.long ?? 0,
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

  Widget _buildMetricCard(
      Map<String, num> metrics, MetricType type, bool buttonInHeader,
      {GlobalKey? key, double? height}) {
    return Padding(
      padding: const EdgeInsets.all(4),
      child: Card(
        margin: EdgeInsets.zero,
        child: ExpandableNotifier(
          initialExpanded: true,
          child: ExpandablePanel(
            theme: const ExpandableThemeData(
              tapHeaderToExpand: false,
              tapBodyToExpand: false,
              tapBodyToCollapse: false,
              hasIcon: false,
              iconPlacement: ExpandablePanelIconPlacement.right,
              iconColor: Colors.black,
              bodyAlignment: ExpandablePanelBodyAlignment.right,
              headerAlignment: ExpandablePanelHeaderAlignment.center,
              alignment: Alignment.center,
            ),
            header: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Text(
                      type.value,
                      style: const TextStyle(
                        fontSize: 18.0,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  if (widget.route?.surfacePolylines != null &&
                      widget.route?.roadClassPolylines != null &&
                      buttonInHeader)
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          FirebaseHelper.logScreen(
                              "PreviewMetric-${type.value}");
                          widget.onPreviewMetric(type);
                        },
                        child: const MoreButton(
                          label: 'Preview',
                          axisAlignment: MainAxisAlignment.end,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            collapsed: const SizedBox(),
            expanded: Padding(
              padding: const EdgeInsets.fromLTRB(4, 4, 4, 0),
              child: Column(
                children: [
                  SizedBox(
                    key: key,
                    height: height == 0 ? null : height,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        _chartForType(metrics, type),
                        if (!buttonInHeader)
                          widget.route?.surfacePolylines != null &&
                                  widget.route?.roadClassPolylines != null
                              ? InkWell(
                                  onTap: () {
                                    FirebaseHelper.logScreen(
                                        "PreviewMetric-${type.value}");
                                    widget.onPreviewMetric(type);
                                  },
                                  child: const Padding(
                                    padding: EdgeInsets.only(
                                      top: 16,
                                      right: 8,
                                      left: 8,
                                    ),
                                    child: MoreButton(
                                      label: 'More',
                                      axisAlignment: MainAxisAlignment.end,
                                    ),
                                  ),
                                )
                              : const SizedBox(),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _chartForType(Map<String, num> metrics, MetricType type) {
    switch (type) {
      case MetricType.elevation:
        return SizedBox(
          height: 100,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            child: ChartHelper.buildElevationChart(
                widget.route!, _elevationTrackball),
          ),
        );
      case MetricType.surface:
        return _buildMetricBarView(_surfaceMetricKey, metrics, type);
      case MetricType.roadClass:
        return _buildMetricBarView(_roadClassMetricKey, metrics, type);
    }
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

    // Update panel height.
    if (mounted) {
      setState(() {
        _setHeight = false;
      });
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

  dynamic _saveRouteButtonForeground() {
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

    if (!_setHeight) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        final height = _metricsKey.currentContext?.size?.height;
        if (widget.panelHeight != height) {
          widget.onSetHeight(height ?? 0);
          setState(() {
            _setHeight = true;
          });
        }

        final double surfaceMetricsHeight =
            _surfaceMetricKey.currentContext?.size?.height ?? 0;
        final double roadClassMetricsHeight =
            _roadClassMetricKey.currentContext?.size?.height ?? 0;

        _smallCardHeight =
            math.max(surfaceMetricsHeight, roadClassMetricsHeight);
      });
    }

    return Expanded(
      child: SingleChildScrollView(
        physics: widget.isPanelFullyOpen
            ? null
            : const NeverScrollableScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 0, horizontal: 16),
        child: ListView(
          physics: const NeverScrollableScrollPhysics(),
          padding: EdgeInsets.zero,
          shrinkWrap: true,
          key: _metricsKey,
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
                        iconFontSize: 20,
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
                      _buildMetricCard(
                        widget.route!.surfaceMetrics!,
                        MetricType.elevation,
                        true,
                      ),
                      Row(
                        children: [
                          Flexible(
                            child: _buildMetricCard(
                              widget.route!.surfaceMetrics!,
                              MetricType.surface,
                              false,
                              key: _surfaceMetricKey,
                              height: _smallCardHeight,
                            ),
                          ),
                          // Not supported in every mode
                          widget.route!.roadClassMetrics != null
                              ? Flexible(
                                  child: _buildMetricCard(
                                    widget.route!.roadClassMetrics!,
                                    MetricType.roadClass,
                                    false,
                                    key: _roadClassMetricKey,
                                    height: _smallCardHeight,
                                  ),
                                )
                              : const SizedBox(),
                        ],
                      ),
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

  Widget _buildMetricBarView(
      GlobalKey key, Map<String, num> metrics, MetricType type) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          ListView.builder(
            physics: const NeverScrollableScrollPhysics(),
            padding: EdgeInsets.zero,
            shrinkWrap: true,
            itemCount: metrics.length.clamp(0, 3),
            itemBuilder: (BuildContext context, int index) {
              final metric = metrics.keys.elementAt(index);
              final distance = metrics[metric] ?? 0;
              return LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constraints) {
                  final availableWidth = constraints.maxWidth;
                  final itemWidth =
                      availableWidth * (distance / widget.route!.distance);
                  return Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: itemWidth,
                              height: 15,
                              color: ChartHelper.colorForMetricKey(
                                  widget.route!, type, metric),
                            ),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(
                              flex: 3,
                              child: AutoSizeText(
                                maxFontSize: 24,
                                minFontSize: 12,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                FormatHelper.toCapitalizedText(metric),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: AutoSizeText(
                                style: const TextStyle(
                                    fontWeight: FontWeight.w300),
                                maxFontSize: 24,
                                minFontSize: 10,
                                textAlign: TextAlign.center,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                FormatHelper.formatDistancePrecise(distance),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }
}
