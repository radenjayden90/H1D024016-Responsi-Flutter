import 'dart:async';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/location.dart';
import '../viewmodels/search_viewmodel.dart';
import '../viewmodels/weather_viewmodel.dart';
import '../widgets/state_views.dart';

/// View untuk mencari kota, melihat daftar favorit, dan riwayat pencarian
/// (View dalam arsitektur MVVM).
class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  Timer? _debounce;

  @override
  void dispose() {
    _debounce?.cancel();
    _controller.dispose();
    super.dispose();
  }

  void _onQueryChanged(String value) {
    _debounce?.cancel();
    if (value.trim().isEmpty) {
      context.read<SearchViewModel>().clearSearch();
      setState(() {});
      return;
    }
    setState(() {});
    _debounce = Timer(const Duration(milliseconds: 500), () {
      if (!mounted) return;
      context.read<SearchViewModel>().search(value);
    });
  }

  void _onSubmitSearch(String value) {
    _debounce?.cancel();
    context.read<SearchViewModel>().search(value);
  }

  Future<void> _onSelectLocation(Location location) async {
    final searchVm = context.read<SearchViewModel>();
    final weatherVm = context.read<WeatherViewModel>();

    await searchVm.addToHistory(location);
    await weatherVm.selectLocation(location);

    if (!mounted) return;
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final searchVm = context.watch<SearchViewModel>();
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cari Lokasi'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
              child: TextField(
                controller: _controller,
                textInputAction: TextInputAction.search,
                autofocus: false,
                onChanged: _onQueryChanged,
                onSubmitted: _onSubmitSearch,
                decoration: InputDecoration(
                  hintText: 'Masukkan nama kota (mis. Purwokerto)...',
                  prefixIcon: const Icon(Icons.search_rounded),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          tooltip: 'Hapus pencarian',
                          icon: const Icon(Icons.clear_rounded),
                          onPressed: () {
                            _debounce?.cancel();
                            _controller.clear();
                            searchVm.clearSearch();
                            setState(() {});
                          },
                        )
                      : IconButton(
                          tooltip: 'Cari',
                          icon: const Icon(Icons.arrow_forward_rounded),
                          onPressed: () => _onSubmitSearch(_controller.text),
                        ),
                  filled: true,
                  fillColor: colorScheme.surfaceContainerHighest
                      .withValues(alpha: 0.45),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(
              child: _buildContent(context, searchVm),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent(BuildContext context, SearchViewModel searchVm) {
    switch (searchVm.state) {
      case SearchLoadState.initial:
        return _buildFavoritesAndHistory(context, searchVm);

      case SearchLoadState.loading:
        return const LoadingStateView(message: 'Mencari kota...');

      case SearchLoadState.empty:
        return const EmptyStateView(
          icon: Icons.location_off_rounded,
          title: 'Kota tidak ditemukan',
          subtitle: 'Periksa ejaan nama kota atau coba kata kunci lain.',
        );

      case SearchLoadState.error:
        return ErrorStateView(
          message: searchVm.errorMessage ?? 'Gagal mencari lokasi.',
          onRetry: () => searchVm.search(_controller.text),
        );

      case SearchLoadState.success:
        return ListView.separated(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: searchVm.results.length,
          separatorBuilder: (_, _) => const Divider(height: 1, indent: 16),
          itemBuilder: (context, index) {
            final location = searchVm.results[index];
            return _buildLocationTile(
              context: context,
              location: location,
              searchVm: searchVm,
              leadingIcon: Icons.location_on_outlined,
            );
          },
        );
    }
  }

  Widget _buildFavoritesAndHistory(
    BuildContext context,
    SearchViewModel searchVm,
  ) {
    final favorites = searchVm.favorites;
    final history = searchVm.history;

    if (favorites.isEmpty && history.isEmpty) {
      return const EmptyStateView(
        icon: Icons.travel_explore_rounded,
        title: 'Cari Kota Favorit Anda',
        subtitle:
            'Ketik nama kota di kolom pencarian di atas untuk melihat prakiraan cuaca.',
      );
    }

    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 8),
      children: [
        if (favorites.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
            child: Row(
              children: [
                Icon(Icons.star_rounded, size: 18, color: colorScheme.primary),
                const SizedBox(width: 6),
                Text(
                  'Lokasi Favorit',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: colorScheme.primary,
                  ),
                ),
              ],
            ),
          ),
          ...favorites.map(
            (loc) => _buildLocationTile(
              context: context,
              location: loc,
              searchVm: searchVm,
              leadingIcon: Icons.location_city_rounded,
            ),
          ),
          const SizedBox(height: 12),
        ],
        if (history.isNotEmpty) ...[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 8, 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(
                      Icons.history_rounded,
                      size: 18,
                      color: colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      'Riwayat Pencarian',
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
                TextButton(
                  onPressed: () => searchVm.clearHistory(),
                  child: const Text('Hapus Semua'),
                ),
              ],
            ),
          ),
          ...history.map(
            (loc) => _buildLocationTile(
              context: context,
              location: loc,
              searchVm: searchVm,
              leadingIcon: Icons.history_rounded,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildLocationTile({
    required BuildContext context,
    required Location location,
    required SearchViewModel searchVm,
    required IconData leadingIcon,
  }) {
    final isFav = searchVm.isFavorite(location);
    final colorScheme = Theme.of(context).colorScheme;

    return ListTile(
      leading: Icon(leadingIcon, color: colorScheme.primary),
      title: Text(
        location.name,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
      subtitle: location.subtitle.isNotEmpty
          ? Text(location.subtitle)
          : Text(
              '${location.latitude.toStringAsFixed(2)}, ${location.longitude.toStringAsFixed(2)}',
            ),
      trailing: IconButton(
        tooltip: isFav ? 'Hapus dari favorit' : 'Simpan sebagai favorit',
        icon: Icon(
          isFav ? Icons.star_rounded : Icons.star_border_rounded,
          color: isFav ? const Color(0xFFFFB300) : colorScheme.onSurfaceVariant,
        ),
        onPressed: () => searchVm.toggleFavorite(location),
      ),
      onTap: () => _onSelectLocation(location),
    );
  }
}
