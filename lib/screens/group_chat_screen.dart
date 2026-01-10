import 'dart:convert';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_icons/flutter_icons.dart';
// import 'package:kadingira/models/chat_room_message.dart';
// import 'package:kadingira/models/single_event.dart';
// import 'package:kadingira/models/user.dart';
// import 'package:kadingira/provider/socket_provider.dart';
// import 'package:kadingira/provider/user_provider.dart';
// import 'package:kadingira/screens/profile_user_screen.dart';
// import 'package:kadingira/screens/single_event_screen.dart';
// import 'package:kadingira/utils/utils.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/chat_room_message.dart';
import 'package:nurebo/models/event.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:time_ago_provider/time_ago_provider.dart' as timeAgo;
import 'package:intl/date_symbol_data_local.dart';
import 'package:http/http.dart' as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:intl/src/intl/date_format.dart';


class GroupChatScreen extends StatefulWidget {
  final Event? singleEvent;

  const GroupChatScreen({ Key? key, this.singleEvent, });

  @override
  State<GroupChatScreen> createState() => _GroupChatScreenState();
}

class _GroupChatScreenState extends State<GroupChatScreen> {
  final TextEditingController _textController = TextEditingController();
  late UserProvider userProvider;
  late SocketProvider socketProvider;
  late int chatRoomIndex;
  IO.Socket? socket;
  final ScrollController _scrollController = ScrollController(
      keepScrollOffset: true,
    // initialScrollOffset: 0
  );

  Future insertChatMessage(
    String? message, String? senderId, String? chatId, /*DateTime sentAt, */String? senderUsername, String? senderProfileImage) async {
    DateTime sentAt = DateTime.now();
    // var socketProvider = Provider.of<SocketProvider>(context, listen: false);

    var url = Uri.parse(Utils.httpServerUrl + "event_room/insert");

    Map/*<String, String>*/ body = {
      "sender_id": senderId,
      "event_id": widget.singleEvent!.id,
      "text": message,
      "sent_at": sentAt.toString(),
    };

    //todo: problema
    var response = await http.post(
        url,
        body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
        }
    );
    //print('ciao');

    //print('response.statusCode now');
    //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      DateTime sentAt = DateTime.now();

      //todo: usare userProvider ed inviare tutti i dati con socket.io
      //todo: inviare anche tutto il singleEvent
      socket!.emit(
          "send-room_message",
          {
            "content": message,
            "senderId": senderId,
            "senderUsername": senderUsername,
            "senderProfileImage": senderProfileImage,
            "senderDescription": userProvider.user!.description,
            "senderName": userProvider.user!.name,
            "singleEventId": widget.singleEvent!.id,
            "sentAt": sentAt.toString(),
            // "user_a_last_opening": user_a_last_opening_at.toString(),
            // "user_b_last_opening": user_b_last_opening_at.toString(),
          }
        // ]
      );

      socketProvider.addChatRoomMessage(
          ChatRoomMessage(
              text: message,
              sender: userProvider.user,
              event: widget.singleEvent,
              // id:
              sent_at: sentAt,
              is_visible: 1
            // send_at: DateTime.now(),
            // send_at:
          )
      );

      // socketMessages.add(
      //   new ChatMessage(
      //     text: message,
      //     receiver_id: receiverId,
      //     sender_id: senderId,
      //     // chatId: chatId.toString(),
      //     chat_id: widget.chatId.toString(),
      //     sent_at: sentAt,
      //     type: 'source',
      //     is_visible_for_sender: 1,
      //     is_visible_for_receiver: 1,
      //   )
      // );

