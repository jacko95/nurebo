import 'package:flutter/material.dart';

class Account {
  String? title;
  String? subtitle;
  String datetime;
  Widget accountImageWidget;
  Account({
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.accountImageWidget,
  });
}

class AccountWithSelectionBoolean {
  String? title;
  String? subtitle;
  String datetime;
  Widget? accountImageWidget;
  bool selected;
  AccountWithSelectionBoolean({
    required this.title,
    required this.subtitle,
    required this.datetime,
    required this.accountImageWidget,
    required this.selected,
  });
}

List<AccountWithSelectionBoolean> setupAccountWithSelectionList(
  List<Account> accountList,
  int initialySelectedElementIndex,
  bool showAddAccountOption,
  String addAccountTitle,
  // String addAccountSubtitle,
) {
  List<AccountWithSelectionBoolean> actualList = [];
  for (int i = 0; i < accountList.length; i++) {
    actualList.add(
      AccountWithSelectionBoolean(
        title: accountList[i].title,
        subtitle: accountList[i].subtitle,
        datetime: accountList[i].datetime,
        accountImageWidget: accountList[i].accountImageWidget,
        selected: i == initialySelectedElementIndex ? true : false,
      ),
    );
  }
  actualList.add(
    AccountWithSelectionBoolean(
      title: addAccountTitle,
      subtitle: '',
      datetime: '',
      accountImageWidget: null,
      selected: false,
    ),
  );
  return actualList;
}

List<AccountWithSelectionBoolean> setupAccountWithMultiSelectionList(
  List<Account> accountList,
  List<int>? initiallySelectedIndexList,
) {
  List<AccountWithSelectionBoolean> actualList = [];
  for (int index = 0; index < accountList.length; index++) {
    actualList.add(
      AccountWithSelectionBoolean(
        title: accountList[index].title,
        subtitle: accountList[index].subtitle,
        datetime: accountList[index].datetime,
        accountImageWidget: accountList[index].accountImageWidget,
        selected: (initiallySelectedIndexList == null || initiallySelectedIndexList.length < 1)
            ? false
            : initiallySelectedIndexList.contains(index) ? true : false,
      ),
    );
  }
  return actualList;
}
