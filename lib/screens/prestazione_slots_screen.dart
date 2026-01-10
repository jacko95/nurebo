import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'dart:ui';

// import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:date_picker_timeline/date_picker_widget.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_cache_business/flutter_cache_business.dart';
// import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:nurebo/widgets/gradient_widgets/gradient_widgets.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/models/booking.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/models/prestazione.dart';
import 'package:nurebo/models/user.dart';
import 'package:nurebo/provider/cart_provider.dart';
import 'package:nurebo/provider/prestazione_favorite_provider.dart';
import 'package:nurebo/provider/geolocation_provider.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/login_screen.dart';
import 'package:nurebo/screens/prestazione_detail_screen.dart';
import 'package:nurebo/screens/reservation_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/future_image.dart';
import 'package:nurebo/widgets/tab_bar_sliver_persistent_header_delegate.dart';
import 'package:page_transition/page_transition.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:expandable_text/expandable_text.dart';
import 'package:nurebo/main.dart';


class PrestazioneSlotsScreen extends StatefulWidget {
  // final Business bookingBusiness;
  // final User user;
  final Prestazione? prestazione;

  const PrestazioneSlotsScreen({super.key, /*this.bookingBusiness,*/ /*this.user,*/ this.prestazione});

  @override
  _PrestazioneSlotsScreenState createState() => _PrestazioneSlotsScreenState();
}

class _PrestazioneSlotsScreenState extends State<PrestazioneSlotsScreen> /*with SingleTickerProviderStateMixin*/ {
  // List bookingBusinessPrestazioni = [];
  DateTime selectedDate = DateTime.parse(DateTime.now().toString());
  DateTime openingDate = DateTime.now();
  DateTime closingDate = DateTime.now();
  List openingDates = [];
  List closingDates = [];
  // List timetableDay = [];
  List? timetableDay = [];
  // DateTime timeOfTheDate;
  // int contaIntervalliDaMezzora = 0;
  // List<int> intervalliDaMezzoraPerApertura = [];
  List? occupiedDates = [];
  List? bookingBusinessAppointments = [];
  // List prestazioneDatePostList = [];
  List<Booking> slots = [];
  final int slotRange = 30;
  List? prestazioneBuyers = [];
  // List businessPostLikes = [];
  bool isLikedPost = false;
  Future a = Future(() {},), b = Future(() {},), /*c,*/ d = Future(() {},), e = Future(() {},);
  late UserProvider userProvider;
  late CartProvider cartProvider;
  late SocketProvider socketProvider;
  late PrestazioneFavoriteProvider favoriteProvider;
  late GeolocationProvider geolocationProvider;
  double? distanceInMeters;
  late AnimationController prenotaAnimationController;
  late Animation<Alignment> topAnimationAlignment;
  late Animation<Alignment> bottomAnimationAlignment;
  ScrollController? _scrollController;
  Color? _theme;
  bool isDateTableVisible = false;


  Future updateSlots(DateTime date) async {
    setState(() {
      selectedDate = date;
    });
    // //print(DateFormat.yMMMMd('it_IT').format(selectedDate));
    timetableDay!.clear();
    // //print('openingDates00');
    // //print(openingDates.toString());
    openingDates.clear();
    closingDates.clear();
    // intervalliDaMezzoraPerApertura.clear();
    // getTimetableDay(selectedDate.weekday);

    // prestazioneBuyers.clear();
    occupiedDates!.clear();
    bookingBusinessAppointments!.clear();
    // getAllPrestazioneBuyers();
    a = getTimetableDay(selectedDate.weekday).then((value) async {
      //print('timetableDay.length aa');
      // print(timetableDay!.length);
      if(timetableDay!.isEmpty){
        return;
      }

      await getOccupiedDates();
      // await getGuestBookings();
      await getBookings();
      await setSlots();
      // await getOccupiedDates()
      //   .then((value) async {
      //     return await getAppointments()
      //   .then((value) async {
      //     return await setSlots();
      //   });
      // });
    });

    // setState(() {
    slots.clear();
    // });
  }

  // Future getPrestazioneAllDatePost() async {
  //   var url = Uri.parse(Utils.httpServerUrl + "booking_post/prestazione_id");
  //   // var userProvider = Provider.of<UserProvider>(context);
  //
  //   Map<String, dynamic> body = {
  //     // 'user_id': userProvider.user.id,
  //     'prestazione_id': widget.prestazione.id,
  //     // 'text': commentController.text,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print("postcomment getall response.statusCode:");
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //
  //     prestazioneDatePostList = jsonData;
  //
  //     // //print('businessPostComments');
  //     // //print(jsonData);
  //     // //print("singleEventReservationCategories: ");
  //     // //print(singleEventReservationCategories);
  //     // //print('searchUserByUsername results.toString()');
  //     // //print(results.toString());
  //     // //print(jsonData);
  //     return jsonData;
  //   }
  // }

  setSlots(/*DateTime openingAt, DateTime closeAt*/) async {
    slots.clear();

    // await getOccupiedDates();
    // // await getGuestBookings();
    // await getBookings();
    // await Future.wait([
    //   getOccupiedDates(),
    //   // getGuestBookings(),
    //   getBookings(),
    // ]);

    for(var e in timetableDay!) {
      openingDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.tryParse(e['open_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
        int.tryParse(e['open_at_minute'])!,
      )/*.add(Duration(hours: 2))*/;
      openingDates.add(openingDate);

      closingDate = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        int.tryParse(e['close_at_hour'])! + DateTime.now().timeZoneOffset.inHours,
        int.tryParse(e['close_at_minute'])!,
      )/*.add(Duration(hours: 2))*/;
      closingDates.add(closingDate);

      // //print('openingDates');
      // //print(openingDates.toString());
      // //print('closingDates');
      // //print(closingDates.toString());

      DateTime newDate = openingDate;

      while(newDate.isBefore(closingDate) || newDate.isAtSameMomentAs(closingDate)) {
        Booking date = Booking(
            begin_at: newDate,
            end_at: newDate.add(Duration(minutes: /*slotRange*/widget.prestazione!.duration!)),
            type: 0
        );
        slots.add(date);
        newDate = newDate.add(Duration(minutes: slotRange/*widget.prestazione.duration*/));
        // setState(() {
        //   contaIntervalliDaMezzora++;
        // });
        // if(newDate.add(Duration(minutes: 30)).isAfter(newDate.add(Duration(minutes: widget.prestazione.duration))))
        if(newDate.add(Duration(minutes: /*slotRange*/widget.prestazione!.duration!)).isAfter(closingDate)) {
          // Date booking0 = new Date(
          //     begin_at: newDate,
          //     end_at: closingDate,
          //     type: 0
          // );
          // slots.add(booking0);
          // setState(() {
          //   // contaIntervalliDaMezzora--;
          // });
          // intervalliDaMezzoraPerApertura.add(contaIntervalliDaMezzora);
          break;
        }
      }
      // //print('ciccio0');
      // for(var l in slots){
      // //print(l.begin_at.toLocal().toString() + ' - ' + l.end_at.toLocal().toString() + ' - ' + l.type.toString());
      // }

      // print('fsv5vfs65bf5bf5bf');
      // print(occupiedDates);

      // for(int kk = 0; kk < occupiedDates!.length; kk++) {
      //   print(occupiedDates![kk]['occupied_from']);
      //   print(occupiedDates![kk]['occupied_until']);
      //   print('\n');
      // }
      // for(var e in occupiedDates!){
      //   print("${DateTime.parse(e['occupied_from'].toString().replaceAll('Z', '')).toString()} ${DateTime.parse(e['occupied_until'].toString().replaceAll('Z', '')).toString()}");
      //   // print('\n');
      // }
      // for(int ko = 0; ko < slots!.length; ko++) {
      //   print(slots[ko].begin_at);
      //   print(slots[ko].end_at);
      //   print('\n');
      // }

      // print('df56ddg65dg65');
      // print(bookingBusinessAppointments!.length);

      // for(Booking e in slots) {
      //   print("${e.begin_at!} ${e.end_at!} ${e.type}");
      //   print('\n');
      // }

      // int fdcf = 0;
      for(int j = 0; j < slots.length; j++) {
        for(int i = 0; i < occupiedDates!.length; i++) {
          // //print(
          //   slots[j].begin_at.toString().substring(11, 16) + ' - ' +
          //   slots[j].begin_at.add(Duration(minutes: widget.prestazione.duration/*slotRange*/)).toString().substring(11, 16)
          // );
          // if(DateTime.parse(occupiedDates![i]['occupied_from']).toLocal().toString() == slots[j].begin_at!.toLocal().toString()) {
          //   slots[j].type = 1;
          //   if(slots[j].end_at!.toLocal().isAfter(DateTime.parse(occupiedDates![i]['occupied_until']).toLocal())) {
          //     if (j > 0) {
          //       slots[j - 1].type = 1;
          //     }
          //   }
          //   // if(slots[j].begin_at!.toLocal().isAfter(DateTime.parse(occupiedDates![i]['occupied_until']).toLocal())) {
          //   //   slots[j].type = 1;
          //   // }
          // }
          if((DateTime.parse(occupiedDates![i]['occupied_from'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAtSameMomentAs(slots[j].begin_at!)) ||
              (DateTime.parse(occupiedDates![i]['occupied_until'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAtSameMomentAs(slots[j].end_at!)) ||
              (slots[j].end_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_until'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours))) &&
                  slots[j].begin_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_from'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))) ||
              (slots[j].begin_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_from'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours))) &&
                  slots[j].end_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_until'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))) ||
              (slots[j].begin_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_from'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours))) &&
                  slots[j].end_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_from'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))) ||
              (slots[j].end_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_until'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours))) &&
                  slots[j].begin_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_until'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)))) ||
              (slots[j].begin_at!.isBefore(DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/) ||
                  slots[j].begin_at!.isAtSameMomentAs(DateTime.now()/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/))
          ) {
            // if((DateTime.parse(occupiedDates![i]['occupied_from'])/*.toString()*/.isAtSameMomentAs(slots[j].begin_at!)/*.toString()*/) ||
            //   (DateTime.parse(occupiedDates![i]['occupied_until'])/*.toString()*/.isAtSameMomentAs(slots[j].end_at!)/*.toString()*/) ||
            //   (slots[j].end_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_until'])) &&
            //   slots[j].begin_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_from']))) ||
            //   (slots[j].begin_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_from'])) &&
            //   slots[j].end_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_until']))) ||
            //   (slots[j].end_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_until'])) &&
            //   slots[j].begin_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_until']))) ||
            //   (slots[j].begin_at!.isAfter(DateTime.parse(occupiedDates![i]['occupied_from'])) &&
            //   slots[j].begin_at!.isBefore(DateTime.parse(occupiedDates![i]['occupied_until'])))
            // ) {
            slots[j].type = 1;
            // fdcf++;
          }
        }
      }
      // print('fdcf');
      // print(fdcf);

      for(Booking e in socketProvider.myAppointmentsList){
        // print(e.id);
        // print("${widget.prestazione!.id} - ${e.prestazione!.id}");
        // print("${DateTime.now().day} - ${e.begin_at!.day}");
        // print("${DateTime.now().month} - ${e.begin_at!.month}");
        // print("${DateTime.now().year} - ${e.begin_at!.year}");
        // print(selectedDate.day == e.begin_at!.day && selectedDate.month == e.begin_at!.month && selectedDate.year == e.begin_at!.year
        //     && widget.prestazione!.id == e.prestazione!.id);
        // print("");

        if(selectedDate.day == e.begin_at!.day && selectedDate.month == e.begin_at!.month && selectedDate.year == e.begin_at!.year
            && widget.prestazione!.id == e.prestazione!.id && e.isCanceled == 0){
          // print('ciccccccococcoco');
          for(int k = 0; k < slots.length; k++) {
            slots[k].type = 1;
          }
          // break;
        }
      }

      // print('bookingBusinessAppointments00000');
      // for(var e in bookingBusinessAppointments!){
      //   if(DateTime.tryParse(e['begin_at'].replaceAll('Z', ''))!.day == selectedDate.day &&
      //     DateTime.tryParse(e['begin_at'].replaceAll('Z', ''))!.month == selectedDate.month) {
      //     print('${DateTime.tryParse(e['begin_at'].replaceAll('Z', '')).toString()} - ${e['duration']}');
      //   }
      // }
      //
      // print('slotsg6cg5g6');
      // for(int j = 0; j < slots.length; j++) {
      //   print("${slots[j].begin_at} - ${slots[j].begin_at} - ${slots[j].type}");
      // }

      int contaIncastri = 0;
      for(int j = 0; j < slots.length; j++) {
        // //print('contaIncastri');
        // //print(contaIncastri);
        contaIncastri = 0;
        for(int i = 0; i < bookingBusinessAppointments!.length; i++) {
          // print(
          //   slots[j].begin_at.toString().substring(11, 16) + ' - ' +
          //   slots[j].begin_at!.add(Duration(minutes: widget.prestazione!.duration!/*slotRange*/)).toString().substring(11, 16)
          // );
          // if(j == 0){
          //   if ((DateTime.parse(bookingBusinessAppointments[i]['begin_at'])
          //       .toLocal().toString() == slots[j].begin_at.toString())
          //       || (DateTime.parse(bookingBusinessAppointments[i]['begin_at'])
          //           .toLocal().isBefore(slots[j].begin_at)
          //           && DateTime.parse(bookingBusinessAppointments[i]['begin_at'])
          //               .add(Duration(minutes: bookingBusinessAppointments[i]['duration']))
          //               .toLocal().isAfter(slots[j].begin_at))) {
          //     contaIncastri++;
          //     //print(bookingBusinessAppointments[i]['begin_at']);
          //     if (contaIncastri >= widget.bookingBusiness.max_contemporary_appointments) {
          //       slots[j-1].type = 2;
          //     }
          //   }
          // }
          // else if(j > 0) {

          // //print("bookingBusinessAppointments[i]['duration']");
          // //print(bookingBusinessAppointments[i]['duration']);

          if(j == 0) {
            if ((DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAtSameMomentAs(slots[j].begin_at!)) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(slots[j].end_at!)
                    && DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'].toInt())).isAfter(slots[j].end_at!))
            ) {
              contaIncastri++;
              // //print(bookingBusinessAppointments[i]['begin_at']);
              if (contaIncastri >= widget.prestazione!.business!.max_contemporary_appointments!) {
                slots[j].type = 2;
              }
            }
          }
          // j = newdate, i = tempdate
          if(j >= 1)
            if ((DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAtSameMomentAs(slots[j].begin_at!)) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'])).isAtSameMomentAs(slots[j].end_at!)) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(slots[j].begin_at!) && (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'])).isAfter(slots[j].begin_at!))) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(slots[j].end_at!) && (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'])).isAfter(slots[j].end_at!))) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isAfter(slots[j].begin_at!) && (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'])).isBefore(slots[j].end_at!))) ||
                (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).isBefore(slots[j].begin_at!) && (DateTime.parse(bookingBusinessAppointments![i]['begin_at'].toString().replaceAll('Z', '')).add(Duration(hours: DateTime.now().timeZoneOffset.inHours)).add(Duration(minutes: bookingBusinessAppointments![i]['duration'])).isAfter(slots[j].end_at!)))
            )
              /*if ((DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().toString() == slots[j].begin_at.toLocal().toString())
                || (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().add(Duration(minutes: bookingBusinessAppointments[i]['duration'])).toLocal().toString() == slots[j].end_at.toLocal().toString())
                || (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().isBefore(slots[j].begin_at.toLocal()) && (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().add(Duration(minutes: bookingBusinessAppointments[i]['duration'])).toLocal().isAfter(slots[j].begin_at.toLocal())))
                || (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().isBefore(slots[j].begin_at.toLocal()) && (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().add(Duration(minutes: bookingBusinessAppointments[i]['duration'])).toLocal().isAfter(slots[j].end_at.toLocal())))

                // || (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().isAfter(slots[j].begin_at.toLocal()) && (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().add(Duration(minutes: bookingBusinessAppointments[i]['duration'])).toLocal().isAfter(slots[j].begin_at.toLocal())))
                || (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().isAfter(slots[j].begin_at.toLocal()) && (DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().add(Duration(minutes: bookingBusinessAppointments[i]['duration'])).toLocal().isBefore(slots[j].end_at.toLocal())))
            )*/
            {
              contaIncastri++;
              // //print(DateTime.parse(bookingBusinessAppointments[i]['begin_at']).toLocal().toString());
              if (contaIncastri >= widget.prestazione!.business!.max_contemporary_appointments!) {
                slots[j].type = 2;
              }
            }
        }
      }

      slots.sort((a, b) => a.begin_at!.compareTo(b.begin_at!));

