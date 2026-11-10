import 'package:flutter/material.dart';
import 'package:lost_and_found/model/product.dart';

// Display full item details
class ProductPopUp extends StatefulWidget {
  final Product product;

  const ProductPopUp({super.key, required this.product});

  @override
  State<ProductPopUp> createState() => _ProductPopUpState();
}

class _ProductPopUpState extends State<ProductPopUp> {
  // Current image index
  int _activePageIndex = 0;

  // Opens full-screen image viewer
  void _openFullscreenViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    final pageController = PageController(initialPage: initialIndex);

    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        int currentIndex = initialIndex;

        return StatefulBuilder(
          builder: (context, setDialogState) {
            return Scaffold(
              backgroundColor: Colors.black,
              appBar: AppBar(
                backgroundColor: Colors.black,
                foregroundColor: Colors.white,
                elevation: 0,
                title: Text(
                  imageUrls.length > 1
                      ? "${currentIndex + 1} of ${imageUrls.length}"
                      : "",
                  style: const TextStyle(fontSize: 16, color: Colors.white),
                ),
                centerTitle: true,
                leading: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
              body: Stack(
                alignment: Alignment.center,
                children: [
                  // Fullscreen PageView
                  PageView.builder(
                    controller: pageController,
                    itemCount: imageUrls.length,
                    onPageChanged: (index) {
                      setDialogState(() {
                        currentIndex = index;
                      });
                    },
                    itemBuilder: (context, index) {
                      final url = imageUrls[index];
                      final isNet = url.startsWith('http');

                      return InteractiveViewer(
                        minScale: 1.0,
                        maxScale: 4.0,
                        child: Center(
                          child: isNet
                              ? Image.network(
                                  url,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stack) =>
                                      _imageError(),
                                )
                              : Image.asset(
                                  url,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stack) =>
                                      _imageError(),
                                ),
                        ),
                      );
                    },
                  ),
                  // Navigation Arrows for Multiple Images
                  if (imageUrls.length > 1) ...[
                    if (currentIndex > 0)
                      Positioned(
                        left: 12,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_back_ios,
                            color: Colors.white70,
                            size: 28,
                          ),
                          onPressed: () {
                            pageController.previousPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                    if (currentIndex < imageUrls.length - 1)
                      Positioned(
                        right: 12,
                        child: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            color: Colors.white70,
                            size: 28,
                          ),
                          onPressed: () {
                            pageController.nextPage(
                              duration: const Duration(milliseconds: 250),
                              curve: Curves.easeInOut,
                            );
                          },
                        ),
                      ),
                  ],
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final imageUrls = widget.product.imageUrls;
    final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Dialog(
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxHeight),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Top Image Header
              SizedBox(
                height: 280,
                child: ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(24),
                  ),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      PageView.builder(
                        itemCount: imageUrls.length,
                        onPageChanged: (index) {
                          setState(() {
                            _activePageIndex = index;
                          });
                        },
                        itemBuilder: (context, index) {
                          final url = imageUrls[index];
                          final isNet = url.startsWith('http');

                          Widget imageWidget = isNet
                              ? Image.network(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _imageError(),
                                )
                              : Image.asset(
                                  url,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) =>
                                      _imageError(),
                                );

                          return GestureDetector(
                            onTap: () => _openFullscreenViewer(
                              context,
                              imageUrls,
                              index,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                imageWidget,
                                DecoratedBox(
                                  decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        Colors.black.withValues(alpha: 0.2),
                                        Colors.black.withValues(alpha: 0.85),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),

                      // Close Button
                      Positioned(
                        top: 8,
                        right: 8,
                        child: IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          style: IconButton.styleFrom(
                            backgroundColor: Colors.black38,
                          ),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ),

                      // Image Page Counter Badge
                      if (imageUrls.length > 1)
                        Positioned(
                          top: 12,
                          left: 12,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black54,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              "${_activePageIndex + 1} / ${imageUrls.length}",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),

                      // Product Title
                      Positioned(
                        left: 20,
                        right: 80,
                        bottom: 16,
                        child: Text(
                          widget.product.name,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Product information
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Row(
                            children: [
                              const Icon(
                                Icons.account_circle_outlined,
                                size: 20,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  widget.product.username,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 8),
                              const Icon(Icons.chat_bubble_outline, size: 20),
                            ],
                          ),
                        ),
                        // const SizedBox(width: 8),
                        // Chip(
                        //   label: Text(
                        //     widget.product.isFound ? "Found" : "Contact",
                        //   ),
                        //   backgroundColor: widget.product.isFound
                        //       ? Colors.green.shade100
                        //       : Colors.red.shade100,
                        //   side: BorderSide.none,
                        //   visualDensity: VisualDensity.compact,
                        // ),
                      ],
                    ),
                    const Divider(height: 24),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            widget.product.location,
                            style: const TextStyle(fontSize: 16),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.category_outlined, size: 20),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "${widget.product.category} • ${widget.product.subcategory}",
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 24),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "Description",
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            widget.product.description,
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
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

// Placeholder error icon displayed when an image URL fails to load.
Widget _imageError() {
  return Container(
    color: Colors.deepPurple.shade100,
    child: const Icon(
      Icons.image_not_supported,
      size: 50,
      color: Colors.deepPurple,
    ),
  );
}