      for(var e in socketProvider.chatRooms){
        // if(e.chat_id.toString() == chatId.toString()){
        if(e.event!.id.toString() == widget.singleEvent!.id.toString()){
          // socketProvider.messageList.remove(e);
          // socketProvider.messageList.add(
          //     new Chat(
          //       // chat_id: chatId,
          //       chat_id: int.tryParse(widget.chatId),
          //       receiver_id: receiverId,
          //       sender_id: widget.user.id,
          //       receiver_username: widget.receiverUsername,
          //       sender_username: widget.user.username,
          //       sent_at: DateTime.now().toLocal(),
          //       text: message,
          //       receiver_profile_image: widget.receiverProfileImage,
          //       sender_profile_image: widget.user.profile_image,
          //       user_a_id: widget.aId,
          //       user_b_id: widget.bId,
          //       // user_a_last_opening_at: user_a_last_opening_at,
          //       // user_b_last_opening_at: user_b_last_opening_at,
          //     )
          // );

          e.chatRoomMessages!.add(
              ChatRoomMessage(
                text: message,
                event: widget.singleEvent,
                sender: userProvider.user,
                sent_at: sentAt,
                is_visible: 1,
                // id:
              )
          );
          // e.unread_messages++;

          // for(var e in socketProvider.chatRooms){
          //   e.chatRoomMessages.sort<DateTime, DateTime>((a, b) {
          //     // return a.sent_at.compareTo(b.sent_at);
          //     return a.sent_at.compareTo(b.sent_at);
          //   });
          //   // //print(e.chat_message_list.last.text);
          //   // //print(e.chat_message_list.last.sent_at.toString());
          // }
          //

          // socketProvider.chatRooms.sort((b, a) {
          //   if(a.chatRoomMessages != null && b.chatRoomMessages != null){
          //   //   if(a.chatRoomMessages.last != null && b.chatRoomMessages.last != null){
          //   //     return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
          //   //   }
          //     if(a.chatRoomMessages.length >= 1 && b.chatRoomMessages.length >= 1){
          //       return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
          //     }
          //   }
          //   // return null;
          //   // if(a.chatRoomMessages.length >= 1 && b.chatRoomMessages.length >= 1){
          //   //   return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
          //   // }
          //   // return a.chatRoomMessages[a.chatRoomMessages.length].sent_at.compareTo(b.chatRoomMessages[b.chatRoomMessages.length].sent_at);
          //   // return null;
          // });
          break;
        }
      }

