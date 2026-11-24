import 'package:flutter/material.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/pages/chat_page.dart';
import 'package:lost_and_found/services/user_service.dart';
import 'package:lost_and_found/widgets/app_image.dart';
import 'package:photo_view/photo_view.dart';
import 'package:photo_view/photo_view_gallery.dart';

// Display full item details
class ProductPage extends StatefulWidget {
  final Product product;

  const ProductPage({super.key, required this.product});

  @override
  State<ProductPage> createState() => _ProductPageState();
}

class _ProductPageState extends State<ProductPage> {
  // Current image index
  int _activePageIndex = 0;

  Future<void> _messageOwner() async {
    final currentUser = UserService.currentUser;
    final ownerId = widget.product.userId;
    final productId = widget.product.id;

    if (currentUser == null) {
      if (!mounted) return;
      Navigator.pop(context);
      Navigator.pushNamed(context, '/login');
      return;
    }

    if (ownerId == null || productId == null) {
      _showMessage('This product does not have an owner yet.');
      return;
    }

    if (ownerId == currentUser.id) {
      _showMessage('You cannot message yourself.');
      return;
    }

    try {
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => ChatPage(otherUserId: ownerId, productId: productId),
        ),
      );
    } catch (error) {
      _showMessage('Could not start conversation: $error');
    }
  }

  void _showMessage(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  // Opens the built-in PhotoView gallery.
  void _openFullscreenViewer(
    BuildContext context,
    List<String> imageUrls,
    int initialIndex,
  ) {
    showDialog(
      context: context,
      barrierColor: Colors.black,
      builder: (context) {
        int currentIndex = initialIndex;
        final pageController = PageController(initialPage: initialIndex);

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
                children: [
                  PhotoViewGallery.builder(
                    pageController: pageController,
                    itemCount: imageUrls.length,
                    backgroundDecoration: const BoxDecoration(
                      color: Colors.black,
                    ),
                    scrollPhysics: const BouncingScrollPhysics(),
                    onPageChanged: (index) {
                      setDialogState(() {
                        currentIndex = index;
                      });
                    },
                    builder: (context, index) {
                      final url = imageUrls[index];
                      return PhotoViewGalleryPageOptions(
                        imageProvider: AppImage.providerFor(url),
                        minScale: PhotoViewComputedScale.contained,
                        maxScale: PhotoViewComputedScale.covered * 2.5,
                      );
                    },
                  ),
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
    // final maxHeight = MediaQuery.of(context).size.height * 0.85;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
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
                          return GestureDetector(
                            onTap: () => _openFullscreenViewer(
                              context,
                              imageUrls,
                              index,
                            ),
                            child: Stack(
                              fit: StackFit.expand,
                              children: [
                                AppImage(source: url, fit: BoxFit.cover),
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
                              IconButton(
                                onPressed: _messageOwner,
                                icon: const Icon(Icons.chat_bubble_outline),
                              ),
                            ],
                          ),
                        ),
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
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: _messageOwner,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Message Owner'),
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
