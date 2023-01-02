import 'package:flutter/material.dart';
import 'package:chatroom/screens/chatroom.dart';
import 'package:chatroom/utils/shared_preference.dart';
import 'package:chatroom/utils/color_utils.dart';
import 'package:chatroom/reusable_widgets/reuse.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextEditingController _usernametextController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: hexStringToColor("333333"),
        elevation: 0,
        title: const Text(
          "Flutter Chatroom App",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      body: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        decoration: BoxDecoration(
            gradient: LinearGradient(colors: [
          hexStringToColor("333333"),
          hexStringToColor("444444"),
          hexStringToColor("555555")
        ], begin: Alignment.topCenter, end: Alignment.bottomCenter)),
        child: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.fromLTRB(
                20, MediaQuery.of(context).size.height * 0.15, 20, 10),
            child: Column(
              children: <Widget>[
                SizedBox(
                  height: 40,
                ),
                logoWidget("assets/images/Person.png"),
                SizedBox(
                  height: 40,
                ),
                reusableTextField("Enter Username", Icons.person_outline,
                    _usernametextController),
                SizedBox(
                  height: 10,
                ),
                reuseButton(context, () async {
                  await UserSimplePreferences.setUsername(
                      _usernametextController.text);
                  _usernametextController.clear();
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ChatRoom()));
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
