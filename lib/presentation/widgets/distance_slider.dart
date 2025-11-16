import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_map/presentation/providers/place_provider.dart';
import 'package:contact_map/core/constants/strings.dart';

class DistanceSlider extends StatelessWidget {
  const DistanceSlider({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<PlaceProvider>(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${Strings.searchRadius}: ${provider.searchRadius.toStringAsFixed(1)} ${Strings.km}',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        Slider(
          value: provider.searchRadius,
          min: 1.0,
          max: 20.0,
          divisions: 19,
          label: '${provider.searchRadius.toStringAsFixed(1)} km',
          onChanged: (value) {
            provider.setSearchRadius(value);
          },
        ),
      ],
    );
  }
}
