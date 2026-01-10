import 'package:flutter/material.dart';
import 'package:nurebo/models/business.dart';
import 'package:nurebo/provider/socket_provider.dart';
import 'package:nurebo/provider/user_provider.dart';
import 'package:nurebo/screens/booking_business_profile_screen.dart';
import 'package:nurebo/screens/business_room_screen.dart';
import 'package:nurebo/screens/cart_screen.dart';
import 'package:nurebo/screens/category_list_screen.dart';
import 'package:nurebo/screens/explore_screen.dart';
import 'package:nurebo/screens/search_map_screen.dart';
import 'package:nurebo/screens/favorites_screen.dart';
import 'package:nurebo/screens/group_chat_screen.dart';
import 'package:nurebo/screens/home_screen.dart';
import 'package:nurebo/screens/business_category_list_screen.dart';
import 'package:nurebo/screens/messages_screen.dart';
import 'package:nurebo/screens/notifications_screen.dart';
import 'package:nurebo/screens/post_feed_screen.dart';
import 'package:nurebo/screens/rooms_screen.dart';
import 'package:nurebo/screens/business_favorite_screen.dart';
import 'package:nurebo/screens/search_screen.dart';
import 'package:nurebo/screens/user_booking_list_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/screens/user_profile_screen.dart';
import 'package:nurebo/utils/user_preferences.dart';
import 'package:nurebo/utils/utils.dart';
import 'package:nurebo/widgets/popover.dart';
import 'package:provider/provider.dart';
import 'main.dart';
import 'models/user.dart';


class TabNavigator extends StatefulWidget {
  final User? user;
  final Business? business;
  final GlobalKey<NavigatorState>? navigatorKey;
  /*static*/ final String? tabItem;

  const TabNavigator({super.key, this.navigatorKey, this.tabItem, this.user, this.business});

  @override
  State<TabNavigator> createState() => _TabNavigatorState();
}

class _TabNavigatorState extends State<TabNavigator> {
  late UserProvider userProvider;
  late SocketProvider socketProvider;
  /*late*/ Widget child = HomeScreen();


  @override
  void initState() {
    super.initState();
    // print('Utils.business!.toJson()');
    // print(Utils.business!.toJson());
    userProvider = Provider.of<UserProvider>(context, listen: false);
    socketProvider = Provider.of<SocketProvider>(context, listen: false);

    if(Utils.isBusiness == true){
      if(widget.tabItem == "Page1") {
        // Utils.tabItem = 0;
        // socketProvider.currentTab = 0;
        socketProvider.setCurrentTab(0);
        child = const HomeScreen(
          // user: user,
        );
      }
      else if(widget.tabItem == "Page2") {
        // Utils.tabItem = 1;
        // socketProvider.currentTab = 1;
        socketProvider.setCurrentTab(1);
        // child = BusinessRoomScreen(
        //   business: Utils.business,
        // );
        child = PostFeedScreen();
      }
      else if(widget.tabItem == "Page3") {
        // Utils.tabItem = 2;
        // socketProvider.currentTab = 2;
        socketProvider.setCurrentTab(2);
        // child = BusinessRoomScreen(
        child = BookingBusinessProfileScreen(
          business: Utils.business,
        );
      }
      else if(widget.tabItem == "Page4") {
        // Utils.tabItem = 3;
        // socketProvider.currentTab = 3;
        socketProvider.setCurrentTab(3);
        child = CartScreen(
          // user: userProvider.user,
          user: widget.user,
        );
        // child = SavedBusinessScreen();
      }
      else if(widget.tabItem == "Page5") {
        // Utils.tabItem = 4;
        socketProvider.setCurrentTab(4);
        // child = SizedBox();
        child = !UserPreferences.getIsLogged()! ? SizedBox() : UserProfileScreen(
          // user: userProvider.user,
          // userId: Utils.user!.id!,
          user: Utils.user!,
          isTab: true,
        );
      }
    }
    else if(Utils.isSocial == true) {
      if(widget.tabItem == "Page1") {
        // Utils.tabItem = 0;
        child = const HomeScreen(
          // user: user,
        );
      }
      else if(widget.tabItem == "Page2") {
        // Utils.tabItem = 1;
        // child = RoomScreen(
        child = const PostFeedScreen(
          // user: user,
        );

      }
      else if(widget.tabItem == "Page3") {
        // Utils.tabItem = 2;
        child = ExploreScreen(
          // user: user,
        );
      }
      else if(widget.tabItem == "Page4") {
        // Utils.tabItem = 3;
        child = MessagesScreen(
          // user: user,
        );
      }
      else if(widget.tabItem == "Page5") {
        // Utils.tabItem = 4;
        child = const CartScreen(
          // child = RoomScreen(
          // child = NotificationsScreen(
          // user: user,
        );
      }
    }
    else if (Utils.isBusiness == false && Utils.isSocial == false){
      if(widget.tabItem == "Page1") {
        // Utils.tabItem = 0;
        // socketProvider.currentTab = 0;
        // socketProvider.setCurrentTab(0);
        child = const HomeScreen(
          // user: user,
        );
      }
      else if(widget.tabItem == "Page2") {
        // Utils.tabItem = 1;
        // socketProvider.currentTab = 1;
        // socketProvider.setCurrentTab(1);
        // child = BusinessRoomScreen(
        //   business: Utils.business,
        // );
        child = PostFeedScreen();
      }
      else if(widget.tabItem == "Page3") {
        // Utils.tabItem = 2;
        // socketProvider.currentTab = 2;
        // socketProvider.setCurrentTab(2);
        // child = BusinessRoomScreen(
        child = CategoryListScreen();
      }
      else if(widget.tabItem == "Page4") {
        // Utils.tabItem = 3;
        // socketProvider.currentTab = 3;
        // socketProvider.setCurrentTab(3);
        // child = CartScreen(
        //   // user: userProvider.user,
        //   user: widget.user,
        // );
        child = UserBookingListScreen(
          // business: Utils.business,
        );
        // child = SavedBusinessScreen();
      }
      else if(widget.tabItem == "Page5") {
        // Utils.tabItem = 4;
        // socketProvider.currentTab = 4;
        // socketProvider.setCurrentTab(4);
        // child = SizedBox();
        child = !UserPreferences.getIsLogged()! ? SizedBox() : UserProfileScreen(
          // user: userProvider.user,
          user: Utils.user!,
          isTab: true,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    userProvider = Provider.of<UserProvider>(context, listen: true);
    // var homeScreen = const HomeScreen(
    //   // user: user,
    // );

    return Navigator(
      key: widget.navigatorKey,
      onGenerateRoute: (routeSettings) {
        return MaterialPageRoute(builder: (context) => child);
      },
    );
  }
}
