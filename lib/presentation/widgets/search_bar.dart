import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:contact_map/presentation/providers/place_provider.dart';
import 'package:contact_map/core/constants/strings.dart';

class CustomSearchBar extends StatefulWidget {
  final Function(String) onSearch;
  const CustomSearchBar({super.key, required this.onSearch});

  @override
  _CustomSearchBarState createState() => _CustomSearchBarState();
}

class _CustomSearchBarState extends State<CustomSearchBar> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // No necesitamos el provider aquí si solo notificamos hacia arriba
    // pero lo usaremos para el botón de limpiar
    final provider = context.read<PlaceProvider>();

    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: Strings.searchHint,
        prefixIcon: const Icon(Icons.search),
        suffixIcon: IconButton(
          icon: const Icon(Icons.clear),
          onPressed: () {
            _controller.clear();
            provider.clearResults();
            // Ocultar el teclado
            FocusScope.of(context).unfocus();
          },
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      ),
      onSubmitted: (value) {
        if (value.isNotEmpty) {
          widget.onSearch(value);
        }
      },
    );
  }
}