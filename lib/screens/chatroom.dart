import 'package:chatroom/reusable_widgets/reuse.dart';
import 'package:flutter/material.dart';
import 'package:chatroom/utils/shared_preference.dart';
import 'package:chatroom/utils/color_utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

class ChatRoom extends StatefulWidget {
  const ChatRoom({Key? key}) : super(key: key);
  @override
  _ChatRoomState createState() => new _ChatRoomState();
}

class _ChatRoomState extends State<ChatRoom> {
  String username = "";
  TextEditingController _message = TextEditingController();
  ScrollController _scrollController = ScrollController();
  int curindex = 0;
  final chatrooms = ['cricket', 'football', 'music', 'art', 'coding'];

  @override
  void initState() {
    super.initState();
    username = UserSimplePreferences.getUsername() ?? "Anonymous";
  }

  @override
  Widget build(BuildContext context) => Scaffold(
      appBar: AppBar(
        backgroundColor: hexStringToColor("333333"),
        elevation: 0,
        title: Text(
          "${toBeginningOfSentenceCase(chatrooms[curindex])} Chatroom",
          style: TextStyle(
              fontSize: 26, fontWeight: FontWeight.bold, color: Colors.white),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: curindex,
        onTap: (index) => setState(() => curindex = index),
        backgroundColor: Colors.black,
        selectedItemColor: Colors.white,
        iconSize: 30,
        selectedLabelStyle: TextStyle(
            fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white),
        unselectedItemColor: Colors.white54,
        showUnselectedLabels: false,
        type: BottomNavigationBarType.fixed,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_cricket),
            label: 'Cricket',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sports_soccer),
            label: 'Football',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            label: 'Music',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.palette),
            label: 'Art',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.computer),
            label: 'Coding',
          ),
        ],
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
        child: Container(
          child: Column(
            children: <Widget>[
              chatMessages(),
              Container(
                alignment: Alignment.bottomCenter,
                width: MediaQuery.of(context).size.width,
                child: Container(
                  padding: EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                  color: hexStringToColor("222222"),
                  child: Row(
                    children: [
                      Expanded(
                          child: TextField(
                        controller: _message,
                        style: TextStyle(color: Colors.white.withOpacity(0.9)),
                        decoration: InputDecoration(
                            suffixIcon: IconButton(
                              icon: Icon(Icons.send),
                              color: Colors.white,
                              onPressed: () {
                                _scrollController.animateTo(
                                    _scrollController.position.maxScrollExtent,
                                    duration: Duration(milliseconds: 400),
                                    curve: Curves.easeOut);
                                final msg = _message.text;
                                _message.clear();
                                createMsg(Message: msg);
                              },
                            ),
                            hintText: "Message ...",
                            hintStyle: TextStyle(
                              color: Colors.white.withOpacity(0.9),
                              fontSize: 16,
                            ),
                            border: InputBorder.none),
                      )),
                    ],
                  ),
                ),
              )
            ],
          ),
        ),
      ));

  Widget chatMessages() {
    return Expanded(
      flex: 2,
      child: StreamBuilder(
        stream: readChat(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Text("Something Went Wrong! ${snapshot.error}");
          } else if (snapshot.hasData) {
            final chats = snapshot.data!;

            return ListView.builder(
              controller: _scrollController,
              itemCount: chats.length + 1,
              itemBuilder: (context, index) {
                if (index == chats.length) {
                  return const SizedBox(
                    height: 80,
                  );
                }
                return MessageTile(
                  message: chats[index].Message,
                  sendByMe: (chats[index].User == username) ? true : false,
                  time: chats[index].Time.substring(0,16)+chats[index].Time.substring(19,22),
                  user: chats[index].User,
                );
              },
            );
          } else {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
    );
  }

  Stream<List<Chat>> readChat() => FirebaseFirestore.instance
      .collection(chatrooms[curindex])
      .orderBy('Time', descending: false)
      .snapshots()
      .map((snapshot) =>
          snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList());

  Future createMsg({required String Message}) async {
    final docref = FirebaseFirestore.instance.collection(chatrooms[curindex]).doc();
    final now = DateTime.now();
    String formatter = DateFormat('dd/MM/yyyy hh:mm:ss a').format(now);
    final chat = Chat(
      Message: Message,
      User: username,
      Time: formatter,
    );

    final json = chat.toJson();

    await docref.set(json);
  }
}

class Chat {
  final String Message;
  final String User;
  final String Time;

  Chat({
    required this.Message,
    required this.User,
    required this.Time,
  });

  Map<String, dynamic> toJson() => {
        'Message': Message,
        'User': User,
        'Time': Time,
      };

  static Chat fromJson(Map<String, dynamic> json) =>
      Chat(Message: json['Message'], User: json['User'], Time: json['Time']);
}
