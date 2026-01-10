import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get_utils/get_utils.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/src/intl/date_format.dart';
import 'package:intl/intl.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/event_reservation.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/widgets/future_image.dart';

class UserTicketDetailScreen extends StatefulWidget {
  final User? user;
  final EventReservation? eventTicket;

  const UserTicketDetailScreen({required this.user, this.eventTicket /*this.ticket*/});

  @override
  _UserTicketDetailScreenState createState() => _UserTicketDetailScreenState();
}

class _UserTicketDetailScreenState extends State<UserTicketDetailScreen> {

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: Brightness.dark,
        statusBarColor: Color(0xFFF6F7F9),
        // statusBarColor: MaterialColors.blue,
        // systemNavigationBarColor: MaterialColors.blue
      ),
      child: Scaffold(
        // backgroundColor: MaterialColors.red,
        // appBar: PreferredSize(
        //   preferredSize: Size.fromHeight(
        //     77
        //   ),
        //   child: MyAppBar1(
        //     user: widget.user,
        //   ),
        // ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: ListView(
            children: [
              Container(
                color: Color(0xFFF6F7F9),
                child: Padding(
                  padding: const EdgeInsets.only(left: 20, top: 20),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.all(Radius.circular(10)),
                        child: Container(
                          color: Colors.grey[300],

                          child: IconButton(
                            onPressed: (){
                              Navigator.pop(context);
                            },
                            padding: EdgeInsets.all(0),

                            icon: Icon(
                              // Icons.arrow_back,
                              Icons.clear,
                              size: 24,
                              color: CupertinoColors.black,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Container(
                padding: EdgeInsets.fromLTRB(40, 0, 40, 0),
                color: Color(0xFFF6F7F9),
                child: NotificationListener<OverscrollIndicatorNotification>(
                  onNotification: (overscroll) {
                    overscroll.disallowIndicator();
                    return true;
                  },
                  child: ListView(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    children: <Widget>[
                      Column(
                        children: <Widget>[
                          SizedBox(
                            height: 10,
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 20),
                            height: 170,
                            // decoration: BoxDecoration(
                            //   color: Colors.blueGrey[100],
                            //   borderRadius: BorderRadius.only(
                            //     topLeft: Radius.circular(12),
                            //     topRight: Radius.circular(12),
                            //   ),
                            //   image: DecorationImage(
                            //     image: NetworkImage(
                            //       widget.eventTicket!.eventTicket!.event!.image!
                            //     ),
                            //     fit: BoxFit.cover
                            //   ),
                            // ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(20),
                              child: FutureImage(
                                widget.eventTicket!.eventTicket!.event!.image!,
                                width: MediaQuery.of(context).size.width,
                                // height: 20,
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: TicketTopClipper(),
                            child: Container(
                              width: double.infinity,
                              color: Colors.white,
                              padding: EdgeInsets.fromLTRB(16, 16, 16, 0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  GradientText(
                                    widget.eventTicket!.eventTicket!.event!.title ?? '',
                                    gradient: const LinearGradient(
                                        begin: Alignment.bottomLeft,
                                        end: Alignment.topRight,
                                        colors: [
                                          Color(0xff8921aa),
                                          Color(0xffDA44bb),
                                          // Color(0xffDA44bb)
                                        ]
                                    ),
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 18,
                                      color: Colors.grey[800]
                                    ),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    widget.eventTicket!.eventTicket!.title!.toUpperCase()/*.toLowerCase().capitalize*//* ?? ''*/,
                                    style: TextStyle(
                                        fontWeight: FontWeight.w700,
                                        fontSize: 13,
                                        color: Colors.grey[700]
                                    ),
                                  ),
                                  SizedBox(height: 4,),
                                  Text(
                                    widget.eventTicket!.eventTicket!.additional!.toLowerCase().capitalize ?? '',
                                    style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 11,
                                        color: Colors.grey[500]
                                    ),
                                  ),
                                  SizedBox(height: 30,),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        DateFormat.yMMMMEEEEd('it_IT').format(widget.eventTicket!.eventTicket!.event!.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))).toUpperCase(),
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            color: Colors.grey[900]
                                        ),
                                      ),
                                      SizedBox(height: 4,),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.access_time,
                                            color: Colors.grey[900],
                                            size: 18,
                                          ),
                                          SizedBox(width: 3,),
                                          Text(
                                            widget.eventTicket!.eventTicket!.event!.begin_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w900,
                                                fontSize: 12,
                                                color: Colors.grey[900]
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),

                                  SizedBox(
                                    height: 35,
                                  ),

                                  //TODO: INSERIRE ANCHE LE INFORMAZIONI SUL PAGAMENTO
                                  //TIPO IL METODO E QUANDO è STATO EFFETTUATO
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Categoria:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      GradientText(
                                        widget.eventTicket!.eventTicket!.event!.business!.category!.name ?? '',
                                        gradient: const LinearGradient(
                                            begin: Alignment.bottomLeft,
                                            end: Alignment.topRight,
                                            colors: [
                                              Color(0xff8921aa),
                                              Color(0xffDA44bb),
                                              // Color(0xffDA44bb)
                                            ]
                                        ),
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          // color: Colors.grey[800]
                                          // color: Colors.blue[500]
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),

                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(right: 20.0),
                                        child: Text(
                                          'ID:',
                                          style: TextStyle(
                                              fontWeight: FontWeight.w700,
                                              fontSize: 12,
                                              color: Colors.grey[500]
                                          ),
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.5,
                                        child: Marquee(
                                          child: Row(
                                            children: [
                                              Text(
                                                widget.eventTicket!.id!,
                                                maxLines: 1,
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w800,
                                                    fontSize: 14,
                                                    color: Colors.grey[800]
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Username:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      Text(
                                        '@' + widget.user!.username!,
                                        style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            // color: Colors.grey[800]
                                            color: Colors.blue[500]
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Prezzo:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      Text(
                                        '€ ' + NumberFormat.currency(
                                          // customPattern: '#,##',
                                            decimalDigits: 2,
                                            symbol: '',
                                            locale: 'IT_it'
                                        ).format(widget.eventTicket!.eventTicket!.price),
                                          style: TextStyle(
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                            // color: Colors.grey[800]
                                            color: Colors.green[500]
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Acquistato il:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        child: Marquee(
                                          child: Text(
                                            DateFormat.yMMMMd('it_IT').format(widget.eventTicket!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                            + ' alle ' + widget.eventTicket!.created_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: Colors.grey[800]
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Valido fino al:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        child: Marquee(
                                          child: Text(
                                            DateFormat.yMMMMd('it_IT').format(widget.eventTicket!.eventTicket!.event!.end_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                                + ' alle ' + widget.eventTicket!.eventTicket!.event!.end_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16),
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: Colors.grey[800]
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Convalidato il:',
                                        style: TextStyle(
                                            fontWeight: FontWeight.w700,
                                            fontSize: 12,
                                            color: Colors.grey[500]
                                        ),
                                      ),
                                      Container(
                                        width: MediaQuery.of(context).size.width * 0.45,
                                        child: Marquee(
                                          child: Text(
                                              widget.eventTicket!.is_validated_at != null ? DateFormat.yMMMMd('it_IT').format(widget.eventTicket!.is_validated_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))
                                                + ' alle ' + widget.eventTicket!.is_validated_at!.add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).toString().substring(11, 16)
                                            : '-',
                                            style: TextStyle(
                                                fontWeight: FontWeight.w800,
                                                fontSize: 14,
                                                color: Colors.grey[800]
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Stato: ',
                                        style: TextStyle(
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w700,
                                            fontSize: 15
                                        ),
                                      ),
                                      SizedBox(
                                        width: 5,
                                      ),
                                      widget.eventTicket!.is_validated == 1 ? Text(
                                        // "25 posti disponibili",
                                        "Convalidato",
                                        style: TextStyle(
                                          color: Colors.indigoAccent[700],
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ) : !widget.eventTicket!.eventTicket!.event!.begin_at!.isBefore(DateTime.now())
                                        && widget.eventTicket!.is_validated == 0 ? Text(
                                        // "25 posti disponibili",
                                        "Valido",
                                        style: TextStyle(
                                          color: Colors.greenAccent[700],
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ) : widget.eventTicket!.eventTicket!.event!.begin_at!.isBefore(DateTime.now())
                                          ? Text(
                                        // "25 posti disponibili",
                                        "Scaduto",
                                        style: TextStyle(
                                          color: Colors.redAccent[700],
                                          fontWeight: FontWeight.w800,
                                        ),
                                      ) : Text("",)
                                    ],
                                  ),
                                  // ListTile(
                                  //   title: Text(
                                  //     'Evento: ',
                                  //     style: TextStyle(
                                  //       color: Colors.grey[700],
                                  //       fontWeight: FontWeight.w700,
                                  //       fontSize: 15
                                  //     ),
                                  //   ),
                                  //   trailing: Text(
                                  //     widget.singleEventReservation.single_event_title,
                                  //   ),
                                  // ),
                                  SizedBox(
                                    height: 30,
                                  ),
                                  generateDashedDivider(
                                      MediaQuery.of(context).size.width * 0.69
                                  )
                                  // Image.network(
                                  //     widget.singleEventReservation.qr_code
                                  // ),
                                ],
                              ),
                            ),
                          ),
                          ClipPath(
                            clipper: TicketBottomClipper(),
                            child: Container(
                              width: double.infinity,
                              padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                              color: Colors.white,
                              // child: Row(
                              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              //   children: <Widget>[
                              //     Column(
                              //       crossAxisAlignment: CrossAxisAlignment.start,
                              //       children: <Widget>[
                              //         Text(
                              //           "Name: ",
                              //           style: TextStyle(
                              //               fontSize: 16, fontWeight: FontWeight.w400),
                              //         ),
                              //         Text(
                              //           'ticket.name',
                              //           style: TextStyle(
                              //               color: Colors.black,
                              //               fontSize: 16,
                              //               fontWeight: FontWeight.w400
                              //           ),
                              //         ),
                              //         SizedBox(
                              //           height: 8,
                              //         ),
                              //         Text(
                              //           "Paid: ",
                              //           style: TextStyle(
                              //               fontSize: 16, fontWeight: FontWeight.w400),
                              //         ),
                              //         Text(
                              //           NumberFormat.currency(
                              //                   locale: "id_ID",
                              //                   decimalDigits: 0,
                              //                   symbol: "IDR ")
                              //               .format(40),
                              //           style: TextStyle(
                              //               color: Colors.black,
                              //               fontSize: 16,
                              //               fontWeight: FontWeight.w400),
                              //         ),
                              //       ],
                              //     ),
                              //     // QrImage(
                              //     //   version: 6,
                              //     //   foregroundColor: Colors.black,
                              //     //   errorCorrectionLevel: QrErrorCorrectLevel.M,
                              //     //   padding: EdgeInsets.all(0),
                              //     //   size: 100,
                              //     //   data: ticket.bookingCode,
                              //     // )
                              //   ],
                              // ),
                              // child: Image.network(
                              //     widget.eventTicket!.qr_code!
                              // ),
                              child: FutureImage(
                                // cartData.orders[i].singleEventImage,
                                // booking.prestazione.image,
                                  widget.eventTicket!.qr_code!,
                                  width: MediaQuery.of(context).size.width,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          )
                        ],
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}

class TicketTopClipper extends CustomClipper<Path> {
  double radius = 15;

  @override
  Path getClip(Size size) {
    Path path = Path();
    path.lineTo(0, size.height - radius);
    path.quadraticBezierTo(radius, size.height - radius, radius, size.height);
    path.lineTo(size.width - radius, size.height);
    path.quadraticBezierTo(size.width - radius, size.height - radius,
        size.width, size.height - radius);
    path.lineTo(size.width, 0);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}

Widget generateDashedDivider(double width) {
  int n = width ~/ 5;
  return Row(
    children: List.generate(
        n,
            (index) => (index % 2 == 0)
            ? Container(
          height: 2,
          width: width / n,
          color: Color(0xFFE4E4E4),
        )
            : SizedBox(
          width: width / n,
        )),
  );
}

class TicketBottomClipper extends CustomClipper<Path> {
  double radius = 15;
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(size.width, size.height);
    path.lineTo(size.width, radius);
    path.quadraticBezierTo(size.width - radius, radius, size.width - radius, 0);
    path.lineTo(radius, 0);
    path.quadraticBezierTo(radius, radius, 0, radius);

    path.close();

    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
