// import 'dart:io';
//
// import 'package:flutter/material.dart';
// import 'package:lost_and_found/model/draft.dart';
//
// class ProductPopUp extends StatelessWidget {
// const DraftProductCard({
// super.key,
// required this.draft,
// required this.onDelete,
// required this.onTap,
// });
//
// final RequestDraft draft;
// final VoidCallback onDelete;
// final VoidCallback onTap;
//
// void showProductDetails(Product product) {
//   final isNetworkImage = product.imageUrl.startsWith('http');
//   Navigator.push(
//     context,
//     PageRouteBuilder(
//       opaque: false,
//       barrierDismissible: true,
//       barrierColor: Colors.black54,
//       transitionDuration: const Duration(milliseconds: 100),
//       transitionsBuilder: (context, animation, secondaryAnimation, child) =>
//           FadeTransition(opacity: animation, child: child),
//       pageBuilder: (context, animation, secondaryAnimation) => Dialog(
//         insetPadding: const EdgeInsets.all(20),
//         clipBehavior: Clip.antiAlias,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(24),
//         ),
//         child: SingleChildScrollView(
//           child: Column(
//             mainAxisSize: MainAxisSize.min,
//             crossAxisAlignment: CrossAxisAlignment.stretch,
//             children: [
//               SizedBox(
//                 height: 320,
//                 child: Stack(
//                   // fit: StackFit.passthrough,
//                   fit: StackFit.expand,
//                   children: [
//                     Hero(
//                       tag: product,
//                       child: isNetworkImage
//                           ? Image.network(
//                         product.imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return _imageError();
//                         },
//                       )
//                           : Image.asset(
//                         product.imageUrl,
//                         fit: BoxFit.cover,
//                         errorBuilder: (context, error, stackTrace) {
//                           return _imageError();
//                         },
//                       ),
//                     ),
//                     DecoratedBox(
//                       decoration: BoxDecoration(
//                         gradient: LinearGradient(
//                           begin: Alignment.topCenter,
//                           end: Alignment.bottomCenter,
//                           colors: [
//                             Colors.transparent,
//                             Colors.black.withValues(alpha: 0.7),
//                           ],
//                         ),
//                       ),
//                     ),
//                     Positioned(
//                       top: 8,
//                       right: 8,
//                       child: IconButton(
//                         icon: const Icon(Icons.close, color: Colors.white),
//                         style: IconButton.styleFrom(
//                           backgroundColor: Colors.black38,
//                         ),
//                         onPressed: () => Navigator.pop(context),
//                       ),
//                     ),
//                     Positioned(
//                       left: 20,
//                       right: 20,
//                       bottom: 16,
//                       child: Text(
//                         product.name,
//                         style: const TextStyle(
//                           fontSize: 28,
//                           fontWeight: FontWeight.w800,
//                           color: Colors.white,
//                         ),
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//               Padding(
//                 padding: const EdgeInsets.all(20),
//                 child: Column(
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Row(
//                       children: [
//                         const Icon(Icons.account_circle_outlined, size: 20),
//                         const SizedBox(width: 6),
//                         Text(
//                           product.username,
//                           style: const TextStyle(
//                             fontSize: 16,
//                             fontWeight: FontWeight.bold,
//                           ),
//                         ),
//                         const SizedBox(width: 8),
//                         const Icon(Icons.chat_bubble_outline, size: 20),
//                         const Spacer(),
//                         Chip(
//                           label: Text(product.isFound ? "Found" : "Lost"),
//                           backgroundColor: product.isFound
//                               ? Colors.green.shade100
//                               : Colors.red.shade100,
//                           side: BorderSide.none,
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 24),
//                     Row(
//                       children: [
//                         const Icon(Icons.location_on_outlined, size: 20),
//                         const SizedBox(width: 6),
//                         Expanded(
//                           child: Text(
//                             product.location,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ),
//                       ],
//                     ),
//                     const SizedBox(height: 12),
//                     Row(
//                       children: [
//                         const Icon(Icons.category_outlined, size: 20),
//                         const SizedBox(width: 6),
//                         Text(
//                           "${product.category} • ${product.subcategory}",
//                           style: const TextStyle(fontSize: 16),
//                         ),
//                       ],
//                     ),
//                     const Divider(height: 24),
//                     Container(
//                       width: double.infinity,
//                       padding: const EdgeInsets.all(14),
//                       decoration: BoxDecoration(
//                         border: Border.all(color: Colors.grey.shade300),
//                         borderRadius: BorderRadius.circular(12),
//                       ),
//                       child: Column(
//                         crossAxisAlignment: CrossAxisAlignment.start,
//                         children: [
//                           const Text(
//                             "Description",
//                             style: TextStyle(
//                               fontSize: 14,
//                               fontWeight: FontWeight.bold,
//                               color: Colors.black54,
//                             ),
//                           ),
//                           const SizedBox(height: 6),
//                           Text(
//                             product.description,
//                             style: const TextStyle(fontSize: 16),
//                           ),
//                         ],
//                       ),
//                     ),
//                   ],
//                 ),
//               ),
//             ],
//           ),
//         ),
//       ),
//     ),
//   );
// }
