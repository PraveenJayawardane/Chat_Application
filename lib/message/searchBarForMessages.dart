import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firestore_search/firestore_search.dart';

class searchBar extends StatefulWidget {
  searchBar(this.id, {Key? key}) : super(key: key);
  String? id;

  @override
  State<searchBar> createState() => _searchBarState(id);
}

class _searchBarState extends State<searchBar> {
  _searchBarState(this.id);
  String? id;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage("assets/background.jpg"),
          fit: BoxFit.cover,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
            child: FirestoreSearchScaffold(
          scaffoldBody: Center(),
          appBarBackgroundColor: Colors.transparent,
          scaffoldBackgroundColor: Colors.transparent,
          searchBodyBackgroundColor: Colors.transparent,
          searchBackgroundColor: Colors.grey,
          firestoreCollectionName: 'message/messages$id/names',
          searchBy: 'name',
          dataListFromSnapshot: DataModel().dataListFromSnapshot,
          builder: (context, snapshot) {
            if (snapshot.hasData) {
              List<DataModel>? dataList = snapshot.data;
              if (dataList!.isEmpty) {
                return const Center(
                  child: Text('No Contacts',
                      style: TextStyle(color: Colors.white)),
                );
              }
              return ListView.builder(
                  itemCount: dataList.length,
                  itemBuilder: (context, index) {
                    final DataModel data = dataList[index];

                    return ListTile(
                      leading: CircleAvatar(child: Icon(Icons.person)),
                      title: Text(data.name.toString(),
                          style: TextStyle(color: Colors.white)),
                    );
                  });
            } else {
              print('object');
              return const Center(
                child: Text('data'),
              );
            }
          },
        )),
      ),
    );
  }
}

class DataModel {
  final String? name;

  DataModel({this.name});

  List<DataModel> dataListFromSnapshot(QuerySnapshot querySnapshot) {
    return querySnapshot.docs.map((snapshot) {
      final Map<String, dynamic> dataMap =
          snapshot.data() as Map<String, dynamic>;

      return DataModel(name: dataMap['name']);
    }).toList();
  }
}
