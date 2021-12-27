import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:rento_vendor/screen/add_new_product_screen.dart';
import 'package:rento_vendor/widgets/drawer_menu_widget.dart';
import 'package:rento_vendor/widgets/published_product.dart';
import 'package:rento_vendor/widgets/unpublished_product.dart';

class ProductScreen extends StatelessWidget {
  static const String id = 'product-screen';

  const ProductScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        drawer: const DrawerMenu(),
        appBar: AppBar(
          backgroundColor: const Color(0xFF3c5784),
          title: const Text('Product'),
          actions: <Widget>[
            IconButton(
              icon: const Icon(
                CupertinoIcons.search,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(
                CupertinoIcons.bell,
                color: Colors.white,
              ),
              onPressed: () {},
            ),
          ],
        ),
        body: Column(
          children: [
            Material(
              elevation: 3,
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        child: Row(
                          children: [
                            Text('Products'),
                            SizedBox(
                              width: 10,
                            ),
                            CircleAvatar(
                              backgroundColor: Colors.black54,
                              maxRadius: 8,
                              child: FittedBox(
                                child: Padding(
                                  padding: const EdgeInsets.all(6.0),
                                  child: Text(
                                    '20',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    TextButton.icon(
                        onPressed: () {
                          Navigator.pushNamed(context, AddNewProduct.id);
                        },
                        style: ButtonStyle(
                            backgroundColor: MaterialStateProperty.all(
                                Theme.of(context).primaryColor)),
                        icon: Icon(
                          Icons.add,
                          color: Colors.white,
                        ),
                        label: Text(
                          'Add New',
                          style: TextStyle(color: Colors.white),
                        ))
                  ],
                ),
              ),
            ),
            TabBar(
                indicatorColor: Theme.of(context).primaryColor,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.black54,
                tabs: [
                  Tab(
                    text: 'PUBLISHED',
                  ),
                  Tab(
                    text: 'UNPUBLISHED',
                  ),
                ]),
            Expanded(
              child: Container(
                child: TabBarView(children: [
                  // Center(
                  //   child: Text('Published Services'),
                  // ),
                  PublishedProduct(),
                  UnpublishedProduct(),
                ]),
              ),
            )
          ],
        ),
      ),
    );
  }
}
