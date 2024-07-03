import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:trailblaze/util/format_helper.dart';

class MetricsItem extends StatelessWidget {
  final bool isSelected;
  final Color accentColor;
  final double width;
  final String metricKey;
  final String percentDistance;
  final Function() onMetricChanged;

  const MetricsItem({
    super.key,
    required this.isSelected,
    required this.accentColor,
    required this.width,
    required this.metricKey,
    required this.percentDistance,
    required this.onMetricChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 4),
      child: InkWell(
        onTap: () {
          onMetricChanged();
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: isSelected
                  ? accentColor.withOpacity(0.7)
                  : Colors.grey.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              const SizedBox(width: 8),
              Container(
                height: 15,
                width: 15,
                decoration: BoxDecoration(
                  color: accentColor,
                  borderRadius: const BorderRadius.all(
                    Radius.circular(15),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              SizedBox(
                width: width - 54,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Flexible(
                      flex: 3,
                      child: AutoSizeText(
                        FormatHelper.toCapitalizedText(metricKey),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 2,
                        softWrap: true,
                        wrapWords: false,
                        minFontSize: 9,
                        maxFontSize: 20,
                      ),
                    ),
                    if (isSelected)
                      Flexible(
                        flex: 2,
                        child: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: AutoSizeText(
                            percentDistance,
                            style: const TextStyle(
                              color: Colors.black,
                            ),
                            maxFontSize: 18,
                            minFontSize: 10,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
