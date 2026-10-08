import 'package:flutter/material.dart';
import 'package:lost_and_found/model/product.dart';
import 'package:lost_and_found/widgets/product_card.dart';

class Home extends StatefulWidget {
  const Home({super.key});


  @override
  State<Home> createState() => _Home();
}

class _Home extends State<Home>{
  Product x = Product(name: "leather jacket", description: "black leather jacket", imageUrl: "lib/images/black_leather_jacket.webp");
  @override
  Widget build(BuildContext context){
    return Scaffold(
      appBar: AppBar(title: const Text("Home")),
      backgroundColor: Colors.blueAccent,
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Column(
                children: [
                  ProductCard(product: x),
                ],
              ),
            ),
          ],
        ),
      )
    );
  }
}