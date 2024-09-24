import 'package:flutter/material.dart';

class EmptySearch extends StatelessWidget {
  final bool isSearchEmpty;

  const EmptySearch({super.key, required this.isSearchEmpty});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 64, horizontal: 40),
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Icon(
                isSearchEmpty
                    ? Icons.travel_explore
                    : Icons.not_listed_location_outlined,
                size: 70,
                color: Colors.black54,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  isSearchEmpty
                      ? 'Search for places, addresses, coordinates, and more.'
                      : 'Sorry, we couldn\'t find any matches.',
                  style: const TextStyle(
                    fontWeight: FontWeight.w400,
                    fontSize: 17,
                    color: Colors.black87,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
