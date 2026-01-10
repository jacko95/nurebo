import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
// import 'package:flutter_icons/flutter_icons.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:nurebo/models/business_post.dart';
import 'package:nurebo/models/post_comment.dart';
import 'package:nurebo/provider/post_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/extensions.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/in_app_notification/in_app_notification.dart';
import 'package:provider/provider.dart';


class CommentCard extends StatefulWidget {
  final PostComment? comment;
  final BusinessPost? businessPost;

  const CommentCard({
    super.key,
    this.comment,
    this.businessPost,
    // this.isActive = true,
    // this.email,
    // this.press,
  });

  @override
  State<CommentCard> createState() => _CommentCardState();
}

class _CommentCardState extends State<CommentCard> {
  bool isOptionsVisible = false;
  late SocketProvider socketProvider;
  late PostProvider postProvider;


  @override
  void initState() {
    super.initState();
    // initializeDateFormatting();
    socketProvider = Provider.of<SocketProvider>(context, listen: false);
    postProvider = Provider.of<PostProvider>(context, listen: false);

  }

  @override
  Widget build(BuildContext context) {
    socketProvider = Provider.of<SocketProvider>(context, listen: true);
    postProvider = Provider.of<PostProvider>(context, listen: true);

    return Stack(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 15, vertical: 15 / 2),
          child: Container(
            padding: EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        SizedBox(
                          width: 32,
                          // child: CircleAvatar(
                          //   backgroundColor: Colors.transparent,
                          //   // backgroundImage: NetworkImage('email.image'),
                          //   // backgroundImage: NetworkImage(widget.comment!.user!.profile_image!),
                          //   backgroundImage: FutureImage(
                          //       widget.comment!.user!.profile_image!),
                          // ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(50),
                            clipBehavior: Clip.antiAliasWithSaveLayer,
                            child: FutureImage(
                              widget.comment!.is_admin == 1 ? widget.comment!.businessPost!.business!.profile_image! : widget.comment!.user!.profile_image!,
                              width: 35,
                              height: 35,
                            ),
                          ),
                        ),
                        SizedBox(width: 20 / 2),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GradientText(
                              // text: "email.name \n",
                              widget.comment!.is_admin == 1
                                  ? widget.comment!.businessPost!.business!.name!
                                  : '@${widget.comment!.user!.username ?? ''}',
                              gradient: widget.comment!.is_admin == 1 ? LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    Color(0xff8921aa),
                                    Color(0xffDA44bb),
                                  ]
                              ) : LinearGradient(
                                  begin: Alignment.bottomLeft,
                                  end: Alignment.topRight,
                                  colors: [
                                    // Color(0xff8921aa),
                                    // Color(0xffDA44bb),
                                    Colors.grey[800]!,
                                    Colors.grey[800]!,
                                  ]
                              ),
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w700,
                                // color: Colors.blue,
                                color: Colors.grey[800],
                              ),
                            ),
                            Text(
                              // text: "email.name \n",
                              widget.comment!.is_admin == 1
                                  ? widget.comment!.businessPost!.business!.category!.name!
                                  : widget.comment!.user!.name ?? '',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w700,
                                // color: Colors.blue,
                                color: Colors.grey[500],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                    Visibility(
                      visible: widget.comment!.user?.id == Utils.user?.id && Utils.user != null,
                      child: InkWell(
                        onTap: (){
                          if(widget.comment!.user!.id == Utils.user!.id){
                            setState(() {
                              isOptionsVisible = !isOptionsVisible;
                            });
                            // InAppNotification.show(
                            //   child: ConstrainedBox(
                            //     constraints: BoxConstraints(minHeight: 100),
                            //     child: Padding(
                            //       padding: const EdgeInsets.fromLTRB(16, 4, 16, 0),
                            //       child: DecoratedBox(
                            //         decoration: BoxDecoration(
                            //           boxShadow: [
                            //             BoxShadow(
                            //               color: Colors.black.withOpacity(0.1),
                            //               spreadRadius: 12,
                            //               blurRadius: 16,
                            //             ),
                            //           ],
                            //         ),
                            //         child: ClipRRect(
                            //           borderRadius: BorderRadius.circular(16),
                            //           child: BackdropFilter(
                            //             filter: ImageFilter.blur(sigmaX: 24, sigmaY: 24),
                            //             child: DecoratedBox(
                            //               decoration: BoxDecoration(
                            //                 color: Colors.lightGreen.withOpacity(0.4),
                            //                 borderRadius: BorderRadius.circular(16.0),
                            //                 border: Border.all(
                            //                   width: 1.4,
                            //                   color: Colors.lightGreen.withOpacity(0.2),
                            //                 ),
                            //               ),
                            //               child: Padding(
                            //                 padding: const EdgeInsets.all(16.0),
                            //                 child: Center(
                            //                   child: Text(
                            //                     'Count: ',
                            //                     style: Theme.of(context)
                            //                         .textTheme
                            //                         .headline4!
                            //                         .copyWith(color: Colors.white),
                            //                   ),
                            //                 ),
                            //               ),
                            //             ),
                            //           ),
                            //         ),
                            //       ),
                            //     ),
                            //   ),
                            //   context: context,
                            //   onTap: () => print('Notification tapped!'),
                            //   duration: Duration(milliseconds: 2500),
                            // );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 15, right: 5, left: 15),
                          child: Icon(
                            // SimpleLineIcons.options_vertical,
                            Icons.more_vert_rounded,
                            size: 20,
                            color: Colors.grey[500],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 15),
                Container(
                  width: MediaQuery.of(context).size.width * .7,
                  child: Text(
                    // 'email.body',
                    widget.comment!.text!,
                    textAlign: TextAlign.center,
                    maxLines: 10,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                    ),
                  ),
                ),
                SizedBox(height: 25),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      // 'email.time',
                      // comment.create_at.toString(),
                      '${DateFormat.yMMMMEEEEd('it_IT').format(widget.comment!.created_at!)} alle ${widget.comment!.created_at.toString().substring(11, 16)}',
                      style: Theme.of(context).textTheme./*caption!.*/bodyLarge!.copyWith(
                          color: Colors.grey[500],
                          fontWeight: FontWeight.w600,
                          fontSize: 11
                      ),
                    ),
                    // if (email.isAttachmentAvailable)
                    //   WebsafeSvg.asset(
                    //     "assets/Icons/Paperclip.svg",
                    //     color: isActive ? Colors.white70 : kGrayColor,
                    //   )
                  ],
                ),
              ],
            ),
          ).addNeumorphism(
            blurRadius: 15,
            borderRadius: 15,
            offset: const Offset(5, 5),
            topShadowColor: Colors.white60,
            bottomShadowColor: const Color(0xFF234395).withOpacity(0.15),
          ),
        ),
        Positioned(
          right: 50,
          top: 40,
          // height: 50,
          child: Visibility(
            visible: isOptionsVisible,
            child: InkWell(
              onTap: () async {
                if(widget.comment!.user!.id == Utils.user!.id){
                  setState(() {
                    isOptionsVisible = !isOptionsVisible;
                  });
                }
                // print('g4g4');
                await postProvider.deleteBusinessPostComment(widget.businessPost!, widget.comment!);
              },
              child: Container(
                // color: Colors.blue,
                // margin: const EdgeInsets.only(top: 20, right: 30),
                decoration: BoxDecoration(
                  color: Colors.red[600],
                  borderRadius: BorderRadius.circular(5),
                  shape: BoxShape.rectangle,
                ),
                height: 35,
                width: 80,
                transform: Matrix4.identity()..translate(10.0, 10.0),
                child: Center(
                  child: Text(
                    'Elimina',
                    // 'Le mie prestazioni',
                    style: TextStyle(
                        color: Colors.white,
                        // color: Colors.grey[200],
                        fontWeight: FontWeight.w600,
                        fontSize: 13
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
