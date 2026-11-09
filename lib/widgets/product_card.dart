import 'package:flutter/material.dart';
import 'package:lost_and_found/model/product.dart';

import 'dart:io';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    // return Container(
    //   width: double.infinity,
    //   padding: EdgeInsets.all(10),
    //   decoration: BoxDecoration(
    //     color: Colors.lightBlueAccent,
    //     borderRadius: BorderRadius.circular(16),
    //     boxShadow: [
    //       BoxShadow(
    //         color: Colors.black.withValues(alpha: 0.4),
    //         spreadRadius: 2,
    //         blurRadius: 7,
    //         offset: const Offset(4, 4),
    //       ),
    //     ],
    //   ),
    //   child: Column(
    //     crossAxisAlignment: CrossAxisAlignment.start,
    //     children: [
    //       ClipRect(
    //         child: Image.asset(
    //           product.imageUrl,
    //           height: 100,
    //           width: double.infinity,
    //           fit: BoxFit.cover,
    //         ),
    //       ),
    //       Padding(
    //         padding: const EdgeInsets.all(8.0),
    //         child: Column(
    //           crossAxisAlignment: CrossAxisAlignment.start,
    //           children: [
    //             Text(
    //               product.name,
    //               style: TextStyle(
    //                 fontFamily: 'HelveticaNeue',
    //                 fontSize: 18,
    //                 fontWeight: FontWeight.w800,
    //               ),
    //               maxLines: 1,
    //               overflow: TextOverflow.ellipsis,
    //             ),
    //             const SizedBox(height: 4.0),
    //             Text(
    //               product.description,
    //               style: TextStyle(fontSize: 14),
    //               maxLines: 2,
    //               overflow: TextOverflow.ellipsis,
    //             )
    //           ]
    //         )
    //       )
    //     ],
    //   ),
    // );
    final isNetworkImage = product.imageUrl.startsWith('http');

    return Container(
      height: 180,
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            spreadRadius: 2,
            blurRadius: 7,
            offset: const Offset(4, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            Positioned.fill(
              child: Hero(
                tag: product,
                child: Image.asset(product.imageUrl, fit: BoxFit.cover),
              ),
            ),

              child: isNetworkImage
                  ? Image.network(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imageError();
                      },
                    )
                  : Image.asset(
                      product.imageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return _imageError();
                      },
                    ),
            ),
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Colors.transparent,
                      Colors.black.withValues(alpha: 0.7),
                    ],
                  ),
                ),
              ),
            ),

            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(12.0),
            Positioned(
              top: 12,
              left: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: product.isFound ? Colors.green : Colors.redAccent,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      product.isFound
                          ? Icons.check_circle
                          : Icons.error_outline,
                      color: Colors.white,
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      product.isFound ? 'FOUND' : 'LOST',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Align(
              alignment: Alignment.bottomLeft,
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: TextStyle(
                        fontFamily: 'HelveticaNeue',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: Colors.white,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    const SizedBox(height: 3),
                    Text(
                      product.description,
                      style: TextStyle(fontSize: 14, color: Colors.white),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        const Icon(
                          Icons.location_on,
                          color: Colors.lightBlueAccent,
                          size: 14,
                        ),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            product.location,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Colors.lightBlueAccent,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

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
}
