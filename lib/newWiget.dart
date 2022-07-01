import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/src/foundation/key.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:otp_auth/Provider/StateManagement.dart';
import 'package:provider/provider.dart';

class MyWidget extends StatefulWidget {
  const MyWidget({Key? key}) : super(key: key);

  @override
  State<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends State<MyWidget> {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('message')
          .doc(
              'messages${Provider.of<StateManagement>(context, listen: false).id}')
          .collection('contacts')
          .snapshots(),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasData) {
          return ListView(
              physics: BouncingScrollPhysics(),
              scrollDirection: Axis.vertical,
              shrinkWrap: true,
              children:
                  snapshot.data!.docs.map((DocumentSnapshot documentSnapshot) {
                if (documentSnapshot.data() == null) {
                  return const Center(child: CircularProgressIndicator());
                } else {
                  return Column(
                    children: [
                      ListTile(
                        visualDensity:
                            const VisualDensity(horizontal: 0, vertical: -4),
                        contentPadding: const EdgeInsets.only(left: 5),
                        minVerticalPadding: 2,
                        horizontalTitleGap: 2,
                        leading: CircleAvatar(
                            radius: 17,
                            child: Text(documentSnapshot['name']
                                .toString()
                                .substring(0, 1))),
                        title: Text(documentSnapshot['name'],
                            style: const TextStyle(
                                color: Colors.white, fontSize: 16)),
                        onTap: () async {},
                      ),
                      const Divider(
                        thickness: 1,
                        height: 0,
                        indent: 50,
                        color: Colors.white,
                      )
                    ],
                  );
                }
              }).toList());
        }
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        } else {
          return const Center(child: CircularProgressIndicator());
        }
      },
    );
  }
}