      // print('ciccio2');
      // for(var t in slots){
      //   print(t.begin_at.toString() + ' - ' + t.end_at.toString() + ' - ' + t.type.toString());
      // }
    }
  }

  Future getOccupiedDates() async {
    // var url = Uri.parse("${Utils.httpServerUrl}occupied_booking/business");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.prestazione!.business!.id}/booking/occupied");

    Map<String, String?> body = {
      // 'business_id': widget.bookingBusiness.id,
      'business_id': widget.prestazione!.business!.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'Business-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      occupiedDates = jsonData;
      // occupiedDates!.addAll(jsonData);
      // appointmentsDefinitive.removeWhere((e) => e.type == 1);
      // for(var e in occupiedDates){
      //   new Appointment(
      //     begin_at: e['begin_at'],
      //     end_at: e['end_at'],
      //   );
      // }
      // appointmentsDefinitive.sort((a, b) => a.begin_at.compareTo(b.begin_at));
      // });

      // print('occupiedDates5ccvv5');
      // print(jsonData);
      // //print(occupiedDates.toString());
      return jsonData;
    }
  }

  Future getBookings() async {
    // var url = Uri.parse(Utils.httpServerUrl + "booking/booking_business_appointments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.prestazione!.business!.id}/booking/begin-at-duration");

    // //print('DateTime.now().toIso8601String()');
    // //print(DateTime.now().toIso8601String());
    // //print('DateTime.now().toUtc()');
    // //print(DateTime.now().toUtc());

    //todo: ottenere solo gli appuntamenti del data selezionata
    Map<String, dynamic> body = {
      // 'business_id': widget.bookingBusiness.id,
      'business_id': widget.prestazione!.business!.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {

      // bookingBusinessAppointments = jsonData;
      bookingBusinessAppointments!.addAll(jsonData);

      //print('jsonDatammkkkiki');
      // //print(jsonData[0]);
      // for(var e in jsonData){
      //   //print(e);
      //   e['begin_at'] = DateTime.parse(e['begin_at']).subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toIso8601String()*/.toString();
      //   // e['begin_at'] = "DateTime.parse(e['begin_at']).toUtc()/*.toIso8601String()*/.toString()";
      // }

      // occupiedDates.addAll(jsonData);
      // appointmentsDefinitive.removeWhere((e) => e.type == 1);
      // for(var e in occupiedDates){
      //   new Appointment(
      //     begin_at: e['begin_at'],
      //     end_at: e['end_at'],
      //   );
      // }
      // appointmentsDefinitive.sort((a, b) => a.begin_at.compareTo(b.begin_at));
      // });

      // //print('bookingBusinessAppointments');
      // //print(jsonData);
      // //print(bookingBusinessAppointments.toString());
      return jsonData;
    }
  }

  Future getGuestBookings() async {
    // var url = Uri.parse("${Utils.httpServerUrl}booking/guest_booking_business_appointments");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.prestazione!.business!.id}/booking/guest/begin-at-duration");

    Map<String, dynamic> body = {
      // 'business_id': widget.bookingBusiness.id,
      'business_id': widget.prestazione!.business!.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);

      bookingBusinessAppointments!.addAll(jsonData);
      //print('jsonDatavdfghgh');
      // for(var e in jsonData){
      //   //print(e);
      //   //print(DateTime.parse(e['begin_at']).toLocal());
      //   e['begin_at'] = DateTime.parse(e['begin_at']).subtract(Duration(hours: DateTime.now().timeZoneOffset.inHours))/*.toIso8601String()*/.toString();
      //   // e['begin_at'] = "DateTime.parse(e['begin_at']).toUtc()/*.toIso8601String()*/.toString()";
      // }

      return jsonData;
    }
  }

  // Future getTimetableDay(int weekday) async {
  //   var url = Uri.parse(Constants.serverUrl + "timetable/weekday");
  //   // var ticketCategoryProvider = Provider.of<TicketProvider>(context/*, listen: false*/);
  //
  //   Map<String, dynamic> body = {
  //     'weekday': weekday.toString(),
  //     'business_id': widget.bookingBusiness.id,
  //   };
  //
  //   var response = await http.post(
  //       url,
  //       body: jsonEncode(body),
  //       headers: {
  //         'Accept': '*/*',
  //         'Content-Type': 'application/json',
  //         'Accept-encoding': 'gzip, deflate',
  //         'connection': 'keep-alive',
  //       }
  //   );
  //
  //   //print('response.statusCode');
  //   //print(response.statusCode);
  //   if(response.statusCode >= 200 && response.statusCode < 400) {
  //     var jsonData = json.decode(response.body);
  //     setState(() {
  //       timetableDay = jsonData;
  //     });
  //
  //     // //print(jsonData);
  //     //print('timetableDay.toString()11');
  //     //print(timetableDay.toString());
  //
  //     if(timetableDay.isNotEmpty){
  //       for(var e in timetableDay) {
  //         setState(() {
  //           openingDate = new DateTime(
  //             selectedDate.year,
  //             selectedDate.month,
  //             selectedDate.day,
  //             e['open_at_hour'],
  //             e['open_at_minute'],
  //           );
  //           openingDates.add(openingDate);
  //
  //           closingDate = new DateTime(
  //             selectedDate.year,
  //             selectedDate.month,
  //             selectedDate.day,
  //             e['close_at_hour'],
  //             e['close_at_minute'],
  //           );
  //           closingDates.add(closingDate);
  //         });
  //
  //         // setSlots(openingDate, closingDate);
  //
  //         //print('openingDates');
  //         //print(openingDates.toString());
  //         //print('closingDates');
  //         //print(closingDates.toString());
  //
  //         DateTime newDate = openingDate;
  //         //print('newDate0');
  //         //print(newDate.toString());
  //
  //         contaIntervalliDaMezzora = 0;
  //         // intervalliDaMezzoraPerApertura.clear();
  //         while(newDate.isBefore(closingDate) || newDate.isAtSameMomentAs(closingDate)) {
  //           ciccio.add(newDate);
  //           newDate = newDate.add(Duration(minutes: 30));
  //           setState(() {
  //             contaIntervalliDaMezzora++;
  //           });
  //           // if(newDate.add(Duration(minutes: 30)).isAfter(newDate.add(Duration(minutes: widget.prestazione.duration))))
  //           if(newDate.add(Duration(minutes: 30)).isAfter(closingDate)) {
  //             setState(() {
  //               // contaIntervalliDaMezzora--;
  //             });
  //             intervalliDaMezzoraPerApertura.add(contaIntervalliDaMezzora);
  //             break;
  //           }
  //         }
  //
  //         //print('contaIntervalliDaMezzora');
  //         //print(contaIntervalliDaMezzora.toString());
  //         //print('newDate1');
  //         //print(newDate.toString());
  //         //print('ciccio');
  //         //print(ciccio.toString());
  //       }
  //
  //       return jsonData;
  //     }
  //   }
  // }

  Future getTimetableDay(int weekday) async {
    // var url = Uri.parse(Utils.httpServerUrl + "timetable/weekday");
    var url = Uri.parse("${Utils.httpServerUrl}business/${widget.prestazione!.business!.id}/timetable/weekday/${weekday.toString()}");

    Map<String, dynamic> body = {
      'weekday': weekday.toString(),
      // 'business_id': widget.bookingBusiness.id,
      'business_id': widget.prestazione!.business!.id,
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
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

    // //print('response.statusCode');
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // setState(() {
      timetableDay = jsonData;
      // });

      // print('jsonDatafg65b65bn6');
      // print(jsonData);
      // //print('timetableDay.toString()11');
      // //print(timetableDay.toString());

      // //print('timetableDay.length');
      // //print(timetableDay.length.toString());

      if(timetableDay!.isNotEmpty){
        await setSlots();
        return jsonData;
      }
    }
  }

  Widget _dateBar() {
    return Container(
      // padding: EdgeInsets.only(bottom: 74),
      // margin: EdgeInsets.only(bottom: 54),
      // height: 50,
      child: DatePicker(
        DateTime.now(),
        // height: 70.0,
        initialSelectedDate: DateTime.now(),
        locale: 'it_IT',
        selectionColor: Colors.transparent,
        // selectionColor: Colors.blue[500],
        selectedTextColor: Colors.blue,
        dateTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.w800,
            color: Colors.grey,
          ),
        ),
        dayTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
              fontSize: 10.0,
              color: Colors.grey,
              fontWeight: FontWeight.w500
          ),
        ),
        monthTextStyle: GoogleFonts.lato(
          textStyle: TextStyle(
            fontSize: 10.0,
            color: Colors.grey,
          ),
        ),
        // deactivatedColor: Colors.white,
        onDateChange: (date) async {
          await updateSlots(date);
        },
      ),
    );
  }

  Future getAllPrestazioneBuyers() async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione/buyers");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/${widget.prestazione!.id}/user/is_shared");

    Map<String, dynamic> body = {
      "prestazione_id": widget.prestazione!.id
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          // HttpHeaders.authorizationHeader: UserPreferences.getUserToken()
        }
    );

    // //print("singleEventReservationBuyers response.statusCode");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      setState(() {
        prestazioneBuyers = jsonData;
      });
      // //print("singleEventReservationBuyers:");
      // //print(prestazioneBuyers);

      return jsonData;
    }
  }

  Future getPrestazioneLike({String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/user_prestazione");
    var url = Uri.parse("${Utils.httpServerUrl}user/${userProvider.user!.id}/prestazione/${widget.prestazione!.id}");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
    };

    // var response = await http.post(
    var response = await http.get(
        url,
        // body: jsonEncode(body),
        headers: {
          'Accept': '*/*',
          'Content-Type': 'application/json',
          'Accept-encoding': 'gzip, deflate',
          'connection': 'keep-alive',
          'Timezone-Offset': DateTime.now().timeZoneOffset.inHours.toString(),
          'X-App-Version-Name': Utils.version_name,
          'X-App-Version-Number': Utils.version_id.toString(),
          'X-Client-Type': 'User-Mobile-App',
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // if(response.statusCode == 401 && UserPreferences.getIsLogged() == true) {
    //   await logout();
    // }
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      // businessPostLikes = jsonData;
      // //print("likes???");
      // //print(posts);
      // //print(jsonData);

      if(jsonData == 1){
        setState(() {
          isLikedPost = true;
        });

      }
      else if(jsonData == 0){
        setState(() {
          isLikedPost = false;
        });
      }
      // notifyListeners();
      return jsonData;
    }
  }

  Future likePrestazione({String? postId, String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/like");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/${widget.prestazione!.id}/like");

    Map<String, dynamic> body = {
      // "user_id": widget.user.id,
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
    };

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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      await getPrestazioneLike(/*userId*/);

      return response.statusCode;
    }
    else if(response.statusCode == 401){
      userProvider.logout(context);
    }
  }

  Future unlikePrestazione({String? postId, String? userId}) async {
    // var url = Uri.parse(Utils.httpServerUrl + "prestazione_favorite/unlike");
    var url = Uri.parse("${Utils.httpServerUrl}prestazione/${widget.prestazione!.id}/like");

    Map<String, dynamic> body = {
      "user_id": userProvider.user!.id,
      'prestazione_id': widget.prestazione!.id
    };

    // var response = await http.post(
    var response = await http.delete(
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
          HttpHeaders.authorizationHeader: UserPreferences.getUserToken()!
        }
    );

    // //print("response.statusCode:");
    // //print(response.statusCode);
    if(response.statusCode >= 200 && response.statusCode < 400) {
      var jsonData = json.decode(response.body);
      await getPrestazioneLike(/*userId*/);

      return response.statusCode;
    }
    else if(response.statusCode == 401){
      userProvider.logout(context);
    }
  }

  double? getDistance(){
    distanceInMeters = Geolocator.distanceBetween(
      // 52.2165957, 6.9437819, 52.3546274, 4.8285838
      // 45.4281857, 9.1531147, 45.44131, 9.14952
      // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
        geolocationProvider.position!.latitude, geolocationProvider.position!.longitude,
        widget.prestazione!.business!.latitude!, widget.prestazione!.business!.longitude!
    );
    return distanceInMeters;
  }

  bool get _isAppBarExpanded {
    return _scrollController!.hasClients && _scrollController!.offset > (MediaQuery.of(context).size.height * .32 - kToolbarHeight);
  }

  @override
  void initState() {
    super.initState();
    initializeDateFormatting();

    _theme = Colors.white;

    _scrollController = ScrollController()..addListener(
      () => _isAppBarExpanded ? _theme != Colors.grey[500] ? setState(() {
        _theme = Colors.grey[500];
        // print('setState is called');
      },):{} : _theme != Colors.white ?
      setState((){
        // print('setState is called');
        _theme = Colors.white;
      }):{},
    );

    // //print('widget.prestazione.toJson()');
    // //print(widget.prestazione.toJson());
    // //print('widget.prestazione.business.toJson()');
    // //print(widget.prestazione.business.toJson());

    userProvider = Provider.of<UserProvider>(context, listen: false);
    cartProvider = Provider.of<CartProvider>(context, listen: false);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: false);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    // if(/*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
    //   getDistance();
    //   // setState(() {
    //   //
    //   // });
    // }

    e = geolocationProvider.checkGeolocationPermission(context).then((value) {
      if(/*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)){
        // //print('geolocationProvider.position.longitude');
        // //print(geolocationProvider.position.longitude);
        // //print('geolocationProvider.position.latitude');
        // //print(geolocationProvider.position.latitude);
        // //print('getDistance');
        // //print((getDistance()/1000).toString());
        // setState(() {
        //
        // });

        getDistance();
      }

      // //print('value.longitude');
      // //print(value.longitude);
      // //print('value.latitude');
      // //print(value.latitude);
    });

    openingDates.clear();
    closingDates.clear();

    // WidgetsBinding.instance.addPostFrameCallback((_){
    a = getTimetableDay(selectedDate.weekday)
        .then((value) => getOccupiedDates()
        .then((value) => getBookings()
    // .then((value) => getGuestBookings()
        .then((value) => setSlots())/*)*/));

    if(UserPreferences.getIsLogged()!){
      d = getPrestazioneLike();
    }

    Future.wait([
      b = getAllPrestazioneBuyers(),
      // c = getPrestazioneAllDatePost(),
      // d = getPrestazioneLike(),
    ]);
    // });

    // prenotaAnimationController = AnimationController(
    //   vsync: this,
    //   duration: Duration(milliseconds: 8000),
    //   reverseDuration: Duration(milliseconds: 8000),
    // );
    // topAnimationAlignment = TweenSequence<Alignment>(
    //     [
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //           weight: 1
    //       ),
    //     ]
    // ).animate(prenotaAnimationController);
    // bottomAnimationAlignment = TweenSequence<Alignment>(
    //     [
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.bottomRight, end: Alignment.bottomLeft),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.bottomLeft, end: Alignment.topLeft),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.topLeft, end: Alignment.topRight),
    //           weight: 1
    //       ),
    //       TweenSequenceItem<Alignment>(
    //           tween: Tween<Alignment>(begin: Alignment.topRight, end: Alignment.bottomRight),
    //           weight: 1
    //       ),
    //     ]
    // ).animate(prenotaAnimationController);
    // prenotaAnimationController.repeat();
  }

  @override
  Widget build(BuildContext context) {
    cartProvider = Provider.of<CartProvider>(context, listen: true);
    userProvider = Provider.of<UserProvider>(context, listen: true);
    favoriteProvider = Provider.of<PrestazioneFavoriteProvider>(context, listen: true);
    geolocationProvider = Provider.of<GeolocationProvider>(context, listen: true);
    socketProvider = Provider.of<SocketProvider>(context, listen: true);

    return Scaffold(
        floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
        floatingActionButton: Visibility(
          // visible: !Utils.isSocial && !Utils.isBusiness,
          visible: cartProvider.items.length > 0,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Container(
                width: MediaQuery.of(context).size.width * 0.9,
                margin: EdgeInsets.only(bottom: 10),
                height: 50,
                child: ElevatedButton(
                  // style: ButtonStyle(
                  //   backgroundColor: MaterialStateProperty.all(Colors.blue[500])
                  // ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.shopping_cart_outlined,
                        // Icons.check_circle_outline_rounded,
                        color: Colors.white,
                        size: 22,
                      ),
                      SizedBox(width: 7,),
                      Text(
                        // 'Vai al carrello',
                        // 'Prenota',
                        'Prosegui',
                        style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w700
                        ),
                      ),
                    ],
                  ),
                  onPressed: () async {
                    // Navigator.push(
                    //   context,
                    //   MaterialPageRoute(builder: (context) => CheckoutScreen()),
                    // );
                    if(UserPreferences.getIsLogged()!){
                      Navigator.push(
                          context,
                          PageTransition(
                              duration: const Duration(milliseconds: 500),
                              alignment: Alignment.center,
                              type: PageTransitionType.fade,
                              // child: NotificationScreen(),
                              // child: CartScreen()
                              child: ReservationScreen()
                          )
                      );
                    }
                    else {
                      Fluttertoast.showToast(
                        msg: 'Accedi per poter accedere a questa schermata',
                        backgroundColor: Colors.grey[700],
                      );
                    }
                  },
                ),
              ),
              // SizedBox(height: 4),
              // Container(
              //   width: MediaQuery.of(context).size.width * 0.9,
              //   margin: EdgeInsets.only(bottom: 10),
              //   height: 50,
              //   child: ElevatedButton(
              //     style: ButtonStyle(
              //         backgroundColor: MaterialStateProperty.all(Colors.grey[500])
              //     ),
              //     child: Row(
              //       mainAxisAlignment: MainAxisAlignment.center,
              //       children: [
              //         Icon(
              //           Icons.home_outlined,
              //           color: Colors.white,
              //           size: 22,
              //         ),
              //         SizedBox(width: 5,),
              //         Text(
              //           'Ritorna alla Home',
              //           style: TextStyle(
              //               fontSize: 16,
              //               fontWeight: FontWeight.w700
              //           ),
              //         ),
              //       ],
              //     ),
              //     onPressed: () async {
              //       await Navigator.pushAndRemoveUntil(
              //           context,
              //           PageTransition(
              //             child: HomeScreen(),
              //             duration: const Duration(milliseconds: 500),
              //             type: PageTransitionType.fade,
              //           ),
              //               (route) => false
              //       );
              //     },
              //   ),
              // ),
            ],
          ),
        ),
        backgroundColor: Colors.white,
        // appBar: AppBar(
        //   elevation: 0,
        //   toolbarHeight: 85,
        //   backgroundColor: Colors.white,
        //   //Color.fromRGBO(245, 93, 62, 1),
        //   // title: Text(
        //   //   widget.prestazione.title,
        //   //   style: TextStyle(
        //   //     color: Colors.blue,
        //   //     fontSize: 21,
        //   //     fontWeight: FontWeight.w700
        //   //   ),
        //   // ),
        //   // centerTitle: true,
        //   leading: IconButton(
        //     onPressed: (){
        //       Navigator.pop(context);
        //     },
        //     icon: Icon(
        //       Icons.arrow_back_outlined,
        //       color: Colors.grey[500],
        //       size: 27,
        //     ),
        //     color: Colors.black,
        //   ),
        //   // centerTitle: true,
        //   title: InkWell(
        //     highlightColor: Colors.transparent,
        //     splashColor: Colors.transparent,
        //     onTap: (){
        //       Navigator.push(
        //         context,
        //         PageTransition(
        //             duration: const Duration(milliseconds: 500),
        //             alignment: Alignment.center,
        //             type: PageTransitionType.fade,
        //             child: BookingBusinessProfileScreen(
        //               business: widget.prestazione!.business,
        //             )
        //         ),
        //       );
        //     },
        //     child: Padding(
        //       padding: const EdgeInsets.only(left: 0, top: 0),
        //       child: Row(
        //         mainAxisAlignment: MainAxisAlignment.start,
        //         children: <Widget>[
        //           Hero(
        //             // tag: 0,
        //             tag: widget.prestazione!.image != null && widget.prestazione!.image != ''? widget.prestazione! : widget.prestazione!.business!,
        //             child: ClipRRect(
        //               borderRadius: BorderRadius.circular(8),
        //               child: FutureImage(
        //                 widget.prestazione!.image != null && widget.prestazione!.image != ''
        //                     ? widget.prestazione!.image! : widget.prestazione!.business!.profile_image!,
        //                 height: 45,
        //                 width: 45,
        //               ),
        //             ),
        //           ),
        //           SizedBox(
        //             width: 10,
        //           ),
        //           // Text(
        //           //   widget.bookingBusiness.name,
        //           //   style: TextStyle(
        //           //       fontWeight:
        //           //       FontWeight.w700,
        //           //       fontSize: 14,
        //           //       color: Colors.grey[600]
        //           //   ),
        //           // ),
        //           Expanded(
        //             child: ListView(
        //               shrinkWrap: true,
        //               padding: EdgeInsets.only(bottom: 0),
        //               physics: const NeverScrollableScrollPhysics(),
        //               // crossAxisAlignment: CrossAxisAlignment.start,
        //               children: [
        //                 Marquee(
        //                   child: Row(
        //                     children: [
        //                       GradientText(
        //                         // widget.bookingBusiness.name,
        //                         widget.prestazione!.title!,
        //                         gradient: LinearGradient(
        //                             begin: Alignment.bottomLeft,
        //                             end: Alignment.topRight,
        //                             colors: [
        //                               // Color(0xff8921aa),
        //                               // Color(0xffDA44bb),
        //                               Colors.blueGrey,
        //                               Colors.blueGrey,
        //
        //                               // // Color(0xffFFA818),
        //                               // Color(0xffF9A516),
        //                               // // Color(0xffED9B15),
        //                               // Color(0xffF4A117),
        //
        //                               // Colors.blue,
        //                               // Colors.blue,
        //                             ]
        //                         ),
        //                         style: TextStyle(
        //                             color: Colors.blue,
        //                             fontSize: 17,
        //                             fontWeight: FontWeight.w600
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //                 SizedBox(height: 2.5,),
        //                 Marquee(
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       // Text(
        //                       //   // widget.bookingBusiness.name,
        //                       //   widget.prestazione.business.name,
        //                       //   // widget.prestazione.title,
        //                       //   style: TextStyle(
        //                       //     // color: Colors.grey[600],
        //                       //       color: Colors.green[500],
        //                       //       // color: Colors.blue[500],
        //                       //       fontWeight: FontWeight.w700,
        //                       //       fontSize: 12
        //                       //   ),
        //                       // )
        //                       GradientText(
        //                         // widget.bookingBusiness.name,
        //                         widget.prestazione!.business!.name!,
        //                         gradient: LinearGradient(
        //                             begin: Alignment.bottomLeft,
        //                             end: Alignment.topRight,
        //                             colors: [
        //                               // Color(0xff8921aa),
        //                               // Color(0xffDA44bb),
        //
        //                               Colors.blue[500]!,
        //                               Colors.blue[500]!,
        //
        //                               // Colors.green[500],
        //                               // Colors.green[500],
        //
        //                               // Color(0xffFFA818),
        //                               // Color(0xffF9A516),
        //                               // Color(0xffED9B15),
        //                               // Color(0xffF4A117),
        //                             ]
        //                         ),
        //                         style: TextStyle(
        //                           // color: Colors.grey[600],
        //                           // color: Colors.green[500],
        //                             color: Colors.blue[500],
        //                             fontWeight: FontWeight.w700,
        //                             fontSize: 12
        //                         ),
        //                       )
        //                     ],
        //                   ),
        //                 ),
        //                 SizedBox(height: 4,),
        //                 Marquee(
        //                   child: Row(
        //                     mainAxisAlignment: MainAxisAlignment.center,
        //                     children: [
        //                       Card(
        //                         semanticContainer: true,
        //                         // color: Colors.grey[100],
        //                         color: Colors.green[100],
        //                         margin: EdgeInsets.all(0),
        //                         clipBehavior: Clip.antiAliasWithSaveLayer,
        //                         shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(50.0),
        //                         ),
        //                         elevation: 0,
        //                         // margin: EdgeInsets.all(0),
        //                         child: Padding(
        //                           padding: EdgeInsets.only(
        //                             top: 5,
        //                             bottom: 5,
        //                             left: 6,
        //                             right: 6,
        //                           ),
        //                           child: Row(
        //                             children: [
        //                               Padding(
        //                                 padding: const EdgeInsets.only(bottom: 0.0),
        //                                 child: Icon(
        //                                   Icons.price_change,
        //                                   // Icons.price_change_outlined,
        //                                   // color: Colors.grey[600],
        //                                   color: Colors.green[800],
        //                                   size: 14,
        //                                 ),
        //                               ),
        //                               SizedBox(width: 3),
        //                               RichText(
        //                                 text: TextSpan(
        //                                     children: <TextSpan>[
        //                                       TextSpan(
        //                                         //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
        //                                         //   text: prestazione.duration.toString() + ' minuti',
        //                                           text: '€ ' + NumberFormat.currency(
        //                                             // customPattern: '#,##',
        //                                             locale: 'IT_it',
        //                                             decimalDigits: 2,
        //                                             symbol: '',
        //                                             // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
        //                                           ).format(widget.prestazione!.price!?.toDouble()),
        //                                           style: GoogleFonts.roboto(
        //                                               fontWeight: FontWeight.w700,
        //                                               // color: Colors.grey[600],
        //                                               color: Colors.green[800],
        //                                               // color: Colors.blue[500],
        //                                               fontSize: 12
        //                                           )
        //                                       ),
        //                                     ]
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                       SizedBox(width: 10,),
        //                       Card(
        //                         semanticContainer: true,
        //                         color: Colors.grey[100],
        //                         margin: EdgeInsets.all(0),
        //                         clipBehavior: Clip.antiAliasWithSaveLayer,
        //                         shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(50.0),
        //                         ),
        //                         elevation: 0,
        //                         // margin: EdgeInsets.all(0),
        //                         child: Padding(
        //                           padding: EdgeInsets.only(
        //                             top: 5,
        //                             bottom: 5,
        //                             left: 8,
        //                             right: 8,
        //                           ),
        //                           child: Row(
        //                             children: [
        //                               Padding(
        //                                 padding: const EdgeInsets.only(bottom: 1.0),
        //                                 child: Icon(
        //                                   Icons.access_time_outlined,
        //                                   // Icons.price_change,
        //                                   // Icons.price_change_outlined,
        //                                   color: Colors.grey[600],
        //                                   size: 14,
        //                                 ),
        //                               ),
        //                               SizedBox(width: 3),
        //                               RichText(
        //                                 text: TextSpan(
        //                                     children: <TextSpan>[
        //                                       TextSpan(
        //                                         //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
        //                                           text: widget.prestazione!.duration.toString() + ' minuti'/*' "'*/,
        //                                           // text: '€ ' + NumberFormat.currency(
        //                                           //   // customPattern: '#,##',
        //                                           //   locale: 'IT_it',
        //                                           //   decimalDigits: 2,
        //                                           //   symbol: '',
        //                                           // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
        //                                           // ).format(prestazione.price?.toDouble()),
        //                                           style: GoogleFonts.roboto(
        //                                               fontWeight: FontWeight.w700,
        //                                               color: Colors.grey[600],
        //                                               // color: Colors.green[600],
        //                                               fontSize: 12
        //                                           )
        //                                       ),
        //                                     ]
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                       // (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder<Object>(
        //                       //     future: e,
        //                       //     builder: (context, snapshot) {
        //                       //       if(snapshot.connectionState == ConnectionState.done){
        //                       //         return Card(
        //                       //           semanticContainer: true,
        //                       //           color: Colors.grey[100],
        //                       //           margin: EdgeInsets.only(left: 10),
        //                       //           clipBehavior: Clip.antiAliasWithSaveLayer,
        //                       //           shape: RoundedRectangleBorder(
        //                       //             borderRadius: BorderRadius.circular(50.0),
        //                       //           ),
        //                       //           elevation: 0,
        //                       //           // margin: EdgeInsets.all(0),
        //                       //           child: Padding(
        //                       //             padding: EdgeInsets.only(
        //                       //               top: 5,
        //                       //               bottom: 5,
        //                       //               left: 6,
        //                       //               right: 6,
        //                       //             ),
        //                       //             child: Row(
        //                       //               children: [
        //                       //                 Padding(
        //                       //                   padding: const EdgeInsets.only(bottom: 0.0),
        //                       //                   child: Icon(
        //                       //                     Icons.pin_drop_outlined,
        //                       //                     // Icons.price_change_outlined,
        //                       //                     color: Colors.grey[600],
        //                       //                     size: 15,
        //                       //                   ),
        //                       //                 ),
        //                       //                 SizedBox(width: 3),
        //                       //                 RichText(
        //                       //                   text: TextSpan(
        //                       //                       children: <TextSpan>[
        //                       //                         TextSpan(
        //                       //                           //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
        //                       //                           //   text: prestazione.duration.toString() + ' minuti',
        //                       //                             text: NumberFormat.currency(
        //                       //                               // customPattern: '#,##',
        //                       //                                 decimalDigits: 2,
        //                       //                                 symbol: '',
        //                       //                                 locale: 'IT_it'
        //                       //                             // ).format(Geolocator.distanceBetween(
        //                       //                             //   // 52.2165957, 6.9437819, 52.3546274, 4.8285838
        //                       //                             //   // 45.4281857, 9.1531147, 45.44131, 9.14952
        //                       //                             //   // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
        //                       //                             //     geolocationProvider.position.latitude, geolocationProvider.position.longitude,
        //                       //                             //     widget.prestazione.business.latitude, widget.prestazione.business.longitude
        //                       //                             // )/1000) + 'km',
        //                       //                             ).format(getDistance()/1000) + 'km',
        //                       //                             style: GoogleFonts.roboto(
        //                       //                                 fontWeight: FontWeight.w700,
        //                       //                                 color: Colors.grey[600],
        //                       //                                 // color: Colors.green[600],
        //                       //                                 // color: Colors.blue[500],
        //                       //                                 fontSize: 12
        //                       //                             )
        //                       //                         ),
        //                       //                       ]
        //                       //                   ),
        //                       //                 ),
        //                       //               ],
        //                       //             ),
        //                       //           ),
        //                       //         );
        //                       //       }
        //                       //       else {
        //                       //         return SizedBox();
        //                       //       }
        //                       //     }
        //                       // ) : SizedBox(),
        //                       // SizedBox(width: 10,),
        //                       Card(
        //                         semanticContainer: true,
        //                         color: Colors.grey[100],
        //                         margin: EdgeInsets.all(0),
        //                         clipBehavior: Clip.antiAliasWithSaveLayer,
        //                         shape: RoundedRectangleBorder(
        //                           borderRadius: BorderRadius.circular(50.0),
        //                         ),
        //                         elevation: 0,
        //                         // margin: EdgeInsets.all(0),
        //                         child: Padding(
        //                           padding: EdgeInsets.only(
        //                             top: 3,
        //                             bottom: 3,
        //                             left: 5,
        //                             right: 8,
        //                           ),
        //                           child: Row(
        //                             children: [
        //                               ClipRRect(
        //                                 borderRadius: BorderRadius.circular(50),
        //                                 child: FutureImage(
        //                                   // widget.bookingBusiness.profile_image,
        //                                   // widget.prestazione.business.profile_image,
        //                                   widget.prestazione!.business!.category!.image!,
        //                                   width: 20,
        //                                   height: 20,
        //                                 ),
        //                               ),
        //                               SizedBox(width: 5),
        //                               RichText(
        //                                 text: TextSpan(
        //                                     children: <TextSpan>[
        //                                       TextSpan(
        //                                         // text: 'Estetista'/*' "'*/,
        //                                           text: widget.prestazione!.business!.category!.name/*' "'*/,
        //                                           // text: '€ ' + NumberFormat.currency(
        //                                           //   // customPattern: '#,##',
        //                                           //   locale: 'IT_it',
        //                                           //   decimalDigits: 2,
        //                                           //   symbol: '',
        //                                           // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
        //                                           // ).format(prestazione.price?.toDouble()),
        //                                           style: GoogleFonts.roboto(
        //                                               fontWeight: FontWeight.w700,
        //                                               color: Colors.grey[600],
        //                                               // color: Colors.green[600],
        //                                               fontSize: 12
        //                                           )
        //                                       ),
        //                                     ]
        //                                 ),
        //                               ),
        //                             ],
        //                           ),
        //                         ),
        //                       ),
        //                     ],
        //                   ),
        //                 ),
        //               ],
        //             ),
        //           ),
        //         ],
        //       ),
        //     ),
        //   ),
        //   actions: [
        //     FutureBuilder<Object?>(
        //       // future: Future.wait([d]),
        //         future: d,
        //         builder: (context, snapshot) {
        //           if(snapshot.connectionState != ConnectionState.done){
        //             return SizedBox();
        //           }
        //           else {
        //             return InkWell(
        //               highlightColor: Colors.transparent,
        //               splashColor: Colors.transparent,
        //               onTap: () async {
        //                 if(UserPreferences.getIsLogged()!){
        //                   if (isLikedPost){
        //                     // setState(() {
        //                     await /*postProvider.*/unlikePrestazione(
        //                       // postProvider.businessPostList[i].id,
        //                       // widget.user.id
        //                     ).then((value) {
        //                       if(value >= 200 && value < 400){
        //                         //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
        //                         favoriteProvider.getUserPrestazioneFavorites(userProvider.user!);
        //
        //                         // Fluttertoast.showToast(
        //                         //   msg: 'Rimosso dai Preferiti',
        //                         //   backgroundColor: Colors.grey[700],
        //                         // );
        //                         final SnackBar snackBar = SnackBar(
        //                           content: Text(
        //                             'Rimosso dai Preferiti',
        //                             style: TextStyle(
        //                               fontWeight: FontWeight.w600,
        //                               color: Colors.white,
        //                             ),
        //                           ),
        //                           backgroundColor: Colors.red,
        //                         );
        //                         snackbarKey.currentState?.showSnackBar(snackBar);
        //                       }
        //                     });
        //                     // });
        //                   }
        //                   else{
        //                     // setState(() {
        //                     await /*postProvider.*/likePrestazione(
        //                       // postProvider.businessPostList[i].id,
        //                       // widget.user.id
        //                     ).then((value) {
        //                       if(value >= 200 && value < 400){
        //                         //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
        //                         favoriteProvider.getUserPrestazioneFavorites(userProvider.user!);
        //                         // Fluttertoast.showToast(
        //                         //   msg: 'Aggiunto ai Preferiti',
        //                         //   backgroundColor: Colors.grey[700],
        //                         // );
        //                         final SnackBar snackBar = SnackBar(
        //                           content: Text(
        //                             'Aggiunto ai Preferiti',
        //                             style: TextStyle(
        //                               fontWeight: FontWeight.w600,
        //                               color: Colors.white,
        //                             ),
        //                           ),
        //                           backgroundColor: Colors.green,
        //                         );
        //                         snackbarKey.currentState?.showSnackBar(snackBar);
        //                       }
        //                     });
        //                     // });
        //                   }
        //                 }
        //                 else{
        //                   Fluttertoast.showToast(
        //                     msg: 'Accedi per aggiungere ai preferiti',
        //                     backgroundColor: Colors.grey[700],
        //                   );
        //                 }
        //
        //               },
        //               child: Padding(
        //                 padding: const EdgeInsets.only(right: 15, left: 0),
        //                 child: Icon(
        //                   // isLikedPost == true
        //                   //     ? Icons.favorite
        //                   //     : Icons.favorite_border_outlined,
        //                   isLikedPost == true
        //                       ? Icons.star
        //                       : Icons.star_outline,
        //                   // color: Colors.grey[600],
        //                   color: Colors.yellow[800],
        //                   // color: Colors.blue[500],
        //                   size: 31,
        //                 ),
        //               ),
        //             );
        //           }
        //         }
        //     ),
        //   ],
        // ),
        body: NotificationListener<OverscrollIndicatorNotification>(
          onNotification: (overscroll) {
            overscroll.disallowIndicator();
            return true;
          },
          child: NestedScrollView(
            controller: _scrollController,
            headerSliverBuilder: (context, innerBoxIsScrolled) {
              return [
                SliverAppBar(
                  expandedHeight: MediaQuery.of(context).size.height * .33,
                  floating: true,
                  pinned: true,
                  elevation: 0,
                  backgroundColor: Colors.white,
                  // backgroundColor: Color.fromRGBO(245, 93, 62, 1),
                  title: InkWell(
                    highlightColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    onTap: () async {
                      Navigator.push(
                          context,
                          PageTransition(
                            duration: const Duration(
                                milliseconds: 500
                            ),
                            alignment: Alignment.center,
                            type: PageTransitionType.fade,
                            child: BookingBusinessProfileScreen(
                              business: widget.prestazione!.business,
                            ),
                          )
                      );
                      // if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                      //   bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                      //
                      //   if (f != null) {
                      //     await map_launcher.MapLauncher.showDirections(
                      //       destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                      //       // destinationTitle: destinationTitle,
                      //       origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                      //       originTitle: 'originTitle',
                      //       // waypoints: waypoints,
                      //       directionsMode: map_launcher.DirectionsMode.driving,
                      //       mapType: map_launcher.MapType.google,
                      //     );
                      //   }
                      // }
                      // else{
                      //   await MapsLauncher.launchQuery(
                      //     // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                      //     // 'via cascina bianca, 6, milano, 20142, italia'
                      //     // 'Via Privata Parenzo, 8, 20143 Milano MI'
                      //     // 'Via Privata Parenzo, 8, Estetica Elixir'
                      //     // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                      //     // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                      //     //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                      //       widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                      //   );
                      // }
                    },
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        /*_isAppBarExpanded ?*/ ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: FutureImage(
                            widget.prestazione!.business!.profile_image!,
                            width: 35,
                            height: 35,
                          ),
                        ) /*: SizedBox(
                          width: 0,
                        )*/,
                        SizedBox(
                          width: /*_isAppBarExpanded ? 0 : */10,
                        ),
                        // SizedBox(
                        //   width: 15,
                        // ),
                        Expanded(
                          child: ListView(
                            shrinkWrap: true,
                            padding: EdgeInsets.only(bottom: 0),
                            // crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Marquee(
                                child: Row(
                                  children: [
                                    // Text(
                                    //   widget.bookingBusiness.name ?? '',
                                    //   style: TextStyle(
                                    //       color:  !_isAppBarExpanded ? Colors.white : Colors.blue,
                                    //       fontSize: 15,
                                    //       fontWeight: FontWeight.w600
                                    //   ),
                                    // ),
                                    /*Gradient*/Text(
                                      widget.prestazione!.business!.name ?? '',
                                      style: TextStyle(
                                          color: !_isAppBarExpanded ? Colors.white : Colors.blue[600],
                                          fontSize: 17,
                                          fontWeight: FontWeight.w600
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: /*2*/.5,),
                              // Text(
                              //   // 'Online',
                              //   '47 partecipanti',
                              //   style: TextStyle(
                              //     // color: Colors.grey[700],
                              //       color: Colors.green[500],
                              //       fontSize: 12,
                              //       fontWeight: FontWeight.w600
                              //   ),
                              // ),
                              Marquee(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    // Icon(
                                    //   Icons.location_on_outlined,
                                    //   color: Colors.grey[600],
                                    //   size: 15,
                                    //   // color: Colors.blue[500],
                                    //
                                    // ),
                                    /*Gradient*/Text(
                                      widget.prestazione!.business!.address ?? '',
                                      // widget.prestazione!.title ?? '',
                                      // gradient: LinearGradient(
                                      //     begin: Alignment.bottomLeft,
                                      //     end: Alignment.topRight,
                                      //     colors: [
                                      //       Color(0xff8921aa),
                                      //       Color(0xffDA44bb),
                                      //       // Color(0xffDA44bb)
                                      //     ]
                                      // ),
                                      style: TextStyle(
                                          color: !_isAppBarExpanded ? Colors.white : Colors.grey[600],
                                          // color: !_isAppBarExpanded ? Colors.white : Colors.grey[800],
                                          // color: Colors.blue[500],
                                          fontWeight: FontWeight.w700,
                                          fontSize: 13
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  centerTitle: true,
                  leading: /*!Utils.isBusiness ?*/ IconButton(
                    onPressed: (){
                      Navigator.pop(context);
                    },
                    icon: Icon(
                      // Icons.star_rounded,
                      // Icons.star_half_rounded,
                      // Icons.star_border_rounded,
                      Icons.arrow_back_outlined,
                      color: _isAppBarExpanded ? Colors.grey[500] : Colors.white,
                      // color: Colors./*white*/grey,
                      // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                      size: 27,
                    ),
                    color: Colors.black,

                  ) /*: SizedBox()*/,
                  // leading: InkWell(
                  //   onTap: (){
                  //     Navigator.pop(context);
                  //   },
                  //   child: Container(
                  //     // padding: EdgeInsets.all(10),
                  //     height: 10,
                  //     decoration: BoxDecoration(
                  //         shape: BoxShape.circle,
                  //         color: Colors.white,
                  //     ),
                  //     child: Center(
                  //       child: Icon(
                  //         // Icons.star_rounded,
                  //         // Icons.star_half_rounded,
                  //         // Icons.star_border_rounded,
                  //         Icons.arrow_back_outlined,
                  //         // color: _isAppBarExpanded ? Colors.grey[500] : Colors.red,
                  //         // color: _theme,
                  //         color: Colors.grey[700],
                  //         // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                  //         size: 23.5,
                  //       ),
                  //     ),
                  //   ),
                  // ),
                  actions: [
                    // InkWell(
                    //   onTap: () async {
                    //     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                    //
                    //     if (f != null) {
                    //       await map_launcher.MapLauncher.showDirections(
                    //         destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                    //         // destinationTitle: destinationTitle,
                    //         origin: map_launcher.Coords(45.4281857, 9.1531147),
                    //         originTitle: 'originTitle',
                    //         // waypoints: waypoints,
                    //         directionsMode: map_launcher.DirectionsMode.driving,
                    //         mapType: map_launcher.MapType.google,
                    //       );
                    //     }
                    //   },
                    //   child: Container(
                    //     margin: EdgeInsets.only(top: 10, bottom: 10, left: 10),
                    //     width: 80,
                    //     child: Card(
                    //       color: Colors.blue,
                    //       child: Padding(
                    //         padding: const EdgeInsets.all(4.0),
                    //         child: Row(
                    //           children: [
                    //             Icon(
                    //               Icons.location_on,
                    //               color: Colors.white,
                    //               size: 15,
                    //             ),
                    //             SizedBox(width: 2,),
                    //             Text(
                    //               NumberFormat.currency(
                    //                 // customPattern: '#,##',
                    //                   decimalDigits: 2,
                    //                   symbol: '',
                    //                   locale: 'IT_it'
                    //               ).format(Geolocator.distanceBetween(
                    //                 // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                    //                 // 45.4281857, 9.1531147, 45.44131, 9.14952
                    //                 // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                    //                   45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                    //               )/1000) + 'km',
                    //               textAlign: TextAlign.center,
                    //               // (Geolocator.distanceBetween(
                    //               //   // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                    //               //   // 45.4281857, 9.1531147, 45.44131, 9.14952
                    //               //   // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                    //               //     45.4281857, 9.1531147, 45.39799153197911, 9.148873111019878
                    //               // )/1000).toString(),
                    //               style: TextStyle(
                    //                   color: Colors.white,
                    //                   fontWeight: FontWeight.w800,
                    //                   fontSize: 13
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //       ),
                    //     ),
                    //   ),
                    // ),


                    // /*!Utils.isBusiness ?*/ InkWell(
                    //
                    //   onTap: (){
                    //     Navigator.push(
                    //       context,
                    //       PageTransition(
                    //         duration: const Duration(milliseconds: 500),
                    //         alignment: Alignment.center,
                    //         type: PageTransitionType.fade,
                    //         child: BusinessRoomScreen(
                    //           business: widget.business,
                    //         )
                    //       )
                    //     );
                    //   },
                    //   highlightColor: Colors.transparent,
                    //   splashColor: Colors.transparent,
                    //   child: Container(
                    //     // width: MediaQuery.of(context).size.width * 0.3,
                    //     // color: Colors.grey[50],
                    //     padding: EdgeInsets.only(right: 5, left: 10,),
                    //     margin: EdgeInsets.all(10),
                    //     decoration: BoxDecoration(
                    //       // color: Colors.blue[300],
                    //       // color: Colors.white,
                    //       color: Colors.transparent,
                    //       shape: BoxShape.circle,
                    //     ),
                    //     child: Center(
                    //         child: Icon(
                    //           // Icons.chat_bubble_outline,
                    //           !_isAppBarExpanded ? Icons.chat : Icons.chat_outlined,
                    //           // Icons.chat_outlined,
                    //           color: _isAppBarExpanded ? Colors.blue : Colors.white,
                    //           // color: Colors.blue[400],
                    //           size: 30,
                    //         )
                    //     ),
                    //   ),
                    // ) /*: SizedBox()*/,
                    Visibility(
                      visible: widget.prestazione!.description!.length > 0,
                      child: IconButton(
                        highlightColor: Colors.transparent,
                        splashColor: Colors.transparent,
                        onPressed: (){
                          // setState(() {
                          //   // !isDateTableVisible ? isDateTableVisible = true : isDateTableVisible = false;
                          //   isDateTableVisible = !isDateTableVisible;
                          // });
                          showDialog(
                            barrierLabel: "Label",
                            barrierDismissible: true,
                            barrierColor: Colors.black.withOpacity(0.5),
                            // transitionDuration: Duration(milliseconds: 700),
                            context: context,
                            // pageBuilder: (context, anim1, anim2) {
                            builder: (context) {
                              return Align(
                                // alignment: Alignment.topCenter,
                                alignment: Alignment.center,
                                // child: Container(
                                //   height: 300,
                                //   child: SizedBox.expand(child: FlutterLogo()),
                                //   margin: EdgeInsets.only(top: 50, left: 12, right: 12),
                                //   decoration: BoxDecoration(
                                //     color: Colors.white,
                                //     borderRadius: BorderRadius.circular(40),
                                //   ),
                                // ),
                                child: Card(
                                  clipBehavior: Clip.antiAliasWithSaveLayer,
                                  elevation: 4,
                                  // margin: EdgeInsets.only(top: 58, right: 0),
                                  margin: EdgeInsets.only(top: 0, right: 0),
                                  // padding: EdgeInsets.all(10),
                                  // decoration: BoxDecoration(
                                  //     border: Border.all(color: Colors.grey[500])
                                  //     // border: Border.all(color: Colors.blue[500]),
                                  //     // borderRadius: BorderRadius.all(Radius.circular(5))
                                  // ),
                                  // width: MediaQuery.of(context).size.width * .5,
                                  child: Container(
                                    width: MediaQuery.of(context).size.width * .7,
                                    height: MediaQuery.of(context).size.height * .5,
                                    // height: (widget.prestazione!.description!.length * 1.5 + (20)).toDouble(),
                                    padding: EdgeInsets.only(
                                        right: 30,
                                        left: 30
                                    ),
                                    // color: Colors.red,
                                    // clipBehavior: Clip.antiAliasWithSaveLayer,
                                    child: NotificationListener<OverscrollIndicatorNotification>(
                                      onNotification: (overscroll) {
                                        overscroll.disallowIndicator();
                                        return true;
                                      },
                                      child: ListView(
                                        children: [
                                          // Container(
                                          //   padding: EdgeInsets.only(top: 15),
                                          //   child: Row(
                                          //     mainAxisAlignment: MainAxisAlignment.start,
                                          //     children: [
                                          //       Icon(
                                          //         Icons.info_outline,
                                          //         color: Colors.grey[500],
                                          //       ),
                                          //     ],
                                          //   ),
                                          // ),
                                          Center(
                                            child: Container(
                                              padding: EdgeInsets.only(top: 15),
                                              child: Text(
                                                  'Descrizione',
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 1,
                                                  style: TextStyle(
                                                      fontWeight: FontWeight.w700,
                                                      color: Colors.grey[800],
                                                      // color: Colors.green[600],
                                                      // color: Colors.blue[500],
                                                      fontSize: 17
                                                  )
                                              ),
                                            ),
                                          ),
                                          ListView(
                                            shrinkWrap: true,
                                            // mainAxisAlignment: MainAxisAlignment.center,
                                            physics: NeverScrollableScrollPhysics(),
                                            children: [
                                              Center(
                                                child: Container(
                                                  padding: EdgeInsets.only(top: 20,),
                                                  child: Text(
                                                      // (widget.prestazione!.description)!*50 ?? '\n\n\n\n',
                                                      widget.prestazione!.description ?? '\n\n\n\n',
                                                      // overflow: TextOverflow.ellipsis,
                                                      // maxLines: 5,
                                                      textAlign: TextAlign.center,
                                                      style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.grey[600],
                                                          // color: Colors.green[600],
                                                          // color: Colors.blue[500],
                                                          fontSize: 15
                                                      )
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: 20,)
                                        ],
                                      ),
                                    ),
                                  ),
                                )
                              );
                            },
                          );
                        },
                        padding: EdgeInsets.only(right: 10),
                        icon: Icon(
                          Icons.notes,
                          // Icons.sort,
                          color: _isAppBarExpanded ? Colors.grey[500] : Colors.white,
                          // color: Colors./*white*/grey,
                          // color: _scrollController.offset > (200 - kToolbarHeight) ? Colors.white : Colors.grey[500],
                          size: 27,
                        ),
                        color: Colors.black,

                      ),
                    )
                  ],
                  // shape: RoundedRectangleBorder(
                  //   borderRadius: BorderRadius.only(
                  //     bottomLeft: Radius.circular(30.0),
                  //     bottomRight: Radius.circular(30.0),
                  //   ),
                  // ),

                  flexibleSpace: FlexibleSpaceBar(
                    // centerTitle: true,
                    collapseMode: CollapseMode.parallax,
                    // stretchModes: const [
                    //   StretchMode.zoomBackground,
                    // ],
                    background: Container(
                      width: MediaQuery.of(context).size.width,
                      // color: Colors.white,
                      // decoration: BoxDecoration(
                      //   color: Colors.blue,
                      //   borderRadius: BorderRadius.only(
                      //     bottomLeft: Radius.circular(30.0),
                      //     bottomRight: Radius.circular(30.0),
                      //   ),
                      // ),
                      // height: 500,
                      child: Stack(
                        clipBehavior: Clip.antiAliasWithSaveLayer,
                        fit: StackFit.expand,
                        children: [
                          // FutureImage(
                          //   imageUrl: widget.bookingBusiness!.profile_image != null && widget.bookingBusiness!.profile_image != ''
                          //       ? widget.bookingBusiness!.profile_image! : widget.bookingBusiness!.profile_image!,
                          //   cacheBusiness: CacheBusiness(
                          //     Config(
                          //       'customCacheKey',
                          //       stalePeriod: const Duration(days: 7)
                          //     )
                          //   ),
                          //   fit: BoxFit.cover,
                          //   // colorBlendMode: BlendMode.darken,
                          //   // colorBlendMode: BlendMode.hardLight,
                          //   width: MediaQuery.of(context).size.width,
                          //   // filterQuality: FilterQuality.high,
                          //   // placeholder: (context, url) => Center(
                          //   //     child: CircularProgressIndicator()
                          //   // ),
                          //   errorWidget: (context, url, error) => SizedBox(),
                          // ),
                          FutureImage(
                            widget.prestazione!.image != null && widget.prestazione!.image != ''
                                ? widget.prestazione!.image! : widget.prestazione!.business!.profile_image!,
                            width: MediaQuery.of(context).size.width,
                          ),
                          DecoratedBox(
                            decoration: BoxDecoration(
                              //colorFilter: new ColorFilter.mode(Colors.black.withOpacity(0.32), BlendMode.darken),
                              // backgroundBlendMode: BlendMode.darken,
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  Colors.black,
                                  Colors.transparent,
                                ],
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 60,
                          //   left: 20,
                          //   width: MediaQuery.of(context).size.width * 0.8,
                          //   child: Column(
                          //     crossAxisAlignment: CrossAxisAlignment.start,
                          //     children: [
                          //       Marquee(
                          //         child: GradientText(
                          //           widget.prestazione!.title ?? '',
                          //           // 'A partire da € 60,00',
                          //           maxLines: 1,
                          //           // shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                          //           // shaderRect: Rect.fromLTWH(.0, 0.0, 70.0, 0.0),
                          //           // gradient: Gradients.hotLinear,
                          //           gradient: LinearGradient(
                          //               begin: Alignment.bottomLeft,
                          //               end: Alignment.topRight,
                          //               colors: [
                          //                 // Color(0xffDA44bb),
                          //                 // Color(0xffDA44bb),
                          //                 // Color(0xff8921aa),
                          //                 Colors.white,
                          //                 Colors.white,
                          //                 // Colors.blue, Colors.blue,
                          //
                          //               ]
                          //           ),
                          //           // gradient: LinearGradient(
                          //           //     begin: Alignment.bottomLeft,
                          //           //     end: Alignment.topRight,
                          //           //     colors: [
                          //           //       Colors.blue[500],
                          //           //       Color(0xffDA44bb),
                          //           //
                          //           //       Color(0xff8921aa),
                          //           //     ]
                          //           // ),
                          //           style: TextStyle(
                          //             color: Colors.blue,
                          //             fontWeight: FontWeight.w700,
                          //             fontSize: 20,
                          //           ),
                          //           textAlign: TextAlign.left,
                          //         ),
                          //       ),
                          //       // Marquee(
                          //       //   child: GradientText(
                          //       //     widget.prestazione!.description ?? '',
                          //       //     maxLines: 1,
                          //       //     shaderRect: Rect.fromLTWH(50.0, 50.0, 50.0, 50.0),
                          //       //     gradient: Gradients.haze,
                          //       //     style: TextStyle(
                          //       //         color: Colors.white,
                          //       //         fontWeight: FontWeight.w700,
                          //       //         fontSize: 14
                          //       //     ),
                          //       //     textAlign: TextAlign.left,
                          //       //   ),
                          //       // ),
                          //       SizedBox(height: 1,),
                          //     ],
                          //   ),
                          // ),

                          Positioned(
                            bottom: 20,
                            left: 15,
                            width: MediaQuery.of(context).size.width * 0.9,
                            child: Padding(
                              padding: const EdgeInsets.only(left: 0, top: 0),
                              child: Marquee(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Card(
                                      semanticContainer: true,
                                      color: Colors.grey[100],
                                      margin: EdgeInsets.all(0),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      elevation: 0,
                                      // margin: EdgeInsets.all(0),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 3,
                                          bottom: 3,
                                          left: 5,
                                          right: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            ClipRRect(
                                              borderRadius: BorderRadius.circular(50),
                                              child: FutureImage(
                                                // widget.bookingBusiness.profile_image,
                                                // widget.prestazione.business.profile_image,
                                                widget.prestazione!.business!.category!.image!,
                                                width: 18,
                                                height: 18,
                                              ),
                                            ),
                                            SizedBox(width: 5),
                                            RichText(
                                              text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      // text: 'Estetista'/*' "'*/,
                                                        text: widget.prestazione!.business!.category!.name/*' "'*/,
                                                        // text: '€ ' + NumberFormat.currency(
                                                        //   // customPattern: '#,##',
                                                        //   locale: 'IT_it',
                                                        //   decimalDigits: 2,
                                                        //   symbol: '',
                                                        // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                        // ).format(prestazione.price?.toDouble()),
                                                        style: GoogleFonts.roboto(
                                                          fontWeight: FontWeight.w700,
                                                          color: Colors.grey[600],
                                                          // color: Colors.green[600],
                                                          fontSize: 13
                                                        )
                                                    ),
                                                  ]
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    Card(
                                      semanticContainer: true,
                                      color: Colors.grey[100],
                                      margin: EdgeInsets.all(0),
                                      clipBehavior: Clip.antiAliasWithSaveLayer,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(50.0),
                                      ),
                                      elevation: 0,
                                      // margin: EdgeInsets.all(0),
                                      child: Padding(
                                        padding: EdgeInsets.only(
                                          top: 5,
                                          bottom: 5,
                                          left: 8,
                                          right: 8,
                                        ),
                                        child: Row(
                                          children: [
                                            Padding(
                                              padding: const EdgeInsets.only(bottom: 1.0),
                                              child: Icon(
                                                Icons.access_time_outlined,
                                                // Icons.price_change,
                                                // Icons.price_change_outlined,
                                                color: Colors.grey[600],
                                                size: 15,
                                              ),
                                            ),
                                            SizedBox(width: 3),
                                            RichText(
                                              text: TextSpan(
                                                  children: <TextSpan>[
                                                    TextSpan(
                                                      //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                                        text: widget.prestazione!.duration.toString() + ' minuti'/*' "'*/,
                                                        // text: '€ ' + NumberFormat.currency(
                                                        //   // customPattern: '#,##',
                                                        //   locale: 'IT_it',
                                                        //   decimalDigits: 2,
                                                        //   symbol: '',
                                                        // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                                        // ).format(prestazione.price?.toDouble()),
                                                        style: GoogleFonts.roboto(
                                                            fontWeight: FontWeight.w700,
                                                            color: Colors.grey[600],
                                                            // color: Colors.green[600],
                                                            fontSize: 13
                                                        )
                                                    ),
                                                  ]
                                              ),
                                            ),
                                            SizedBox(width: 2,)
                                          ],
                                        ),
                                      ),
                                    ),
                                    // (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder<Object>(
                                    //     future: e,
                                    //     builder: (context, snapshot) {
                                    //       if(snapshot.connectionState == ConnectionState.done){
                                    //         return Card(
                                    //           semanticContainer: true,
                                    //           color: Colors.grey[100],
                                    //           margin: EdgeInsets.only(left: 10),
                                    //           clipBehavior: Clip.antiAliasWithSaveLayer,
                                    //           shape: RoundedRectangleBorder(
                                    //             borderRadius: BorderRadius.circular(50.0),
                                    //           ),
                                    //           elevation: 0,
                                    //           // margin: EdgeInsets.all(0),
                                    //           child: Padding(
                                    //             padding: EdgeInsets.only(
                                    //               top: 5,
                                    //               bottom: 5,
                                    //               left: 6,
                                    //               right: 6,
                                    //             ),
                                    //             child: Row(
                                    //               children: [
                                    //                 Padding(
                                    //                   padding: const EdgeInsets.only(bottom: 0.0),
                                    //                   child: Icon(
                                    //                     Icons.pin_drop_outlined,
                                    //                     // Icons.price_change_outlined,
                                    //                     color: Colors.grey[600],
                                    //                     size: 15,
                                    //                   ),
                                    //                 ),
                                    //                 SizedBox(width: 3),
                                    //                 RichText(
                                    //                   text: TextSpan(
                                    //                       children: <TextSpan>[
                                    //                         TextSpan(
                                    //                           //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                    //                           //   text: prestazione.duration.toString() + ' minuti',
                                    //                             text: NumberFormat.currency(
                                    //                               // customPattern: '#,##',
                                    //                                 decimalDigits: 2,
                                    //                                 symbol: '',
                                    //                                 locale: 'IT_it'
                                    //                             // ).format(Geolocator.distanceBetween(
                                    //                             //   // 52.2165957, 6.9437819, 52.3546274, 4.8285838
                                    //                             //   // 45.4281857, 9.1531147, 45.44131, 9.14952
                                    //                             //   // 45.4281857, 9.1531147, 45.464521158381, 9.148603646381646
                                    //                             //     geolocationProvider.position.latitude, geolocationProvider.position.longitude,
                                    //                             //     widget.prestazione.business.latitude, widget.prestazione.business.longitude
                                    //                             // )/1000) + 'km',
                                    //                             ).format(getDistance()/1000) + 'km',
                                    //                             style: GoogleFonts.roboto(
                                    //                                 fontWeight: FontWeight.w700,
                                    //                                 color: Colors.grey[600],
                                    //                                 // color: Colors.green[600],
                                    //                                 // color: Colors.blue[500],
                                    //                                 fontSize: 12
                                    //                             )
                                    //                         ),
                                    //                       ]
                                    //                   ),
                                    //                 ),
                                    //               ],
                                    //             ),
                                    //           ),
                                    //         );
                                    //       }
                                    //       else {
                                    //         return SizedBox();
                                    //       }
                                    //     }
                                    // ) : SizedBox(),
                                    // SizedBox(width: 10,),
                                    /**/
                                    // SizedBox(width: 10,),
                                    // Card(
                                    //   semanticContainer: true,
                                    //   color: Colors.grey[100],
                                    //   // color: Colors.green[100],
                                    //   margin: EdgeInsets.all(0),
                                    //   clipBehavior: Clip.antiAliasWithSaveLayer,
                                    //   shape: RoundedRectangleBorder(
                                    //     borderRadius: BorderRadius.circular(50.0),
                                    //   ),
                                    //   elevation: 0,
                                    //   // margin: EdgeInsets.all(0),
                                    //   child: Padding(
                                    //     padding: EdgeInsets.only(
                                    //       top: 5,
                                    //       bottom: 5,
                                    //       left: 8,
                                    //       right: 8,
                                    //     ),
                                    //     child: Row(
                                    //       children: [
                                    //         Padding(
                                    //           padding: const EdgeInsets.only(bottom: 0.0),
                                    //           child: Icon(
                                    //             // Icons.price_change,
                                    //             // Icons.price_change_outlined,
                                    //             // Icons.euro,
                                    //             Icons.sell,
                                    //             // Icons.payment,
                                    //             // color: Colors.grey[600],
                                    //             // color: Colors.green[800],
                                    //             color: Colors.blue[500],
                                    //             size: 18,
                                    //           ),
                                    //         ),
                                    //         SizedBox(width: 3),
                                    //         RichText(
                                    //           text: TextSpan(
                                    //               children: <TextSpan>[
                                    //                 TextSpan(
                                    //                   //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                    //                   //   text: prestazione.duration.toString() + ' minuti',
                                    //                     text: '€',
                                    //                     style: GoogleFonts.roboto(
                                    //                         fontWeight: FontWeight.w700,
                                    //                         // color: Colors.grey[600],
                                    //                         // color: Colors.green[800],
                                    //                         color: Colors.blue[500],
                                    //                         fontSize: 17
                                    //                     )
                                    //                 ),
                                    //               ]
                                    //           ),
                                    //         ),
                                    //         SizedBox(width: 3),
                                    //         RichText(
                                    //           text: TextSpan(
                                    //               children: <TextSpan>[
                                    //                 TextSpan(
                                    //                   //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                                    //                   //   text: prestazione.duration.toString() + ' minuti',
                                    //                     text: NumberFormat.currency(
                                    //                       // customPattern: '#,##',
                                    //                       locale: 'IT_it',
                                    //                       decimalDigits: 2,
                                    //                       symbol: '',
                                    //                       // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                                    //                     ).format(widget.prestazione!.price?.toDouble()),
                                    //                     style: GoogleFonts.roboto(
                                    //                         fontWeight: FontWeight.w700,
                                    //                         // color: Colors.grey[600],
                                    //                         // color: Colors.green[800],
                                    //                         color: Colors.blue[500],
                                    //                         fontSize: 15
                                    //                     )
                                    //                 ),
                                    //               ]
                                    //           ),
                                    //         ),
                                    //       ],
                                    //     ),
                                    //   ),
                                    // ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          // Positioned(
                          //   bottom: 20,
                          //   left: 15,
                          //   width: MediaQuery.of(context).size.width * 0.8,
                          //   child: Row(
                          //     children: [
                          //       Card(
                          //         semanticContainer: true,
                          //         color: Colors.grey[100],
                          //         margin: EdgeInsets.all(0),
                          //         clipBehavior: Clip.antiAliasWithSaveLayer,
                          //         shape: RoundedRectangleBorder(
                          //           borderRadius: BorderRadius.circular(50.0),
                          //         ),
                          //         elevation: 0,
                          //         // margin: EdgeInsets.all(0),
                          //         child: Padding(
                          //           padding: EdgeInsets.only(
                          //             top: 3,
                          //             bottom: 3,
                          //             left: 5,
                          //             right: 8,
                          //           ),
                          //           child: Row(
                          //             children: [
                          //               ClipRRect(
                          //                 borderRadius: BorderRadius.circular(50),
                          //                 child: FutureImage(
                          //                   // widget.bookingBusiness.profile_image,
                          //                   // widget.prestazione.business.profile_image,
                          //                   widget.prestazione!.business!.category!.image!,
                          //                   // "https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                          //                   width: 20,
                          //                   height: 20,
                          //                 ),
                          //               ),
                          //               SizedBox(width: 5),
                          //               RichText(
                          //                 text: TextSpan(
                          //                     children: <TextSpan>[
                          //                       TextSpan(
                          //                         // text: 'Estetista'/*' "'*/,
                          //                           text: widget.prestazione!.business!.category!.name,
                          //                           // text: '€ ' + NumberFormat.currency(
                          //                           //   // customPattern: '#,##',
                          //                           //   locale: 'IT_it',
                          //                           //   decimalDigits: 2,
                          //                           //   symbol: '',
                          //                           // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                          //                           // ).format(prestazione.price?.toDouble()),
                          //                           style: GoogleFonts.roboto(
                          //                               fontWeight: FontWeight.w700,
                          //                               color: Colors.grey[600],
                          //                               // color: Colors.green[600],
                          //                               fontSize: 12
                          //                           )
                          //                       ),
                          //                     ]
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          //         ),
                          //       ),
                          //       /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? FutureBuilder/*<Object>*/(
                          //           future: a/*!.then((value) => value as Object)*/,
                          //           builder: (context, snapshot) {
                          //             if(snapshot.connectionState == ConnectionState.done){
                          //               return Card(
                          //                 semanticContainer: true,
                          //                 color: Colors.grey[100],
                          //                 margin: EdgeInsets.only(left: 10),
                          //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                          //                 shape: RoundedRectangleBorder(
                          //                   borderRadius: BorderRadius.circular(50.0),
                          //                 ),
                          //                 elevation: 0,
                          //                 // margin: EdgeInsets.all(0),
                          //                 child: Padding(
                          //                   padding: EdgeInsets.only(
                          //                     top: 5,
                          //                     bottom: 5,
                          //                     left: 7,
                          //                     right: 7,
                          //                   ),
                          //                   child: Row(
                          //                     children: [
                          //                       Padding(
                          //                         padding: const EdgeInsets.only(bottom: 0.0),
                          //                         child: Icon(
                          //                           Icons.pin_drop_outlined,
                          //                           // Icons.price_change_outlined,
                          //                           color: Colors.grey[600],
                          //                           size: 15,
                          //                         ),
                          //                       ),
                          //                       SizedBox(width: 3),
                          //                       RichText(
                          //                         text: TextSpan(
                          //                             children: <TextSpan>[
                          //                               TextSpan(
                          //                                 //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                          //                                 //   text: prestazione.duration.toString() + ' minuti',
                          //                                   text: NumberFormat.currency(
                          //                                     // customPattern: '#,##',
                          //                                       decimalDigits: 2,
                          //                                       symbol: '',
                          //                                       locale: 'IT_it'
                          //                                     // ).format((distanceInMeters/1000)) + ' km',
                          //                                   ).format((getDistance()!/1000)) + ' km',
                          //                                   style: GoogleFonts.roboto(
                          //                                       fontWeight: FontWeight.w700,
                          //                                       color: Colors.grey[600],
                          //                                       // color: Colors.green[600],
                          //                                       // color: Colors.blue[500],
                          //                                       fontSize: 12
                          //                                   )
                          //                               ),
                          //                             ]
                          //                         ),
                          //                       ),
                          //                     ],
                          //                   ),
                          //                 ),
                          //               );
                          //             }
                          //             else return SizedBox();
                          //           }
                          //       ) : SizedBox(),
                          //     ],
                          //   ),
                          // ),

                          Visibility(
                            // visible: !Utils.isBusiness,
                            visible: true,
                            child: Positioned(
                              bottom: 20,
                              right: 15,
                              width: MediaQuery.of(context).size.width * 0.8,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Visibility(
                                    visible: false,
                                    child: InkWell(
                                      highlightColor: Colors.transparent,
                                      splashColor: Colors.transparent,
                                      onTap: (){
                                        // LaunchReview.launch(
                                        //   androidAppId: "com.nurebo.nurebo",
                                        //   // iOSAppId: "585027354",
                                        //   writeReview: false,
                                        // );
                                      },
                                      child: Padding(
                                        padding: const EdgeInsets.only(right: 15, left: 5),
                                        child: Container(
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white
                                          ),
                                          child: Icon(
                                            Icons.download,
                                            color: Colors.grey[700],
                                            // color: Colors.green[700],
                                            // color: Colors.white,
                                            // color: _theme,
                                            // color: Colors.blue,
                                            // color: Colors.red[600],
                                            // color: Colors.blue[500],
                                            size: 23,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  FutureBuilder<Object?>(
                                  // future: Future.wait([d]),
                                    future: d,
                                    builder: (context, snapshot) {
                                      if(snapshot.connectionState != ConnectionState.done){
                                        return SizedBox();
                                      }
                                      else {
                                        return InkWell(
                                          highlightColor: Colors.transparent,
                                          splashColor: Colors.transparent,
                                          onTap: () async {
                                            if(UserPreferences.getIsLogged()!){
                                              if (isLikedPost){
                                                // setState(() {
                                                await /*postProvider.*/unlikePrestazione(
                                                  // postProvider.businessPostList[i].id,
                                                  // widget.user.id
                                                ).then((value) {
                                                  if(value >= 200 && value < 400){
                                                    //todo: cercarlo in myprestazione in favorite provider ed eliminarlo al posto di fare questa get
                                                    favoriteProvider.getUserPrestazioneFavorites(userProvider.user!);

                                                    // Fluttertoast.showToast(
                                                    //   msg: 'Rimosso dai Preferiti',
                                                    //   backgroundColor: Colors.grey[700],
                                                    // );
                                                    final SnackBar snackBar = SnackBar(
                                                      content: Text(
                                                        'Rimosso dai Preferiti',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor: Colors.red,
                                                    );
                                                    snackbarKey.currentState?.showSnackBar(snackBar);
                                                  }
                                                });
                                                // });
                                              }
                                              else{
                                                // setState(() {
                                                await /*postProvider.*/likePrestazione(
                                                  // postProvider.businessPostList[i].id,
                                                  // widget.user.id
                                                ).then((value) {
                                                  if(value >= 200 && value < 400){
                                                    //todo: inserirlo in myprestazione in favorite provider al posto di fare questa get
                                                    favoriteProvider.getUserPrestazioneFavorites(userProvider.user!);
                                                    // Fluttertoast.showToast(
                                                    //   msg: 'Aggiunto ai Preferiti',
                                                    //   backgroundColor: Colors.grey[700],
                                                    // );
                                                    final SnackBar snackBar = SnackBar(
                                                      content: Text(
                                                        'Aggiunto ai Preferiti',
                                                        style: TextStyle(
                                                          fontWeight: FontWeight.w600,
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                      backgroundColor: Colors.green,
                                                    );
                                                    snackbarKey.currentState?.showSnackBar(snackBar);
                                                  }
                                                });
                                                // });
                                              }
                                            }
                                            else{
                                              Fluttertoast.showToast(
                                                msg: 'Accedi per aggiungere ai preferiti',
                                                backgroundColor: Colors.grey[700],
                                              );
                                            }

                                          },
                                          child: Padding(
                                            padding: const EdgeInsets.only(right: /*15*/5, left: 5),
                                            child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Colors.white
                                            ),
                                            child: Padding(
                                              padding: const EdgeInsets.only(right: /*15*/0, left: 0),
                                              child: Icon(
                                                // isLikedPost == true
                                                //     ? Icons.favorite
                                                //     : Icons.favorite_border_outlined,
                                                isLikedPost == true
                                                    ? Icons.star
                                                    : Icons.star_outline,
                                                // color: Colors.grey[600],
                                                color: Colors.yellow[800],
                                                // color: Colors.blue[500],
                                                size: 30,
                                              ),
                                            ),
                                          ),
                                          )
                                        );
                                      }
                                    }
                                  ),
                                ],
                              ),
                            ),
                          ),

                          Visibility(
                            visible: isDateTableVisible,
                            child: InkWell(
                              splashColor: Colors.transparent,
                              highlightColor: Colors.transparent,
                              onTap: (){
                                if(isDateTableVisible){
                                  setState(() {
                                    isDateTableVisible = !isDateTableVisible;
                                  });
                                }
                              },
                              child: Container(
                                height: MediaQuery.of(context).size.height,
                                width: MediaQuery.of(context).size.width,
                                // decoration: BoxDecoration(
                                //   borderRadius: BorderRadius.circular(5),
                                //   backgroundBlendMode: BlendMode.darken,
                                //   color: Colors.black.withOpacity(0.15),
                                //   boxShadow: [
                                //     BoxShadow(
                                //       color: Colors.grey[400].withOpacity(0.2),
                                //       spreadRadius: 0.5,
                                //       blurRadius: 1,
                                //       offset: Offset(5, 5), // changes position of shadow
                                //     ),
                                //   ],
                                // ),
                              ),
                            ),
                          ),

                          // Positioned(
                          //   bottom: 10,
                          //   right: 10,
                          //   // width: MediaQuery.of(context).size.width * 0.8,
                          //   child: Stack(
                          //     children: [
                          //       Container(
                          //         height: MediaQuery.of(context).size.height * 0.1,
                          //         width: MediaQuery.of(context).size.width * 0.35,
                          //         child: Card(
                          //           elevation: 2,
                          //           clipBehavior: Clip.antiAliasWithSaveLayer,
                          //           child: FutureBuilder<Object>(
                          //               future: a,
                          //               builder: (context, snapshot) {
                          //                 if(snapshot.connectionState == ConnectionState.done){
                          //                   return FlutterMap(
                          //                     options: MapOptions(
                          //                       // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                       // center: LatLng(45.4281857,9.1531147),
                          //                       // center: LatLng(45.44145125443612, 9.140500655351495),
                          //                       // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                          //                       center: /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse)
                          //                           ? LatLng((geolocationProvider.position.latitude + widget.bookingBusiness.latitude)/2, (geolocationProvider.position.longitude + widget.bookingBusiness.longitude)/2)
                          //                           : LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                       // zoom: 15.0,
                          //                       zoom: 8.8,
                          //                       // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                          //                       // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                          //                       // zoom: widget.bookingBusiness.longitude,
                          //                       // zoom: distanceInMeters / 1000 * 5,
                          //                       // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                          //                       onTap: (tapPosition, latLng) async {
                          //                         if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                          //                           bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                          //
                          //                           if (f != null) {
                          //                             await map_launcher.MapLauncher.showDirections(
                          //                               destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                               // destinationTitle: destinationTitle,
                          //                               origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                          //                               originTitle: 'originTitle',
                          //                               // waypoints: waypoints,
                          //                               directionsMode: map_launcher.DirectionsMode.driving,
                          //                               mapType: map_launcher.MapType.google,
                          //                             );
                          //                           }
                          //                         }
                          //                         else{
                          //                           await MapsLauncher.launchQuery(
                          //                             // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                          //                             // 'via cascina bianca, 6, milano, 20142, italia'
                          //                             // 'Via Privata Parenzo, 8, 20143 Milano MI'
                          //                             // 'Via Privata Parenzo, 8, Estetica Elixir'
                          //                             // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                          //                             // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                          //                             //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                          //                               widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                          //                           );
                          //                         }
                          //
                          //                       },
                          //                     ),
                          //                     layers: [
                          //                       TileLayerOptions(
                          //                         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          //                         subdomains: ['a', 'b', 'c'],
                          //                       ),
                          //                       MarkerLayerOptions(
                          //                         markers: [
                          //                           // Marker(
                          //                           //   width: 60.0,
                          //                           //   height: 60.0,
                          //                           //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                           //   builder: (ctx) => Container(
                          //                           //     // child: FlutterLogo(),
                          //                           //     child: Image.asset("assets/user_location_pin.png"),
                          //                           //   ),
                          //                           // ),
                          //
                          //                           /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                          //                               width: 45.0,
                          //                               height: 45.0,
                          //                               // point: new LatLng(40.73, -74.00),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               // point: LatLng(45.44131,9.14952),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               point: LatLng(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                          //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                               builder: (context) => Material(
                          //                                 type: MaterialType.transparency,
                          //                                 child: IconButton(
                          //                                   icon: Icon(Icons.person),
                          //                                   color: Colors.black,
                          //                                   iconSize: 20.0,
                          //
                          //                                   onPressed: () async {
                          //                                     // //print('Marker tapped');
                          //
                          //                                     // MapsSheet.show(
                          //                                     //   context: context,
                          //                                     //   onMapTap: (map) async {
                          //                                     //     await map.showDirections(
                          //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                          //                                     //       // destinationTitle: destinationTitle,
                          //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                          //                                     //       originTitle: 'originTitle',
                          //                                     //       // waypoints: waypoints,
                          //                                     //       directionsMode: mmm.DirectionsMode.driving,
                          //                                     //     );
                          //                                     //   },
                          //                                     // );
                          //
                          //                                     if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                          //                                       bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                          //
                          //                                       if (f != null) {
                          //                                         await map_launcher.MapLauncher.showDirections(
                          //                                           destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                                           // destinationTitle: destinationTitle,
                          //                                           origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                          //                                           originTitle: 'originTitle',
                          //                                           // waypoints: waypoints,
                          //                                           directionsMode: map_launcher.DirectionsMode.driving,
                          //                                           mapType: map_launcher.MapType.google,
                          //                                         );
                          //                                       }
                          //                                     }
                          //                                     else{
                          //                                       await MapsLauncher.launchQuery(
                          //                                         // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                          //                                         // 'via cascina bianca, 6, milano, 20142, italia'
                          //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI'
                          //                                         // 'Via Privata Parenzo, 8, Estetica Elixir'
                          //                                         // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                          //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                          //                                         //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                          //                                           widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                          //                                       );
                          //                                     }
                          //                                   },
                          //                                 ),
                          //                               )
                          //                           ) : Marker(),
                          //                           Marker(
                          //                               width: 45.0,
                          //                               height: 45.0,
                          //                               // point: new LatLng(40.73, -74.00),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               // point: LatLng(45.44131,9.14952),
                          //                               // point: LatLng(45.44145125443612, 9.140500655351495),
                          //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                               builder: (context) => Material(
                          //                                 type: MaterialType.transparency,
                          //                                 child: IconButton(
                          //                                   icon: Icon(Icons.location_on),
                          //                                   color: Colors.red,
                          //                                   iconSize: 20.0,
                          //                                   onPressed: () async {
                          //                                     // //print('Marker tapped');
                          //
                          //                                     // MapsSheet.show(
                          //                                     //   context: context,
                          //                                     //   onMapTap: (map) async {
                          //                                     //     await map.showDirections(
                          //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                          //                                     //       // destinationTitle: destinationTitle,
                          //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                          //                                     //       originTitle: 'originTitle',
                          //                                     //       // waypoints: waypoints,
                          //                                     //       directionsMode: mmm.DirectionsMode.driving,
                          //                                     //     );
                          //                                     //   },
                          //                                     // );
                          //
                          //                                     if(geolocationProvider.locationPermission == LocationPermission.whileInUse || geolocationProvider.locationPermission == LocationPermission.always){
                          //                                       bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                          //
                          //                                       if (f != null) {
                          //                                         await map_launcher.MapLauncher.showDirections(
                          //                                           destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                                           // destinationTitle: destinationTitle,
                          //                                           origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                          //                                           originTitle: 'originTitle',
                          //                                           // waypoints: waypoints,
                          //                                           directionsMode: map_launcher.DirectionsMode.driving,
                          //                                           mapType: map_launcher.MapType.google,
                          //                                         );
                          //                                       }
                          //                                     }
                          //                                     else{
                          //                                       await MapsLauncher.launchQuery(
                          //                                         // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                          //                                         // 'via cascina bianca, 6, milano, 20142, italia'
                          //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI'
                          //                                         // 'Via Privata Parenzo, 8, Estetica Elixir'
                          //                                         // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                          //                                         // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                          //                                         //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                          //                                           widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                          //                                       );
                          //                                     }
                          //                                   },
                          //                                 ),
                          //                               )
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   );
                          //                 }
                          //                 else{
                          //                   return FlutterMap(
                          //                     options: MapOptions(
                          //                       // center: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                       // center: LatLng(45.4281857,9.1531147),
                          //                       // center: LatLng(45.44145125443612, 9.140500655351495),
                          //                       // center: LatLng((45.44145125443612+45.4281857)/2, (9.140500655351495+9.1531147)/2),
                          //                       center: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                       // zoom: 15.0,
                          //                       zoom: 8.8,
                          //                       // zoom: double.parse((getDistance()?.toDouble() * 1.0).toString()),
                          //                       // zoom: double.parse((distanceInMeters?.toDouble() * 1.0).toString()),
                          //                       // zoom: widget.bookingBusiness.longitude,
                          //                       // zoom: distanceInMeters / 1000 * 5,
                          //                       // zoom: ((getDistance()/1000.0) * 1500.0)?.toDouble(),
                          //                       onTap: (tapPosition, latLng) async {
                          //                         // //print('ciao');
                          //                         await MapsLauncher.launchQuery(
                          //                           // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                          //                           // 'via cascina bianca, 6, milano, 20142, italia'
                          //                           // 'Via Privata Parenzo, 8, 20143 Milano MI'
                          //                           // 'Via Privata Parenzo, 8, Estetica Elixir'
                          //                           // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                          //                           // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                          //                           //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                          //                             widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                          //                         );
                          //                       },
                          //                     ),
                          //                     layers: [
                          //                       TileLayerOptions(
                          //                         urlTemplate: "https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png",
                          //                         subdomains: ['a', 'b', 'c'],
                          //                       ),
                          //                       MarkerLayerOptions(
                          //                         markers: [
                          //                           // Marker(
                          //                           //   width: 60.0,
                          //                           //   height: 60.0,
                          //                           //   point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                           //   builder: (ctx) => Container(
                          //                           //     // child: FlutterLogo(),
                          //                           //     child: Image.asset("assets/user_location_pin.png"),
                          //                           //   ),
                          //                           // ),
                          //
                          //                           /*UserPreferences.getIsLogged() &&*/ (geolocationProvider.locationPermission == LocationPermission.always || geolocationProvider.locationPermission == LocationPermission.whileInUse) ? Marker(
                          //                               width: 45.0,
                          //                               height: 45.0,
                          //                               // point: new LatLng(40.73, -74.00),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               // point: LatLng(45.44131,9.14952),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                               builder: (context) => Material(
                          //                                 type: MaterialType.transparency,
                          //                                 child: IconButton(
                          //                                   icon: Icon(Icons.person),
                          //                                   color: Colors.blue,
                          //                                   iconSize: 20.0,
                          //
                          //                                   onPressed: () async {
                          //                                     // //print('Marker tapped');
                          //
                          //                                     // MapsSheet.show(
                          //                                     //   context: context,
                          //                                     //   onMapTap: (map) async {
                          //                                     //     await map.showDirections(
                          //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                          //                                     //       // destinationTitle: destinationTitle,
                          //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                          //                                     //       originTitle: 'originTitle',
                          //                                     //       // waypoints: waypoints,
                          //                                     //       directionsMode: mmm.DirectionsMode.driving,
                          //                                     //     );
                          //                                     //   },
                          //                                     // );
                          //
                          //                                     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                          //
                          //                                     if (f != null) {
                          //                                       await map_launcher.MapLauncher.showDirections(
                          //                                         destination: map_launcher.Coords(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                                         // destinationTitle: destinationTitle,
                          //                                         origin: map_launcher.Coords(geolocationProvider.position.latitude, geolocationProvider.position.longitude),
                          //                                         originTitle: 'originTitle',
                          //                                         // waypoints: waypoints,
                          //                                         directionsMode: map_launcher.DirectionsMode.driving,
                          //                                         mapType: map_launcher.MapType.google,
                          //                                       );
                          //                                     }
                          //                                   },
                          //                                 ),
                          //                               )
                          //                           ) : Marker(),
                          //                           Marker(
                          //                               width: 45.0,
                          //                               height: 45.0,
                          //                               // point: new LatLng(40.73, -74.00),
                          //                               // point: LatLng(45.4281857,9.1531147),
                          //                               // point: LatLng(45.44131,9.14952),
                          //                               // point: LatLng(45.44145125443612, 9.140500655351495),
                          //                               point: LatLng(widget.bookingBusiness.latitude, widget.bookingBusiness.longitude),
                          //                               // point: LatLng(userCurrentPosition.latitude, userCurrentPosition.longitude),
                          //                               builder: (context) => Material(
                          //                                 type: MaterialType.transparency,
                          //                                 child: IconButton(
                          //                                   icon: Icon(Icons.location_on),
                          //                                   color: Colors.red,
                          //                                   iconSize: 20.0,
                          //
                          //                                   onPressed: () async {
                          //                                     // //print('Marker tapped');
                          //
                          //                                     // MapsSheet.show(
                          //                                     //   context: context,
                          //                                     //   onMapTap: (map) async {
                          //                                     //     await map.showDirections(
                          //                                     //       destination: mmm.Coords(45.44145125443612, 9.140500655351495),
                          //                                     //       // destinationTitle: destinationTitle,
                          //                                     //       origin: mmm.Coords(45.4281857, 9.1531147),
                          //                                     //       originTitle: 'originTitle',
                          //                                     //       // waypoints: waypoints,
                          //                                     //       directionsMode: mmm.DirectionsMode.driving,
                          //                                     //     );
                          //                                     //   },
                          //                                     // );
                          //
                          //                                     bool f = await map_launcher.MapLauncher.isMapAvailable(map_launcher.MapType.google);
                          //
                          //                                     if (f != null) {
                          //                                       await map_launcher.MapLauncher.showDirections(
                          //                                         destination: map_launcher.Coords(45.44145125443612, 9.140500655351495),
                          //                                         // destinationTitle: destinationTitle,
                          //                                         origin: map_launcher.Coords(45.4281857, 9.1531147),
                          //                                         originTitle: 'originTitle',
                          //                                         // waypoints: waypoints,
                          //                                         directionsMode: map_launcher.DirectionsMode.driving,
                          //                                         mapType: map_launcher.MapType.google,
                          //                                       );
                          //                                     }
                          //                                   },
                          //                                 ),
                          //                               )
                          //                           ),
                          //                         ],
                          //                       ),
                          //                     ],
                          //                   );
                          //                 }
                          //               }
                          //           ),
                          //         ),
                          //       ),
                          //
                          //       // InkWell(
                          //       //   onTap: () async {
                          //       //     await MapsLauncher.launchQuery(
                          //       //       // '1600 Amphitheatre Pkwy, Mountain View, CA 94043, USA'
                          //       //       // 'via cascina bianca, 6, milano, 20142, italia'
                          //       //       // 'Via Privata Parenzo, 8, 20143 Milano MI'
                          //       //       // 'Via Privata Parenzo, 8, Estetica Elixir'
                          //       //       // 'Via Ambrogio Binda, 25, 20143, Milano, MI'
                          //       //       // 'Via Privata Parenzo, 8, 20143 Milano MI Estetica Elixir'
                          //       //       //   'Via Ambrogio Binda, 25, 20143, Milano, MI, DS Parrucchiere'
                          //       //         widget.bookingBusiness.address + ', ' + widget.bookingBusiness.name
                          //       //     );
                          //       //   },
                          //       //   child: Container(
                          //       //     height: MediaQuery.of(context).size.height * 0.25,
                          //       //     width: MediaQuery.of(context).size.width * 0.75,
                          //       //     // color: Colors.blue,
                          //       //     color: Colors.transparent,
                          //       //   ),
                          //       // ),
                          //     ],
                          //   ),
                          // ),
                        ],
                      ),
                    ),
                    // background: FutureBuilder<Object>(
                    //   future: ab,
                    //   builder: (context, snapshot) {
                    //     if(snapshot.connectionState == ConnectionState.done) {
                    //       return Stack(
                    //         children: [
                    //           CarouselSlider(
                    //             carouselController: CarouselController(),
                    //             items: bestsellersList.map((item) {
                    //               // //print('item.prestazione.toJson()');
                    //               // //print(item.prestazione.toJson());
                    //               return Stack(
                    //                 clipBehavior: Clip.antiAliasWithSaveLayer,
                    //                 fit: StackFit.expand,
                    //                 children: [
                    //                   FutureImage(
                    //                     imageUrl: item.image != null &&
                    //                         item.image != ''
                    //                         ? item.image : item.business
                    //                         .profile_image,
                    //                     fit: BoxFit.cover,
                    //                     // colorBlendMode: BlendMode.hardLight,
                    //                     width: MediaQuery
                    //                         .of(context)
                    //                         .size
                    //                         .width,
                    //                     height: MediaQuery
                    //                         .of(context)
                    //                         .size
                    //                         .height * 0.33,
                    //                     // filterQuality: FilterQuality.high,
                    //                     // placeholder: (context, url) => Center(
                    //                     //     child: CircularProgressIndicator()
                    //                     // ),
                    //                     errorWidget: (context, url, error) =>
                    //                         SizedBox(),
                    //                   ),
                    //                   DecoratedBox(
                    //                     decoration: BoxDecoration(
                    //                       // backgroundBlendMode: BlendMode.darken,
                    //                       gradient: LinearGradient(
                    //                         begin: Alignment.bottomLeft,
                    //                         end: Alignment.topRight,
                    //                         colors: [
                    //                           Colors.black,
                    //                           // Colors.transparent,
                    //                           Colors.transparent,
                    //                         ],
                    //                       ),
                    //                     ),
                    //                   ),
                    //                 ],
                    //               );
                    //             }).toList(),
                    //             options: CarouselOptions(
                    //                 enlargeCenterPage: false,
                    //                 height: MediaQuery
                    //                     .of(context)
                    //                     .size
                    //                     .height * 0.38,
                    //                 viewportFraction: 1,
                    //                 autoPlay: true,
                    //                 // aspectRatio: 16/9,
                    //                 autoPlayCurve: Curves.easeInOut,
                    //                 onPageChanged: (i, bho) {
                    //                   // setState(() {
                    //                   //   // _current = bho.index;
                    //                   //   _eventsPageController.jumpToPage(bho.index);
                    //                   // });
                    //                 }
                    //             ),
                    //           ),
                    //           Positioned(
                    //             bottom: 20,
                    //             left: 15,
                    //             width: MediaQuery
                    //                 .of(context)
                    //                 .size
                    //                 .width * 0.8,
                    //             child: Row(
                    //               children: [
                    //                 Card(
                    //                   semanticContainer: true,
                    //                   color: Colors.grey[100],
                    //                   margin: EdgeInsets.all(0),
                    //                   clipBehavior: Clip.antiAliasWithSaveLayer,
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(50.0),
                    //                   ),
                    //                   elevation: 0,
                    //                   // margin: EdgeInsets.all(0),
                    //                   child: Padding(
                    //                     padding: EdgeInsets.only(
                    //                       top: 3,
                    //                       bottom: 3,
                    //                       left: 5,
                    //                       right: 8,
                    //                     ),
                    //                     child: Row(
                    //                       children: [
                    //                         ClipRRect(
                    //                           borderRadius: BorderRadius.circular(
                    //                               50),
                    //                           child: Image(
                    //                             image: CachedNetworkImageProvider(
                    //                               // widget.bookingBusiness.profile_image,
                    //                               // widget.prestazione.business.profile_image,
                    //                               widget.bookingBusiness.category
                    //                                   .image,
                    //                               errorListener: () => SizedBox(),
                    //                               // "https://images.pexels.com/photos/6476116/pexels-photo-6476116.jpeg?auto=compress&cs=tinysrgb&dpr=1&w=500",
                    //                             ),
                    //                             width: 20,
                    //                             height: 20,
                    //                             fit: BoxFit.cover,
                    //                           ),
                    //                         ),
                    //                         SizedBox(width: 5),
                    //                         RichText(
                    //                           text: TextSpan(
                    //                               children: <TextSpan>[
                    //                                 TextSpan(
                    //                                   // text: 'Estetista'/*' "'*/,
                    //                                     text: widget.bookingBusiness
                    //                                         .category.name,
                    //                                     // text: '€ ' + NumberFormat.currency(
                    //                                     //   // customPattern: '#,##',
                    //                                     //   locale: 'IT_it',
                    //                                     //   decimalDigits: 2,
                    //                                     //   symbol: '',
                    //                                     // // ).format(bookingBusinessPrestazioni[index]['price']?.toDouble()),
                    //                                     // ).format(prestazione.price?.toDouble()),
                    //                                     style: GoogleFonts.roboto(
                    //                                         fontWeight: FontWeight
                    //                                             .w700,
                    //                                         color: Colors.grey[600],
                    //                                         // color: Colors.green[600],
                    //                                         fontSize: 12
                    //                                     )
                    //                                 ),
                    //                               ]
                    //                           ),
                    //                         ),
                    //                       ],
                    //                     ),
                    //                   ),
                    //                 ),
                    //                 /*UserPreferences.getIsLogged() &&*/
                    //                 (geolocationProvider.locationPermission ==
                    //                     LocationPermission.always ||
                    //                     geolocationProvider.locationPermission ==
                    //                         LocationPermission.whileInUse)
                    //                     ? FutureBuilder<Object>(
                    //                     future: a,
                    //                     builder: (context, snapshot) {
                    //                       if (snapshot.connectionState ==
                    //                           ConnectionState.done) {
                    //                         return Card(
                    //                           semanticContainer: true,
                    //                           color: Colors.grey[100],
                    //                           margin: EdgeInsets.only(left: 10),
                    //                           clipBehavior: Clip
                    //                               .antiAliasWithSaveLayer,
                    //                           shape: RoundedRectangleBorder(
                    //                             borderRadius: BorderRadius.circular(
                    //                                 50.0),
                    //                           ),
                    //                           elevation: 0,
                    //                           // margin: EdgeInsets.all(0),
                    //                           child: Padding(
                    //                             padding: EdgeInsets.only(
                    //                               top: 5,
                    //                               bottom: 5,
                    //                               left: 7,
                    //                               right: 7,
                    //                             ),
                    //                             child: Row(
                    //                               children: [
                    //                                 Padding(
                    //                                   padding: const EdgeInsets
                    //                                       .only(bottom: 0.0),
                    //                                   child: Icon(
                    //                                     Icons.pin_drop_outlined,
                    //                                     // Icons.price_change_outlined,
                    //                                     color: Colors.grey[600],
                    //                                     size: 15,
                    //                                   ),
                    //                                 ),
                    //                                 SizedBox(width: 3),
                    //                                 RichText(
                    //                                   text: TextSpan(
                    //                                       children: <TextSpan>[
                    //                                         TextSpan(
                    //                                           //   text: singleEvent.begin_at.day.toString() + " " + "Febbraio" + " " + singleEvent.begin_at.year.toString(),
                    //                                           //   text: prestazione.duration.toString() + ' minuti',
                    //                                             text: NumberFormat
                    //                                                 .currency(
                    //                                               // customPattern: '#,##',
                    //                                                 decimalDigits: 2,
                    //                                                 symbol: '',
                    //                                                 locale: 'IT_it'
                    //                                               // ).format((distanceInMeters/1000)) + ' km',
                    //                                             ).format(
                    //                                                 (getDistance() /
                    //                                                     1000)) +
                    //                                                 ' km',
                    //                                             style: GoogleFonts
                    //                                                 .roboto(
                    //                                                 fontWeight: FontWeight
                    //                                                     .w700,
                    //                                                 color: Colors
                    //                                                     .grey[600],
                    //                                                 // color: Colors.green[600],
                    //                                                 // color: Colors.blue[500],
                    //                                                 fontSize: 12
                    //                                             )
                    //                                         ),
                    //                                       ]
                    //                                   ),
                    //                                 ),
                    //                               ],
                    //                             ),
                    //                           ),
                    //                         );
                    //                       }
                    //                       else
                    //                         return SizedBox();
                    //                     }
                    //                 )
                    //                     : SizedBox(),
                    //               ],
                    //             ),
                    //           ),
                    //         ],
                    //       );
                    //     }
                    //     else return SizedBox();
                    //   }
                    // ),
                  ),
                ),
                SliverToBoxAdapter(
                  // child: Column(
                  //   children: [
                  //     Stack(
                  //       // fit: StackFit.expand,
                  //       // clipBehavior: Clip.antiAliasWithSaveLayer,
                  //       children: [
                  //         Container(
                  //           margin: EdgeInsets.only(bottom: 3, top: 0),
                  //           height: MediaQuery.of(context).size.height * 0.3,
                  //           child: Card(
                  //             margin: EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                  //             clipBehavior: Clip.antiAliasWithSaveLayer,
                  //             shape: RoundedRectangleBorder(
                  //               borderRadius: BorderRadius.circular(5),
                  //             ),
                  //             child: FutureImage(
                  //               imageUrl: widget.prestazione.image,
                  //               fit: BoxFit.cover,
                  //               width: MediaQuery.of(context).size.width,
                  //               placeholder: (context, url) => Center(
                  //                   child: CircularProgressIndicator()
                  //               ),
                  //               errorWidget: (context, url, error) => Icon(Icons.error),
                  //             ),
                  //           ),
                  //         ),
                  //         Container(
                  //           margin: EdgeInsets.only(left: 3, right: 3, top: 0, bottom: 0),
                  //
                  //           height: MediaQuery.of(context).size.height * 0.3,
                  //           decoration: BoxDecoration(
                  //             // backgroundBlendMode: BlendMode.darken,
                  //             borderRadius: BorderRadius.all(Radius.circular(5)),
                  //             gradient: LinearGradient(
                  //               begin: Alignment.topLeft,
                  //               end: Alignment.bottomRight,
                  //               colors: [
                  //                 Colors.black,
                  //                 Colors.transparent,
                  //                 Colors.black,
                  //               ],
                  //             ),
                  //           ),
                  //           // child: Card(
                  //           //   // margin: ,
                  //           //   clipBehavior: Clip.antiAliasWithSaveLayer,
                  //           //   child: FutureImage(
                  //           //     imageUrl: widget.prestazione.image,
                  //           //     fit: BoxFit.cover,
                  //           //     width: MediaQuery.of(context).size.width,
                  //           //     placeholder: (context, url) => Center(
                  //           //         child: CircularProgressIndicator(
                  //           //         )
                  //           //     ),
                  //           //     errorWidget: (context, url, error) => Icon(Icons.error),
                  //           //   ),
                  //           // ),
                  //         ),
                  //
                  //         Positioned(
                  //           top: 20,
                  //           left: 20,
                  //           child: Container(
                  //             width: 200,
                  //             child: ExpandableText(
                  //               widget.prestazione.description,
                  //               maxLines: 6,
                  //               textAlign: TextAlign.start,
                  //               collapseText: 'nascondi',
                  //               expandText: 'mostra',
                  //               style: TextStyle(
                  //                 color: Colors.grey[400],
                  //                 fontSize: 12,
                  //                 fontWeight: FontWeight.w500,
                  //               ),
                  //               // animation: true,
                  //               // linkColor: Colors.grey[700],
                  //             ),
                  //           ),
                  //         ),
                  //         // Positioned(
                  //         //   bottom: 93,
                  //         //   left: 20,
                  //         //   child: Text(
                  //         //     widget.prestazione.duration.toString()
                  //         //         + ' minuti',
                  //         //     style: TextStyle(
                  //         //         // color: Colors.grey[700],
                  //         //         color: Colors.white,
                  //         //         // color: Colors.blue[500],
                  //         //         fontWeight: FontWeight.w800,
                  //         //         fontSize: 20
                  //         //     ),
                  //         //   ),
                  //         // ),
                  //         Positioned(
                  //           bottom: 20,
                  //           right: 20,
                  //           child: ClipRRect(
                  //             borderRadius: BorderRadius.circular(5),
                  //             child: BackdropFilter(
                  //               filter: ImageFilter.blur(
                  //                   sigmaY: 30,
                  //                   sigmaX: 30
                  //               ),
                  //               child: Container(
                  //                 margin: EdgeInsets.symmetric(vertical: 6, horizontal: 6),
                  //                 padding: EdgeInsets.only(left: 4),
                  //                 child: Text(
                  //                   '€ ' + NumberFormat.currency(
                  //                     // customPattern: '#,##',
                  //                       decimalDigits: 2,
                  //                       symbol: '',
                  //                       locale: 'IT_it'
                  //                   ).format(widget.prestazione.price),
                  //                   style: TextStyle(
                  //                     // color: Colors.grey[700],
                  //                     //   color: Colors.green[600],
                  //                       color: Colors.white,
                  //                       // color: Colors.blue[100],
                  //                       fontWeight: FontWeight.w900,
                  //                       fontSize: 28
                  //                   ),
                  //                 ),
                  //               ),
                  //             ),
                  //           ),
                  //         ),
                  //       ],
                  //     ),
                  //   ],
                  // ),
                  /**/
                  // child: Container(
                  //   width: MediaQuery.of(context).size.width * 0.9,
                  //   child: Row(
                  //     mainAxisAlignment: MainAxisAlignment.spaceAround,
                  //     children: [
                  //       // Visibility(
                  //       //   visible: Utils.user!.id == widget.user!.id,
                  //       //   // maintainSize: false,
                  //       //   // maintainState: false,
                  //       //   // maintainSemantics: false,
                  //       //   // maintainInteractivity: false,
                  //       //   // maintainAnimation: false,
                  //       //   child: InkWell(
                  //       //     onTap: (){
                  //       //       //print(Utils.user!.id == widget.user!.id);
                  //       //       // Navigator.push(
                  //       //       //     context,
                  //       //       //     PageTransition(
                  //       //       //         duration: const Duration(milliseconds: 500),
                  //       //       //         alignment: Alignment.center,
                  //       //       //         type: PageTransitionType.fade,
                  //       //       //         child: FollowersScreen(
                  //       //       //           user: widget.user,
                  //       //       //           followers: followers,
                  //       //       //         )
                  //       //       //     )
                  //       //       // );
                  //       //     },
                  //       //     child: Column(
                  //       //       children: [
                  //       //         Text(
                  //       //           Utils.user!.id == widget.user!.id ? favoriteProvider.favoritesList.length.toString() : "",
                  //       //           // favoriteProvider.favoritesList.length.toString(),
                  //       //           style: GoogleFonts.montserrat(
                  //       //               fontSize: 18.0,
                  //       //               color: Colors.blue,
                  //       //               // color: Colors.grey[700],
                  //       //               fontWeight: FontWeight.w600
                  //       //           )
                  //       //         ),
                  //       //         Text(
                  //       //             // 'Followers',
                  //       //             'Preferiti',
                  //       //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                  //       //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                  //       //         )
                  //       //       ],
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //       InkWell(
                  //         onTap: (){
                  //           // Navigator.push(
                  //           //     context,
                  //           //     PageTransition(
                  //           //         duration: const Duration(milliseconds: 500),
                  //           //         alignment: Alignment.center,
                  //           //         type: PageTransitionType.fade,
                  //           //         child: SubscriptionsScreen(
                  //           //           user: widget.user,
                  //           //           subscriptions: subscriptions,
                  //           //         )
                  //           //     )
                  //           // );
                  //         },
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                   "52",
                  //                   // userBookingsList.length.toString(),
                  //                   //   userProvider.events1.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //   subscriptions.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                  //                   //     : widget.user.numEventi.toString(),
                  //                   // style: GoogleFonts.montserrat(
                  //                   style: GoogleFonts.montserrat(
                  //                       fontSize: 18.0,
                  //                       color: Colors.blue,
                  //                       fontWeight: FontWeight.w600
                  //                   )
                  //               ),
                  //               SizedBox(height: 2,),
                  //               Text(
                  //                 // 'Iscrizioni',
                  //                   'Iscritti',
                  //                   // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                  //                   style: TextStyle(fontSize: 12.0, color: Colors.grey)
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: (){
                  //           // Navigator.push(
                  //           //     context,
                  //           //     PageTransition(
                  //           //         duration: const Duration(milliseconds: 500),
                  //           //         alignment: Alignment.center,
                  //           //         type: PageTransitionType.fade,
                  //           //         child: widget.user!.id == Utils.user!.id ? UserFriendsListScreen(
                  //           //           // userFriends: socketProvider.userFriendsList,
                  //           //           // user: widget.user!,
                  //           //         ) : UserProfileFriendsListScreen(
                  //           //           userFriends: userFriendsList,
                  //           //           // user: widget.user!,
                  //           //         )
                  //           //     )
                  //           // );
                  //         },
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                   "12",
                  //                   // widget.user!.id == Utils.user!.id
                  //                   //     ? socketProvider.userFriendsList.length.toString()
                  //                   //     : userFriendsList.length.toString(),
                  //                   //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                  //                   //   userFollowedList.length.toString(),
                  //                   //   userProvider.events1.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //   subscriptions.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                  //                   //     : widget.user.numEventi.toString(),
                  //                   // style: GoogleFonts.montserrat(
                  //                   style: GoogleFonts.montserrat(
                  //                       fontSize: 18.0,
                  //                       color: Colors.blue,
                  //                       fontWeight: FontWeight.w600
                  //                   )
                  //               ),
                  //               SizedBox(height: 2,),
                  //               Text(
                  //                 // 'Iscrizioni',
                  //                   'Preferenze',
                  //                   // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                  //                   style: TextStyle(fontSize: 12.0, color: Colors.grey)
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       InkWell(
                  //         onTap: (){
                  //           // Navigator.push(
                  //           //     context,
                  //           //     PageTransition(
                  //           //         duration: const Duration(milliseconds: 500),
                  //           //         alignment: Alignment.center,
                  //           //         type: PageTransitionType.fade,
                  //           //         child: SubscriptionsScreen(
                  //           //           user: widget.user,
                  //           //           subscriptions: subscriptions,
                  //           //         )
                  //           //     )
                  //           // );
                  //         },
                  //         child: Container(
                  //           padding: EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                  //           child: Column(
                  //             children: [
                  //               Text(
                  //                   "459",
                  //                   //   businessFavoriteProvider.savedBusinessList!.length.toString(),
                  //                   //   userFollowedList.length.toString(),
                  //                   //   userProvider.events1.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //   subscriptions.length.toString(),
                  //                   // widget.user.numEventi >= 10000
                  //                   //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                  //                   //     : widget.user.numEventi.toString(),
                  //                   // style: GoogleFonts.montserrat(
                  //                   style: GoogleFonts.montserrat(
                  //                       fontSize: 18.0,
                  //                       color: Colors.blue,
                  //                       fontWeight: FontWeight.w600
                  //                   )
                  //               ),
                  //               SizedBox(height: 2,),
                  //               Text(
                  //                 // 'Iscrizioni',
                  //                   'Prenotazioni',
                  //                   // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                  //                   style: TextStyle(fontSize: 12.0, color: Colors.grey)
                  //               )
                  //             ],
                  //           ),
                  //         ),
                  //       ),
                  //       // Visibility(
                  //       //   visible: Utils.isEventsEnabled,
                  //       //   maintainSize: false,
                  //       //   maintainInteractivity: false,
                  //       //   maintainAnimation: false,
                  //       //   maintainSemantics: false,
                  //       //   maintainState: false,
                  //       //   replacement: SizedBox(),
                  //       //   child: InkWell(
                  //       //     onTap: (){
                  //       //       // Navigator.push(
                  //       //       //     context,
                  //       //       //     PageTransition(
                  //       //       //         duration: const Duration(milliseconds: 500),
                  //       //       //         alignment: Alignment.center,
                  //       //       //         type: PageTransitionType.fade,
                  //       //       //         child: SubscriptionsScreen(
                  //       //       //           user: widget.user,
                  //       //       //           subscriptions: subscriptions,
                  //       //       //         )
                  //       //       //     )
                  //       //       // );
                  //       //     },
                  //       //     child: Column(
                  //       //       children: [
                  //       //         Text(
                  //       //           // "52",
                  //       //           // socketProvider.eventTicketsList.length.toString(),
                  //       //             eventTicketList1.length.toString(),
                  //       //             //   userProvider.events1.length.toString(),                                    // widget.user.numEventi >= 10000
                  //       //             //   subscriptions.length.toString(),                                    // widget.user.numEventi >= 10000
                  //       //             //     ? ((widget.user.numEventi/1000).toInt().truncate()).toString() + "mila"
                  //       //             //     : widget.user.numEventi.toString(),
                  //       //             // style: GoogleFonts.montserrat(
                  //       //             style: GoogleFonts.montserrat(
                  //       //                 fontSize: 18.0,
                  //       //                 color: Colors.blue,
                  //       //                 fontWeight: FontWeight.w600
                  //       //             )
                  //       //         ),
                  //       //         Text(
                  //       //           // 'Iscrizioni',
                  //       //             'Biglietti',
                  //       //             // style: GoogleFonts.montserrat(fontSize: 11.0, color: Colors.grey)
                  //       //             style: TextStyle(fontSize: 11.0, color: Colors.grey)
                  //       //         )
                  //       //       ],
                  //       //     ),
                  //       //   ),
                  //       // ),
                  //       // Visibility(
                  //       //   visible: Utils.user!.id == widget.user!.id,
                  //       //   child: InkWell(
                  //       //     onTap: (){
                  //       //       // Navigator.push(
                  //       //       //     context,
                  //       //       //     PageTransition(
                  //       //       //         duration: const Duration(milliseconds: 500),
                  //       //       //         alignment: Alignment.center,
                  //       //       //         type: PageTransitionType.fade,
                  //       //       //         child: FollowsScreen(
                  //       //       //           user: widget.user,
                  //       //       //           follows: follows,
                  //       //       //         )
                  //       //       //     )
                  //       //       // );
                  //       //     },
                  //       //     child: Column(
                  //       //       children: [
                  //       //         Text(
                  //       //           Utils.user!.id == widget.user!.id ? businessFavoriteProvider.savedBusinessList!.length.toString() : "",
                  //       //           // prestazioniList.length.toString(),
                  //       //           // businessFavoriteProvider.savedBusinessList.length.toString(),
                  //       //           // seguiti.toString(),
                  //       //
                  //       //           //   userProvider.seguiti.toString(),
                  //       //
                  //       //             // follows.length >= 10000
                  //       //             //     ? ((follows.length/1000)./*toInt().*/truncate()).toString() + "mila"
                  //       //             //     : follows.length.toString(),
                  //       //             style: GoogleFonts.montserrat(
                  //       //                 fontSize: 18.0, color: Colors.blue, fontWeight: FontWeight.w600
                  //       //             )
                  //       //         ),
                  //       //         Text(
                  //       //             // 'Seguiti',
                  //       //             // 'Locali',
                  //       //             'Salvati',
                  //       //             // style: GoogleFonts.montserrat(
                  //       //             style: TextStyle(
                  //       //                 fontSize: 11.0,
                  //       //                 color: Colors.grey
                  //       //             )
                  //       //         )
                  //       //       ],
                  //       //     ),
                  //       //   ),
                  //       // )
                  //     ],
                  //   ),
                  // ),
                  /**/
                  child: ListView(
                    shrinkWrap: true,
                    padding: EdgeInsets.all(0),
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Container(
                            width: MediaQuery.of(context).size.width * .6,
                            padding: EdgeInsets.only(left: 20, top: 20, bottom: 20),
                            child: /*Gradient*/Text(
                              widget.prestazione!.title ?? '',
                              // 'Massaggio del viso',
                              // gradient: LinearGradient(
                              //     begin: Alignment.bottomLeft,
                              //     end: Alignment.topRight,
                              //     colors: [
                              //       Color(0xff8921aa),
                              //       Color(0xffDA44bb),
                              //       // Color(0xffDA44bb)
                              //     ]
                              // ),
                              // maxLines: 4,
                              style: GoogleFonts.roboto(
                                  color: Colors.grey[900],
                                  // color: !_isAppBarExpanded ? Colors.white : Colors.grey[800],
                                  // color: Colors.blue[500],
                                  fontWeight: FontWeight.w900,
                                  fontSize: 25
                              ),
                            ),
                          ),
                          Container(
                            // width: MediaQuery.of(context).size.width * .3,
                            padding: EdgeInsets.only(right: 20, top: 20, bottom: 20),
                            child: Text(
                              // widget.prestazione!.price.toString() ?? '',
                              // '€ 25,88',
                              !widget.prestazione!.is_price_range ? '€ ${NumberFormat.currency(
                                // customPattern: '#,##',
                                  decimalDigits: 2,
                                  symbol: '',
                                  locale: 'IT_it'
                              ).format(widget.prestazione!.price)}' : 'Da € ${NumberFormat.currency(
                                // customPattern: '#,##',
                                  decimalDigits: 2,
                                  symbol: '',
                                  locale: 'IT_it'
                              ).format(widget.prestazione!.price_min)} \na € ${NumberFormat.currency(
                                // customPattern: '#,##',
                                  decimalDigits: 2,
                                  symbol: '',
                                  locale: 'IT_it'
                              ).format(widget.prestazione!.price_max)}',
                              maxLines: 2,
                              textAlign: TextAlign.center,
                              style: GoogleFonts.roboto(
                                color: Colors.blue[600],
                                fontWeight: FontWeight.w900,
                                fontSize: 23,
                              ),
                            ),
                          )
                        ],
                      ),
                      // Container(
                      //   // width: MediaQuery.of(context).size.width * 0.5,
                      //   width: MediaQuery.of(context).size.width * 0.8,
                      //   child: ExpandableText(
                      //       widget.prestazione!.description ?? '',
                      //       // overflow: TextOverflow.ellipsis,
                      //       textAlign: TextAlign.start,
                      //       collapseText: 'nascondi',
                      //       expandText: 'mostra',
                      //       maxLines: 5,
                      //       // maxLines: 2,
                      //       style: TextStyle(
                      //           fontWeight: FontWeight.w500,
                      //           color: Colors.grey[600],
                      //           // color: Colors.green[600],
                      //           // color: Colors.blue[500],
                      //           fontSize: 14
                      //       )
                      //   ),
                      // ),
                      // SizedBox(height: 20,),
                      Divider(indent: 15, endIndent: 15, height: 0, thickness: 1,)
                    ],
                  )
                ),
                SliverPersistentHeader(
                    pinned: true,
                    delegate: TabBarSliverPersistentHeaderDelegate(
                        extent: 70,
                        child: Container(
                          // height: 80,
                          margin: EdgeInsets.only(bottom: 0),
                          // padding: EdgeInsets.only(bottom: 10),
                          child: _dateBar(),
                        )
                    )
                ),
              ];
            },
            body: FutureBuilder<Object>(
                future: Future.wait([a, b, /*c,*/ d, e]),
                builder: (context, snapshot) {
                  if(openingDates.isEmpty && snapshot.connectionState != ConnectionState.done /*&& snapshot.hasData*/) {
                    return ListView(
                      // crossAxisAlignment: CrossAxisAlignment.center,
                      // mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SizedBox(height: MediaQuery.of(context).size.height * 0.12,),
                        Center(
                          child: Lottie.asset(
                            'assets/animations/76533-floating-robot-head.json',
                            // 'assets/animations/46809-web-develop-d.json',
                            // controller: animationController,
                            width: 250,
                            height: 250,
                            repeat: true,
                            animate: true,
                          ),
                        ),
                        Center(
                          child: Text(
                            "Caricando...",
                            // textAlign: TextAlign.center,
                            style: TextStyle(
                              // color: Colors.red[800],
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w600,
                              fontSize: 20,
                            ),
                          ),
                        ),
                      ],
                    );
                    // return SizedBox();
                  }
                  if(openingDates.isNotEmpty/*&& snapshot.hasData && snapshot.connectionState == ConnectionState.done*/){
                    return NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: ListView(
                        shrinkWrap: true,
                        // physics: NeverScrollableScrollPhysics(),
                        // physics: BouncingScrollPhysics(),
                        children: [
                          // Container(height: 10,),
                          Container(
                            child: ListView.builder(
                                shrinkWrap: true,
                                itemCount: slots.length,
                                physics: NeverScrollableScrollPhysics(),
                                itemBuilder: (context, i){
                                  if(slots[i].type == 0) {
                                    return Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          slots[i].begin_at!.toString().substring(11, 16) + ' - ' +
                                              slots[i].begin_at!.add(Duration(minutes: widget.prestazione!.duration!/*slotRange*/)).toString().substring(11, 16),
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 50,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.4,
                                          // height: 30,
                                          child: OutlinedButton(
                                            // style: ButtonStyle(
                                            //   padding: EdgeInsets.all(0),
                                            // ),
                                              style: cartProvider.isBookingInTheCart(
                                                  slots[i].begin_at.toString()) ?
                                              OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  backgroundColor: Colors.blue,
                                                  // backgroundColor: Colors.white,
                                                  // minimumSize: Size(50, 30),
                                                  alignment: Alignment.center
                                              ) : OutlinedButton.styleFrom(
                                                  padding: EdgeInsets.zero,
                                                  // backgroundColor: Colors.grey[50],
                                                  backgroundColor: Colors.white,
                                                  // minimumSize: Size(50, 30),
                                                  alignment: Alignment.center
                                              ),
                                              onPressed: () {
                                                // order.removeOrder(order.items[i]);

                                                // //print('cartProvider');
                                                // //print(cartProvider.items.toString());
                                                // //print(cartProvider.items[0].id.toString());

                                                CartItem cartItem = CartItem(
                                                    isEvent: false,
                                                    // business: widget.bookingBusiness,
                                                    business: widget.prestazione!.business,
                                                    // id:
                                                    begin_at: slots[i].begin_at,
                                                    // note:
                                                    // userId: widget.user != null ? widget.user.id : 'user_id',
                                                    image: widget.prestazione!.image,
                                                    title: widget.prestazione!.title,
                                                    duration: widget.prestazione!.duration,
                                                    presale_price: widget.prestazione!.price,
                                                    presale_price_min: widget.prestazione!.price_min,
                                                    presale_price_max: widget.prestazione!.price_max,
                                                    added_in_cart_at: DateTime.now().add(Duration(hours: DateTime.now().timeZoneOffset.inHours)),
                                                    // ticketCategoryId: Random().nextInt(999999999),
                                                    ticketCategoryId: slots[i].begin_at.toString(),
                                                    prestazione_id: widget.prestazione!.id,
                                                    prestazione: widget.prestazione
                                                );
                                                if(!cartProvider.isBookingInTheCart(slots[i].begin_at.toString())) {
                                                  // for(var e in cartProvider.items) {
                                                  //   if (e.begin_at.day == cartItem.begin_at.day && e.begin_at.month == cartItem.begin_at.month
                                                  //       && e.begin_at.year == cartItem.begin_at.year && e.prestazione.id == cartItem.prestazione.id) {
                                                  //     cartProvider.removeBookingByDate(e.begin_at.toString());
                                                  //   }
                                                  // }

                                                  cartProvider.addBookingInCart(cartItem);

                                                  // //print('cartItem');
                                                  // //print(cartItem.begin_at.toString());

                                                  // Fluttertoast.showToast(
                                                  //   msg: 'Aggiunto al carrello',
                                                  //   backgroundColor: Colors.grey[700],
                                                  // );
                                                  // final SnackBar snackBar = SnackBar(
                                                  //   content: Text(
                                                  //     'Aggiunto al Carrello',
                                                  //     style: TextStyle(
                                                  //       fontWeight: FontWeight.w600,
                                                  //       color: Colors.white,
                                                  //     ),
                                                  //   ),
                                                  //   backgroundColor: Colors.green,
                                                  //   behavior: SnackBarBehavior.floating,
                                                  //   margin: EdgeInsets.only(
                                                  //     bottom: MediaQuery.of(context).size.height - 100,
                                                  //     right: 20,
                                                  //     left: 20
                                                  //   ),
                                                  //   dismissDirection: DismissDirection.vertical,
                                                  // );
                                                  // snackbarKey.currentState?.showSnackBar(snackBar);
                                                }
                                                else {
                                                  cartProvider.removeBookingByDate(
                                                      slots[i].begin_at.toString());
                                                }

                                                // //print(cartItem.ticketCategoryId.toString());
                                              },
                                              child: !cartProvider.isBookingInTheCart(slots[i].begin_at.toString()) ? Text(
                                                // 'Prenota',
                                                // 'Aggiungi al carrello',
                                                'Seleziona',
                                                style: TextStyle(
                                                  // color: Colors.blue[500],
                                                  color: Colors.blue[500],
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                ),
                                              ) /* : Text(
                                            'Prenotato',
                                            style: TextStyle(
                                              // color: Colors.blue[500],
                                              color: Colors.blue[500],
                                              fontWeight: FontWeight.w800,
                                              fontSize: 12,
                                            ),
                                          )*/ : Icon(
                                                Icons.check,
                                                color: Colors.white,
                                              )
                                            /*: Text(
                                              'Acquistato',
                                              style: TextStyle(
                                                // color: Colors.blue[500],
                                                color: Colors.blue[500],
                                                fontWeight: FontWeight.w800,
                                                fontSize: 12,
                                            ),
                                          ),*/
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  else if(slots[i].type == 1 || slots[i].type == 2){
                                    return Row(
                                      // mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          slots[i].begin_at!/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16)
                                              + ' - ' +
                                              slots[i].begin_at!.add(Duration(minutes: widget.prestazione!.duration!/*slotRange*/))/*.add(Duration(hours: DateTime.now().timeZoneOffset.inHours))*/.toString().substring(11, 16),
                                          style: TextStyle(
                                            // color: Colors.blue[500],
                                            color: Colors.grey[700],
                                            fontWeight: FontWeight.w800,
                                            fontSize: 14,
                                          ),
                                        ),
                                        SizedBox(width: 50,),
                                        Container(
                                          width: MediaQuery
                                              .of(context)
                                              .size
                                              .width * 0.4,
                                          // height: 30,
                                          child: OutlinedButton(
                                            // style: ButtonStyle(
                                            //   padding: EdgeInsets.all(0),
                                            // ),
                                              style: OutlinedButton.styleFrom(
                                                padding: EdgeInsets.zero,
                                                backgroundColor: Colors.grey[50],
                                                // backgroundColor: Colors.white,
                                                // minimumSize: Size(50, 30),
                                                alignment: Alignment.center,
                                              ),
                                              onPressed: () {

                                              },
                                              child: Text(
                                                // 'Non Disponibile',
                                                'Prenotato',
                                                style: TextStyle(
                                                  // color: Colors.blue[500],
                                                  color: Colors.grey[500],
                                                  // color: Colors.red[700],
                                                  fontWeight: FontWeight.w800,
                                                  fontSize: 12,
                                                ),
                                              )
                                          ),
                                        )
                                      ],
                                    );
                                  }
                                  else return Text('Errore');
                                }
                            ),
                          ),
                          Container(height: 10,),
                          SizedBox(
                              height: /*cartProvider.items.length > 0
                                ?*/ MediaQuery.of(context).size.height * 0.105
                            // : MediaQuery.of(context).size.height * 0.01,
                          ),
                        ],
                      ),
                    );
                  }
                  else /*if(openingDates.isEmpty && *//*!snapshot.hasData &&*//* snapshot.connectionState == ConnectionState.done)*/{
                    // return Lottie.network(
                    //   'https://assets6.lottiefiles.com/packages/lf20_xdfeea13.json',
                    //   height: 400,
                    //   width: 400,
                    //
                    // );
                    return NotificationListener<OverscrollIndicatorNotification>(
                      onNotification: (overscroll) {
                        overscroll.disallowIndicator();
                        return true;
                      },
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        // physics: NeverScrollableScrollPhysics(),
                        children: [
                          SizedBox(height: MediaQuery.of(context).size.height * 0.1,),
                          // Lottie.asset(
                          //   'assets/animations/16683-closed.json',
                          //   // 'assets/animations/51661-closed-tag.json',
                          //   height: MediaQuery.of(context).size.height * 0.35,
                          //   width: MediaQuery.of(context).size.height * 0.35,
                          //   // height: MediaQuery.of(context).size.height * 0.45,
                          //   // width: MediaQuery.of(context).size.height * 0.45,
                          //
                          // ),
                          SizedBox(height: MediaQuery.of(context).size.height * .035,),
                          Center(
                            child: Image.asset(
                              'assets/png/Saly-3.png',
                              height: MediaQuery.of(context).size.height * .25,
                              // width: MediaQuery.of(context).size.width * .7,
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: MediaQuery.of(context).size.height * .05,),
                          Center(
                            child: Text(
                              "Chiuso",
                              // textAlign: TextAlign.center,
                              style: TextStyle(
                                color: Colors.red[800],
                                // color: Colors.grey[500],
                                fontWeight: FontWeight.w800,
                                fontSize: 20,
                              ),
                            ),
                          ),

                        ],
                      ),
                    );
                  }
                  /*else {
                  return Container(color: Colors.white,);
                }*/
                }
            ),
          ),
        )
    );
  }

}
