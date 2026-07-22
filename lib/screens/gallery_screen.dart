import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../utils/image_utils.dart';

class GalleryScreen extends StatefulWidget {
  final VoidCallback onBack;

  const GalleryScreen({super.key, required this.onBack});

  @override
  State<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends State<GalleryScreen> {
  List<dynamic> _categories = [];
  List<dynamic> _galleryItems = [];
  int? _selectedCategoryId;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchGalleryData();
  }

  Future<void> fetchGalleryData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString('cache_gallery');

      if (cachedData != null) {
        final data = json.decode(cachedData);
        if (mounted) {
          setState(() {
            _categories = data['categories'] ?? [];
            _galleryItems = data['items'] ?? data['data'] ?? [];
            if (_categories.isNotEmpty && _selectedCategoryId == null) {
              _selectedCategoryId = _categories[0]['id'];
            }
            _isLoading = false;
          });
        }
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.23/mandorbangun.id/api/gallery.php'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['success'] == true) {
          prefs.setString('cache_gallery', response.body);
          if (mounted) {
            setState(() {
              _categories = data['categories'] ?? [];
              _galleryItems = data['items'] ?? data['data'] ?? [];
              if (_categories.isNotEmpty && _selectedCategoryId == null) {
                _selectedCategoryId = _categories[0]['id'];
              }
              _isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      if (mounted && _categories.isEmpty) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _filterByCategory(int? categoryId) {
    setState(() {
      _selectedCategoryId = categoryId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final filteredItems = _selectedCategoryId == null
        ? _galleryItems
        : _galleryItems
              .where(
                (item) =>
                    item['category_id'].toString() ==
                    _selectedCategoryId.toString(),
              )
              .toList();

    return _isLoading
        ? const Center(
            child: CircularProgressIndicator(color: Color(0xFFD4AF37)),
          )
        : SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 150),
                SizedBox(
                  width: double.infinity,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Text(
                        'GALERI KAMI',
                        style: TextStyle(
                          color: Color(0xFFD4AF37),
                          fontSize: 20,
                          fontWeight: FontWeight.w900,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      Container(
                        margin: const EdgeInsets.only(top: 5),
                        height: 4,
                        width: 40,
                        decoration: BoxDecoration(
                          color: const Color(0xFFD4AF37),
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      const SizedBox(height: 15),
                      const Padding(
                        padding: EdgeInsets.symmetric(horizontal: 30),
                        child: Text(
                          'Setiap proyek adalah cerita. Temukan inspirasi dari karya desain dan konstruksi yang telah kami wujudkan.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.grey,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (_categories.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(
                      top: 24,
                      left: 24,
                      right: 24,
                      bottom: 24,
                    ),
                    child: SizedBox(
                      width: double.infinity,
                      child: Wrap(
                        alignment: WrapAlignment.center,
                        spacing: 12,
                        runSpacing: 10,
                        children: List.generate(_categories.length, (index) {
                          final category = _categories[index];
                          final isSelected =
                              _selectedCategoryId == category['id'];
                          return GestureDetector(
                            onTap: () => _filterByCategory(category['id']),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? const Color(0xFFD4AF37)
                                    : Colors.transparent,
                                border: Border.all(
                                  color: isSelected
                                      ? const Color(0xFFD4AF37)
                                      : Colors.white.withValues(alpha: 0.3),
                                  width: 2,
                                ),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                category['name'],
                                style: TextStyle(
                                  color: isSelected
                                      ? const Color(0xFF0a0a0a)
                                      : Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          );
                        }),
                      ),
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: filteredItems.isEmpty
                      ? const Padding(
                          padding: EdgeInsets.all(20),
                          child: Text(
                            'Tidak ada galeri',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : GridView.builder(
                          padding: EdgeInsets.zero,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate:
                              const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 16,
                                mainAxisSpacing: 16,
                                childAspectRatio: 0.85,
                              ),
                          itemCount: filteredItems.length,
                          itemBuilder: (context, index) {
                            final item = filteredItems[index];
                            var imageUrl =
                                item['main_image_path'] ??
                                item['main_image'] ??
                                item['image_path'] ??
                                '';

                            if (imageUrl.isNotEmpty &&
                                !imageUrl.startsWith('http')) {
                              imageUrl = getOptimizedImageUrl(
                                imageUrl,
                                size: 'thumb',
                              );
                            }

                            return GestureDetector(
                              onTap: () {
                                showGalleryDetailModal(context, item, imageUrl);
                              },
                              child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: Colors.white.withValues(alpha: 0.1),
                                  ),
                                  color: const Color(0xFF111111),
                                ),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Expanded(
                                      child: ClipRRect(
                                        borderRadius: const BorderRadius.only(
                                          topLeft: Radius.circular(16),
                                          topRight: Radius.circular(16),
                                        ),
                                        child: imageUrl.isNotEmpty
                                            ? buildSafeNetworkImage(
                                                imageUrl,
                                                fit: BoxFit.cover,
                                                cacheWidth: 350,
                                              )
                                            : Container(
                                                color: const Color(0xFF151515),
                                                child: const Icon(
                                                  Icons.image_not_supported,
                                                  color: Colors.grey,
                                                ),
                                              ),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(12),
                                      child: Text(
                                        item['title'],
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600,
                                        ),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                ),
                const SizedBox(height: 120),
              ],
            ),
          );
  }

  void showGalleryDetailModal(
    BuildContext context,
    dynamic item,
    String mainImageUrl,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF111111),
      isScrollControlled: true,
      builder: (context) {
        return GalleryDetailSheet(item: item, mainImageUrl: mainImageUrl);
      },
    );
  }
}

class GalleryDetailSheet extends StatefulWidget {
  final dynamic item;
  final String mainImageUrl;

  const GalleryDetailSheet({
    super.key,
    required this.item,
    required this.mainImageUrl,
  });

  @override
  State<GalleryDetailSheet> createState() => _GalleryDetailSheetState();
}

class _GalleryDetailSheetState extends State<GalleryDetailSheet> {
  late PageController _pageController;
  int _currentImageIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final images = widget.item['images'] ?? [];
    final itemTitle = widget.item['title'] ?? 'Galeri';

    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return SingleChildScrollView(
          controller: scrollController,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.all(20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      itemTitle,
                      style: const TextStyle(
                        color: Color(0xFFD4AF37),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.close, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ),
              if (images.isNotEmpty)
                Column(
                  children: [
                    SizedBox(
                      height: 350,
                      child: PageView.builder(
                        controller: _pageController,
                        onPageChanged: (index) {
                          setState(() => _currentImageIndex = index);
                        },
                        itemCount: images.length,
                        itemBuilder: (context, index) {
                          var imageUrl = images[index]['path'] ?? '';
                          if (imageUrl.isNotEmpty &&
                              !imageUrl.startsWith('http')) {
                            imageUrl =
                                'http://192.168.1.23/mandorbangun.id/$imageUrl';
                          }

                          return ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(16),
                              topRight: Radius.circular(16),
                            ),
                            child: imageUrl.isNotEmpty
                                ? buildSafeNetworkImage(
                                    imageUrl,
                                    fit: BoxFit.cover,
                                  )
                                : Container(
                                    color: const Color(0xFF151515),
                                    child: const Icon(
                                      Icons.image_not_supported,
                                      color: Colors.grey,
                                    ),
                                  ),
                          );
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 16,
                        left: 20,
                        right: 20,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${_currentImageIndex + 1} / ${images.length}',
                            style: const TextStyle(
                              color: Color(0xFFD4AF37),
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          Row(
                            children: List.generate(
                              images.length > 5 ? 5 : images.length,
                              (index) {
                                final isActive =
                                    index == (_currentImageIndex % 5);
                                return Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                  ),
                                  child: Container(
                                    width: isActive ? 20 : 8,
                                    height: 8,
                                    decoration: BoxDecoration(
                                      color: isActive
                                          ? const Color(0xFFD4AF37)
                                          : Colors.grey.withValues(alpha: 0.5),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (images[_currentImageIndex]['caption'] != null &&
                        images[_currentImageIndex]['caption'].isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.all(20),
                        child: Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            images[_currentImageIndex]['caption'],
                            style: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 13,
                              fontStyle: FontStyle.italic,
                            ),
                          ),
                        ),
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 16,
                      ),
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          children: List.generate(images.length, (index) {
                            var thumbUrl = images[index]['path'] ?? '';
                            if (thumbUrl.isNotEmpty &&
                                !thumbUrl.startsWith('http')) {
                              thumbUrl =
                                  'http://192.168.1.23/mandorbangun.id/$thumbUrl';
                            }

                            return GestureDetector(
                              onTap: () {
                                _pageController.animateToPage(
                                  index,
                                  duration: const Duration(milliseconds: 300),
                                  curve: Curves.easeInOut,
                                );
                              },
                              child: Container(
                                margin: const EdgeInsets.only(right: 12),
                                width: 70,
                                height: 70,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: _currentImageIndex == index
                                        ? const Color(0xFFD4AF37)
                                        : Colors.white.withValues(alpha: 0.2),
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(8),
                                  color: const Color(0xFF151515),
                                ),
                                child: ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: thumbUrl.isNotEmpty
                                      ? buildSafeNetworkImage(
                                          thumbUrl,
                                          fit: BoxFit.cover,
                                        )
                                      : const Icon(
                                          Icons.image_not_supported,
                                          color: Colors.grey,
                                          size: 20,
                                        ),
                                ),
                              ),
                            );
                          }),
                        ),
                      ),
                    ),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }
}