      return jsonData;
    }
  }

  /*Future<void>*/ sendMessage({String? message, String? senderId, String? senderUsername, String? senderProfileImage}) async {
    // setMessage(
    //     type: "source",
    //     message: message
    // );
    // socket.emit("join-chat", chatId);

    // var socketProvider = Provider.of<SocketProvider>(context, listen: false);
    // //print(socket.connected.toString());

    // //print('aId 999');
    // //print(widget.aId);
    // //print('bId 999');
    // //print(widget.bId);

    DateTime sentAt = DateTime.now();

    /*await*/ insertChatMessage(
        message, senderId, socketProvider.chatId.toString(),/* sentAt,*/ senderUsername, senderProfileImage
    );

    /*//todo: usare userProvider ed inviare tutti i dati con socket.io
    //todo: inviare anche tutto il singleEvent
    socket.emit(
        "send-room_message",
        {
          "content": message,
          "senderId": senderId,
          "senderUsername": senderUsername,
          "senderProfileImage": senderProfileImage,
          "senderDescription": userProvider.user.description,
          "senderName": userProvider.user.name,
          "singleEventId": widget.singleEvent.id,
          "sentAt": sentAt.toString(),
          // "user_a_last_opening": user_a_last_opening_at.toString(),
          // "user_b_last_opening": user_b_last_opening_at.toString(),
        }
      // ]
    );

    socketProvider.addChatRoomMessage(
        new ChatRoomMessage(
          text: message,
          sender: userProvider.user,
          single_event: widget.singleEvent,
          // id:
          sent_at: sentAt,
          is_visible: 1
          // send_at: DateTime.now(),
          // send_at:
        )
    );

    // socketMessages.add(
    //   new ChatMessage(
    //     text: message,
    //     receiver_id: receiverId,
    //     sender_id: senderId,
    //     // chatId: chatId.toString(),
    //     chat_id: widget.chatId.toString(),
    //     sent_at: sentAt,
    //     type: 'source',
    //     is_visible_for_sender: 1,
    //     is_visible_for_receiver: 1,
    //   )
    // );

    for(var e in socketProvider.chatRooms){
      // if(e.chat_id.toString() == chatId.toString()){
      if(e.single_event.id.toString() == widget.singleEvent.id.toString()){
        // socketProvider.messageList.remove(e);
        // socketProvider.messageList.add(
        //     new Chat(
        //       // chat_id: chatId,
        //       chat_id: int.tryParse(widget.chatId),
        //       receiver_id: receiverId,
        //       sender_id: widget.user.id,
        //       receiver_username: widget.receiverUsername,
        //       sender_username: widget.user.username,
        //       sent_at: DateTime.now().toLocal(),
        //       text: message,
        //       receiver_profile_image: widget.receiverProfileImage,
        //       sender_profile_image: widget.user.profile_image,
        //       user_a_id: widget.aId,
        //       user_b_id: widget.bId,
        //       // user_a_last_opening_at: user_a_last_opening_at,
        //       // user_b_last_opening_at: user_b_last_opening_at,
        //     )
        // );

        e.chatRoomMessages.add(
            new ChatRoomMessage(
              text: message,
              single_event: widget.singleEvent,
              sender: userProvider.user,
              sent_at: sentAt.toLocal(),
              is_visible: 1,
              // id:
            )
        );
        // e.unread_messages++;

        // for(var e in socketProvider.chatRooms){
        //   e.chatRoomMessages.sort<DateTime, DateTime>((a, b) {
        //     // return a.sent_at.compareTo(b.sent_at);
        //     return a.sent_at.compareTo(b.sent_at);
        //   });
        //   // //print(e.chat_message_list.last.text);
        //   // //print(e.chat_message_list.last.sent_at.toString());
        // }
        //

        // socketProvider.chatRooms.sort((b, a) {
        //   if(a.chatRoomMessages != null && b.chatRoomMessages != null){
        //   //   if(a.chatRoomMessages.last != null && b.chatRoomMessages.last != null){
        //   //     return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
        //   //   }
        //     if(a.chatRoomMessages.length >= 1 && b.chatRoomMessages.length >= 1){
        //       return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
        //     }
        //   }
        //   // return null;
        //   // if(a.chatRoomMessages.length >= 1 && b.chatRoomMessages.length >= 1){
        //   //   return a.chatRoomMessages.last.sent_at.compareTo(b.chatRoomMessages.last.sent_at);
        //   // }
        //   // return a.chatRoomMessages[a.chatRoomMessages.length].sent_at.compareTo(b.chatRoomMessages[b.chatRoomMessages.length].sent_at);
        //   // return null;
        // });
        break;
      }
    }
*/
    // socketProvider.messageList.sort((b, a) {
    //   return a.sent_at.compareTo(b.sent_at);
    // });

    // //print('tttttt');
    // for(var e in socketProvider.messageList){
    //   // e.chat_message_list.sort((b, a) {
    //   //   return a.sent_at.compareTo(b.sent_at);
    //   // });
    //   //print(e.chat_message_list.last.text);
    //   //print(e.chat_message_list.last.sent_at.toString());
    // }
    //
    // socketProvider.messageList.sort((b, a) {
    //   return a.chat_message_list.last.sent_at.compareTo(b.chat_message_list.last.sent_at);
    // });


    // _textController.clear();
  }

  Widget senderChatMessage(
    BuildContext context, {
    // String imageUrl,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, top: 0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          // Image.asset(
          //   imageUrl,
          //   width: MediaQuery.of(context).size.width * 0.1,
          // ),
          // const SizedBox(
          //   width: 8,
          // ),
          Container(
            // width: MediaQuery.of(context).size.width * 0.8,
            // color: Colors.blue,
            constraints: BoxConstraints(
              //   minWidth: 100.0,
              maxWidth: MediaQuery.of(context).size.width * 0.83,
              // minHeight: 20,
              // maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Colors.blue,
              //     Colors.purple,
              //   ],
              // ),
              //   boxShadow: [
              //     BoxShadow(
              //         blurRadius: 0.05,
              //         // color: Colors.blue[500],
              //         color: Colors.black,
              //         // spreadRadius: 1,
              //     ),
              //   ],
              //   color: Color(0xFF1EA3E8),
              // color: Color(0xFF4CA1F1).withOpacity(0.75),
              // color: Color(0xFF9894F4).withOpacity(0.9),
              color: Color(0xFFD8D8D8).withOpacity(0.9),
              // color: Color(0xFFFFFFF).withOpacity(0.9),

              // color: Colors.greenAccent[400].withOpacity(0.55),
              // color: Colors.grey[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(0),
                bottomRight: Radius.circular(12),
              ),
            ),
            padding: EdgeInsets.only(
              top: 10.0,
              // bottom: 5.0,
              bottom: 10.0,
              left: 16.0,
              right: 16,
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 0,
                    right: 5,
                    top: 5,
                    bottom: 0,
                  ),
                  child: Text(
                    text,
                    style: TextStyle(
                      // color: Colors.black,
                      color: Colors.grey[850],
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                const SizedBox(height: 8,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   // time.toString()/*.substring(10, 16)*/,
                    //   DateFormat.MMMMd('it_IT').format(time)
                    //       + ' alle ' + time.toString().substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize: 9.0,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w500
                    //   ),
                    // ),
                    Text(
                      // time.toString()/*.substring(10, 16)*/,
                      // '15:22',
                      time,
                      style: TextStyle(
                          fontSize: 9.5,
                          // color: Colors.white,
                          // color: Colors.grey,
                          // color: Color(0xFF9E9E9E),
                          // color: Color(0xFF757575),
                          color: Color(0xFF616161),
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(width: 6,),
                    Visibility(
                      visible: /*isVisualized*/false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Icon(
                          Icons.check,
                          color: Colors.lightGreen[800],
                          // color: Colors.purple[700],
                          // color: Color(0xFF9894F4).withOpacity(0.9),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget receiverChatMessage(
    BuildContext context, {
    // String imageUrl,
    required User user,
    required String text,
    required String time,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Container(
            // width: MediaQuery.of(context).size.width * 0.8,

            // color: Colors.blue,
            constraints: BoxConstraints(
              //   minWidth: 100.0,
              //   maxWidth: MediaQuery.of(context).size.width * 0.715,
              maxWidth: MediaQuery.of(context).size.width * 0.83,
              // minHeight: 20,
              // maxHeight: MediaQuery.of(context).size.height * 0.9,
            ),
            decoration: BoxDecoration(
              //   gradient: LinearGradient(
              //   begin: Alignment.topRight,
              //   end: Alignment.bottomLeft,
              //   colors: [
              //     Colors.blue,
              //     Colors.purple,
              //   ],
              // ),
              //   boxShadow: [
              //     BoxShadow(
              //         blurRadius: 0.05,
              //         // color: Colors.blue[500],
              //         color: Colors.black,
              //         // spreadRadius: 1,
              //     ),
              //   ],
              //   color: Color(0xFF1EA3E8),
              // color: Color(0xFF4CA1F1).withOpacity(0.75),
              color: Colors.blue,
              // color: Colors.greenAccent[400].withOpacity(0.55),
              // color: Colors.grey[700],
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(12),
                topRight: Radius.circular(12),
                bottomLeft: Radius.circular(12),
                bottomRight: Radius.circular(0),
              ),
            ),
            padding: EdgeInsets.only(
              top: 12.0,
              // bottom: 5.0,
              bottom: 10.0,
              left: 16.0,
              right: 16,
            ),
            child: Column(
              // mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Padding(
                  padding: const EdgeInsets.only(
                    left: 10,
                    right: 0,
                    top: 5,
                    bottom: 0,
                  ),
                  child: Text(
                    text,
                    // textAlign: TextAlign.right,
                    style: const TextStyle(
                      // color: Colors.black,
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 10,),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Text(
                    //   // time.toString()/*.substring(10, 16)*/,
                    //   DateFormat.MMMMd('it_IT').format(time)
                    //       + ' alle ' + time.toString().substring(11, 16),
                    //   style: TextStyle(
                    //       fontSize: 9.0,
                    //       color: Colors.white,
                    //       fontWeight: FontWeight.w500
                    //   ),
                    // ),
                    Text(
                      // time.toString()/*.substring(10, 16)*/,
                      // '15:22',
                      time,
                      style: TextStyle(
                          fontSize: 9.5,
                          color: Colors.white,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                    const SizedBox(width: 6,),
                    Visibility(
                      visible: /*isVisualized*/false,
                      child: Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Icon(
                          Icons.check,
                          color: Colors.lightGreen[800],
                          // color: Colors.purple[700],
                          // color: Color(0xFF9894F4).withOpacity(0.9),
                          size: 22,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          SizedBox(
            // width: 8,
            width: MediaQuery.of(context).size.width * 0.02,
          ),
          InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              Navigator.push(
                context,
                PageTransition(
                  duration: const Duration(milliseconds: 500),
                  alignment: Alignment.center,
                  type: PageTransitionType.fade,
                  child: UserProfileScreen(
                    // userId: user.id!,
                    user: user,
                    isTab: false,
                  )
                ),
              );
            },
            child: ClipOval(
              child: FutureImage(
                // imageUrl,
                user.profile_image!,
                width: MediaQuery.of(context).size.width * 0.1,
                height: MediaQuery.of(context).size.width * 0.1,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();
    timeAgo.setLocale('it', timeAgo.Italian());
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    socket = socketProvider.socket;
    socketProvider.chatRoomOpen = widget.singleEvent!.id;

    //per vedere se già sono stati prelevati i messaggi della room
    for(int i = 0; i < socketProvider.chatRooms.length; i++){
      if(socketProvider.chatRooms[i].event!.id.toString() == widget.singleEvent!.id.toString()){
        chatRoomIndex = i;
        if(socketProvider.chatRooms[i].chatRoomMessages!.length == 0){
          socketProvider.getAllChatRoomMessages(
              userProvider.user!.id,
              widget.singleEvent!
          );
        }
      }
    }

    // WidgetsBinding.instance.addPostFrameCallback((timeStamp) {
    //   _scrollController.animateTo(
    //     _scrollController.position.maxScrollExtent,
    //     duration: Duration(milliseconds: 300),
    //     curve: Curves.easeOut,
    //   );
    // });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    super.dispose();
    _textController.dispose();
    socketProvider.chatRoomOpen = '';
    _scrollController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    var chatRoomMessageListReversed = [];
    chatRoomMessageListReversed = List.from(
        socketProvider.chatRooms[chatRoomIndex].chatRoomMessages!.reversed
    );

    return Scaffold(
      // backgroundColor: lightGreyColor,
      // backgroundColor: Colors.grey[100],
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: false,

      appBar: PreferredSize(
        preferredSize: Size.fromHeight(55),
        child: AppBar(
          iconTheme: IconThemeData(
            color: Colors.grey[400], //change your color here
          ),
          elevation: 1,
          title: InkWell(
            highlightColor: Colors.transparent,
            splashColor: Colors.transparent,
            onTap: (){
              // Navigator.push(
              //   context,
              //   PageTransition(
              //       duration: const Duration(milliseconds: 500),
              //       alignment: Alignment.center,
              //       type: PageTransitionType.fade,
              //       child: SingleEventScreen(
              //         singleEvent: widget.singleEvent,
              //         user: userProvider.user,
              //       )
              //   ),
              // );
            },
            child: Row(
              children: [
                // ClipRRect(
                //   borderRadius:
                //   BorderRadius.circular(8),
                //   child: Image(
                //     image: CachedNetworkImageProvider(
                //       widget.receiverImage,
                //     ),
                //     width: 30,
                //     height: 30,
                //     fit: BoxFit.cover,
                //   ),
                // ),
                Container(
                  child: Padding(
                    padding: EdgeInsets.only(
                        // left: 10,
                        left: MediaQuery.of(context).size.width * 0.02,
                        top: 2.5,
                        bottom: 2.5
                    ),
                    child: Container(
                      width: 45,
                      height: 45,
                      // height: 20,
                      child: Card(
                        semanticContainer: true,
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        // child: Image.network(
                        //   widget.singleEvent!.image!,
                        //   fit: BoxFit.cover,
                        // ),
                        child: FutureImage(
                          widget.singleEvent!.image!,
                          width: MediaQuery.of(context).size.width,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8.0),
                        ),
                        elevation: 5,
                        //margin: EdgeInsets.all(10),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.only(bottom: 0),
                    // crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Marquee(
                        child: Row(
                          children: [
                            Text(
                              widget.singleEvent!.title!,
                              style: TextStyle(
                                  color: Colors.blue,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 2.5,),
                      Text(
                        // 'Online',
                        '47 partecipanti',
                        style: TextStyle(
                          // color: Colors.grey[700],
                            color: Colors.green[500],
                            fontSize: 12,
                            fontWeight: FontWeight.w600
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          // title: Text(
          //   testoRicevuto ?? "",
          //   style: TextStyle(
          //     color: Colors.black,
          //     fontSize: 12
          //   ),
          // ),
          // leading:
          actions: <Widget>[
            InkWell(
              onTap: () {
                // _bottomSheetOptions(context);
              },
              focusColor: Colors.transparent,
              hoverColor: Colors.transparent,
              splashColor: Colors.transparent,
              highlightColor: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.only(right: 16.0),
                child: Icon(
                  // SimpleLineIcons.options_vertical,
                  Icons.more_vert_rounded,
                  size: 17,
                  color: Colors.grey[600],
                ),
              ),
            ),
            // Container(
            //   child: Padding(
            //     padding: EdgeInsets.only(left: 10, top: 2.5, bottom: 2.5),
            //     child: Container(
            //       width: 50,
            //       // height: 20,
            //       child: Card(
            //         semanticContainer: true,
            //         clipBehavior: Clip.antiAliasWithSaveLayer,
            //         child: Image.network(
            //           widget.receiverImage,
            //           fit: BoxFit.cover,
            //         ),
            //         shape: RoundedRectangleBorder(
            //           borderRadius: BorderRadius.circular(12.0),
            //         ),
            //         elevation: 15,
            //         //margin: EdgeInsets.all(10),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
      // floatingActionButton: Container(
      //   width: MediaQuery.of(context).size.width - (2 * 30),
      //   padding: const EdgeInsets.all(16),
      //   decoration: BoxDecoration(
      //     color: Colors.white,
      //     borderRadius: BorderRadius.circular(75),
      //   ),
      //   child: Row(
      //     mainAxisAlignment: MainAxisAlignment.spaceBetween,
      //     children: [
      //       const Text(
      //           'Type message ...',
      //           style: TextStyle(
      //             color: Color(0xff999999),
      //             fontWeight: FontWeight.w300,
      //             fontSize: 16,
      //           )
      //       ),
      //       Image.asset(
      //         'assets/images/btn_send.png',
      //         width: 35,
      //         height: 35,
      //       ),
      //     ],
      //   ),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      body: Container(
        height: MediaQuery.of(context).size.height,
        width: MediaQuery.of(context).size.width,
        padding: EdgeInsets.symmetric(
          // horizontal: 10,
          horizontal: MediaQuery.of(context).size.width * 0.018,
        ),
        child: ListView.builder(
          reverse: true,
          physics: BouncingScrollPhysics(),
          controller: _scrollController,
          padding: EdgeInsets.only(top: 20, bottom: 50),
          shrinkWrap: false,
          itemCount: chatRoomMessageListReversed.length,
          itemBuilder: (context, i){
            if(chatRoomMessageListReversed[i].sender.id == userProvider.user!.id){
              return senderChatMessage(
                context,
                text: chatRoomMessageListReversed[i].text,
                // imageUrl: socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sender.profile_image,
                // time: socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sent_at.toString()
                time: DateFormat.MMMMd('it_IT').format(chatRoomMessageListReversed[i].sent_at)
                    + ' alle ' + chatRoomMessageListReversed[i].sent_at.toString().substring(11, 19),
                // time: timeAgo.format(
                //   socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sent_at,
                //   locale: 'it'
                // ),
              );
            }
            else if(chatRoomMessageListReversed[i].sender.id != userProvider.user!.id){
              return receiverChatMessage(
                context,
                text: chatRoomMessageListReversed[i].text,
                // imageUrl: socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sender.profile_image,
                user: chatRoomMessageListReversed[i].sender,
                // time: socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sent_at.toString()
                time: DateFormat.MMMMd('it_IT').format(chatRoomMessageListReversed[i].sent_at)
                    + ' alle ' + chatRoomMessageListReversed[i].sent_at.toString().substring(11, 19),
                // time: timeAgo.format(
                //     socketProvider.chatRooms[chatRoomIndex].chatRoomMessages[i].sent_at,
                //     locale: 'it'
                // ),
              );
            }
            return null;
          },
        ),
      ),
      bottomSheet: BottomAppBar(
        elevation: 0,
        color: Colors.white,
        child: Container(
          constraints: BoxConstraints(
              maxHeight: 100,
              minHeight: 50
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              IconButton(
                icon: Icon(
                  Icons.add,
                  color: Colors.blue,
                ),
                onPressed: () {

                },
              ),
              Flexible(
                child: TextField(
                  controller: _textController,
                  autofocus: false,

                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.grey[800],
                  ),
                  decoration: InputDecoration(
                    contentPadding: EdgeInsets.all(10.0),
                    border: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    hintText: "Scrivi il tuo messaggio...",
                    hintStyle: TextStyle(
                      fontSize: 15.0,
                      color: Colors.grey[500],
                    ),
                  ),
                  maxLines: null,
                ),
              ),
              IconButton(
                icon: Icon(
                  Icons.send,
                  color: Colors.blue,
                ),
                onPressed: () {
                  // sendMessage(
                  //   message: _textController.text,
                  //   senderId: userProvider.user.id,
                  //   senderProfileImage: userProvider.user.profile_image,
                  //   senderUsername: userProvider.user.username,
                  // );
                  if(_textController.text != ''){
                    insertChatMessage(
                      _textController.text,
                      userProvider.user!.id,
                      widget.singleEvent!.id,
                      userProvider.user!.username,
                      userProvider.user!.profile_image,
                    );

                    // Clear the text field
                    _textController.clear();
                  }

                },
              )
            ],
          ),
        ),
      ),
    );
  }
}