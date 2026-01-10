import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:nurebo/models/cart_item.dart';
import 'package:nurebo/main.dart';

class CartProvider extends ChangeNotifier {
  // List<Order> items = [];
  List<CartItem> items = [];
  double totalCartOrder = 0;
  double minTotalCartOrder = 0;
  double maxTotalCartOrder = 0;


  void addOrder(CartItem ticket) {
    final i = items.indexWhere((e) => e.singleEventId == ticket.singleEventId);
    // //print('i');
    // //print(i);
    if (i > -1) {
      // items[i].quantity += ticket.quantity;
      for(int j = 0; j < ticket.quantity!; j++){
        addQuantity(j);
      }
    } else {
      this.items.add(ticket);
    }
    notifyListeners();
  }

  void addEventInCart(CartItem ticket) {
    // for(var e in items) {
    for(int i = 0; i < items.length; i++) {
      // if (e.ticketCategoryId == ticket.ticketCategoryId) {
      if (items[i].ticketCategoryId == ticket.ticketCategoryId) {
      // // if (e == ticket) {
      //   for(int j = 0; j < ticket.quantity; j++){
      //     addQuantity(i);
      //   }
      //   // items[i].quantity += ticket.quantity;
      //   getTotalOrder();
      //   notifyListeners();
        return;
      }
    }
    // for(int j = 0; j < ticket.quantity; j++){
    //   addQuantity(j);
    // }
    items.add(ticket);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    getTotalOrder();

    // Fluttertoast.showToast(
    //   msg: 'Aggiunto al Carrello',
    //   backgroundColor: Colors.grey[700],
    // );
    final SnackBar snackBar = SnackBar(
      content: Text(
        'Aggiunto al Carrello',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      backgroundColor: Colors.green,
    );
    snackbarKey.currentState?.showSnackBar(snackBar);

    notifyListeners();
  }

  /*double*/ getTotalOrder() {
    totalCartOrder = 0;
    for(var e in items){
      if(!e.isEvent!){
        if(e.prestazione!.is_price_range) {
          minTotalCartOrder += e.presale_price_min!.toDouble();
          maxTotalCartOrder += e.presale_price_max!.toDouble();
        }
        else {
          totalCartOrder += e.presale_price!.toDouble();
        }
      }
      else if(e.isEvent!){
        // totalCartOrder += (e.ticketCategoryPrice * e.quantity);
        totalCartOrder += (e.eventTicket!.price! * e.quantity!);
      }
    }
    notifyListeners();
    // return totalCartOrder;
  }

  void addBookingInCart(CartItem item) {
    if(!item.isEvent!){
      for(var e in List.from(items)) {
        if(!e.isEvent){
          // if(e.begin_at.day == item.begin_at!.day && e.begin_at.month == item.begin_at!.month
          //     && e.begin_at.year == item.begin_at!.year && e.prestazione.id == item.prestazione!.id) {
            removeBookingByDate(e.begin_at.toString());
          // }
        }

        // //evitare incroci con altri appuntamenti nel carrello
        // if (e.ticketCategoryId == booking.ticketCategoryId) {
        //   // if (e == ticket) {
        //   e.quantity += booking.quantity;
        //   getTotalOrder();
        //   notifyListeners();
        //   return;
        // }
      }
    }
    items.add(item);
    // for(var e in items) {
    //   //print(e.toString());
    // }
    getTotalOrder();
    notifyListeners();
  }

  removeOrder(CartItem ticket) {
    final i = items.indexWhere((e) => e.ticketCategoryId == ticket.ticketCategoryId);
    items.remove(items[i]);
    // if (i > -1) {
    //   items[i].quantity += ticket.quantity;
    // } else {
    //   this.items.add(ticket);
    // }

    // items.remove(ticket);
    getTotalOrder();
    notifyListeners();
  }

  removeAll() {
    items.clear();
    getTotalOrder();
    notifyListeners();
  }

  void subtractQuantity(int i) {
    // items[i].quantity--;
    items[i].quantity = items[i].quantity! - 1;
    getTotalOrder();
    notifyListeners();
  }

  void addQuantity(int i) {
    // items[i].quantity++;
    items[i].quantity = items[i].quantity! + 1;
    getTotalOrder();
    notifyListeners();
  }

  bool isBookingInTheCart(String beginAt) {
    for(var e in items) {
      // if (e == booking) {
      if (e.ticketCategoryId == beginAt) {
        return true;
      }
    }
    return false;
    // notifyListeners();
  }

  removeBookingByDate(String beginAt) {
    final i = items.indexWhere((e) => e.begin_at.toString() == beginAt);
    items.remove(items[i]);
    // if (i > -1) {
    //   items[i].quantity += ticket.quantity;
    // } else {
    //   this.items.add(ticket);
    // }

    // items.remove(ticket);
    getTotalOrder();
    notifyListeners();
  }

  removeEventByDate(String eventTicketId) {
    final i = items.indexWhere((e) => e.eventTicket!.id.toString() == eventTicketId);
    items.remove(items[i]);
    // if (i > -1) {
    //   items[i].quantity += ticket.quantity;
    // } else {
    //   this.items.add(ticket);
    // }

    // items.remove(ticket);
    getTotalOrder();
    notifyListeners();
  }

  // decrementQty(order) {
  //   final i = items.indexWhere((e) => e.product == order.product);
  //   if (items[i].qty == 1) {
  //     removeOrder(order);
  //   } else {
  //     items[i].qty -= 1;
  //     notifyListeners();
  //   }
  // }
  //
  // incrementQty(order) {
  //   items[items.indexOf(order)].qty += 1;
  //   notifyListeners();
  // }
}
