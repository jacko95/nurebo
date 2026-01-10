import 'package:flutter/material.dart';

class SelectorTile {
  String title;
  String subtitle;
  String datetime;
  Widget leadingWidget;
  SelectorTile({
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.leadingWidget,
  });
}

class SelectorTileBoolean {
  String title;
  String subtitle;
  String datetime;
  Widget? leadingWidget;
  bool selected;
  SelectorTileBoolean({
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.leadingWidget,
    required this.selected,
  });
}

List<SelectorTileBoolean> setupAccountWithSelectionList(
  List<SelectorTile> accountList,
  int initialySelectedElementIndex,
  bool showAddAccountOption,
  String addTileTitle,
  // String addAccountSubtitle,
) {
  List<SelectorTileBoolean> actualList = [];
  for (int i = 0; i < accountList.length; i++) {
    actualList.add(
      SelectorTileBoolean(
        title: accountList[i].title,
        subtitle: accountList[i].subtitle,
        datetime: accountList[i].datetime,
        leadingWidget: accountList[i].leadingWidget,
        selected: i == initialySelectedElementIndex ? true : false,
      ),
    );
  }
  actualList.add(
    SelectorTileBoolean(
      title: addTileTitle,
      subtitle: '',
      datetime: '',
      leadingWidget: null,
      selected: false,
    ),
  );
  return actualList;
}

List<SelectorTileBoolean> setupAccountWithMultiSelectionList(
  List<SelectorTile> accountList,
  List<int> initiallySelectedIndexList,
) {
  List<SelectorTileBoolean> actualList = [];
  for (int index = 0; index < accountList.length; index++) {
    actualList.add(
      SelectorTileBoolean(
        title: accountList[index].title,
        subtitle: accountList[index].subtitle,
        datetime: accountList[index].datetime,
        leadingWidget: accountList[index].leadingWidget,
        selected: (initiallySelectedIndexList == null ||
                initiallySelectedIndexList.length < 1)
            ? false
            : initiallySelectedIndexList.contains(index) ? true : false,
      ),
    );
  }
  return actualList;
}
