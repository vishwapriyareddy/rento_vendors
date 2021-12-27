import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:rento_vendor/screen/edit_view_product.dart';
import 'package:rento_vendor/services/firebase_services.dart';

class UnpublishedProduct extends StatelessWidget {
  const UnpublishedProduct({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    FirebaseServices _services = FirebaseServices();
    return Container(
      child: StreamBuilder<QuerySnapshot?>(
          stream: _services.services
              .where('published', isEqualTo: false)
              .snapshots(),
          builder:
              (BuildContext context, AsyncSnapshot<QuerySnapshot?> snapshot) {
            if (snapshot.hasError) {
              return Text('Something Went Wrong');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator());
            }
            return SingleChildScrollView(
              child: FittedBox(
                child: DataTable(
                  columns: <DataColumn>[
                    DataColumn(label: Expanded(child: Text('Service '))),
                    DataColumn(label: Text('Image')),
                    DataColumn(label: Text('Info')),
                    DataColumn(label: Text('Actions')),
                  ],
                  rows: _serviceDetails(snapshot.data!, _services, context),
                  showBottomBorder: true,
                  dataRowHeight: 60,
                  headingRowColor: MaterialStateProperty.all(Colors.grey[200]),
                ),
              ),
            );
          }),
    );
  }

  List<DataRow> _serviceDetails(
      QuerySnapshot snapshot, FirebaseServices services, context) {
    List<DataRow> newList = snapshot.docs.map((DocumentSnapshot document) {
      // if (document != null) {
      return DataRow(cells: [
        DataCell(Container(
            child: Expanded(
          child: ListTile(
            title: Row(
              children: [
                Expanded(
                  child: Text(
                    'Name: ',
                    style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                ),
                Expanded(
                  child: Text(
                    document.get('serviceName'),
                    style: TextStyle(fontSize: 15),
                  ),
                ),
              ],
            ),
          ),
        ))),
        DataCell(Container(
            child: Padding(
          padding: const EdgeInsets.all(3.0),
          child: Row(children: [
            Image.network(
              document.get('serviceImage'),
              width: 50,
            )
          ]),
        ))),
        DataCell(IconButton(
          icon: Icon(Icons.info_outline),
          onPressed: () {
            Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        EditViewProduct(serviceId: document.get('serviceId'))));
          },
        )),
        DataCell(popUpButton(document.data())),
      ]);
    }).toList();
    return newList;
  }

  Widget popUpButton(data, {BuildContext? context}) {
    FirebaseServices _services = FirebaseServices();
    return PopupMenuButton(
        onSelected: (String value) {
          if (value == 'publish') {
            _services.publishService(id: data['serviceId']);
          }
          if (value == 'delete') {
            _services.deleteService(id: data['serviceId']);
          }
        },
        itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.check),
                  title: Text('Publish'),
                ),
                value: 'publish',
              ),
              const PopupMenuItem(
                child: ListTile(
                  leading: Icon(Icons.delete_outlined),
                  title: Text('Delete Product'),
                ),
                value: 'delete',
              ),
            ]);
  }
}
