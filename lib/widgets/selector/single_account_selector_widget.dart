import 'package:flutter/material.dart';
import 'package:marquee_widget/marquee_widget.dart';
import 'package:nurebo/widgets/selector/account.dart';

class SingleAccountSelectionWidget extends StatefulWidget {
  final int initiallySelectedIndex;
  final Function(int index) tapCallback;
  final List<AccountWithSelectionBoolean> accountwithselectionList;
  final bool hideSheetOnItemTap;
  final Color? selectedRadioColor,
      unselectedRadioColor,
      selectedTextColor,
      unselectedTextColor,
      unselectedSubtitleColor,
      unselectedDatetimeColor,
      arrowColor,
      backgroundColor;
  final bool showAddAccountOption;
  final Function addAccountTapCallback;

  SingleAccountSelectionWidget({
    required this.initiallySelectedIndex,
    required this.tapCallback,
    required this.accountwithselectionList,
    required this.hideSheetOnItemTap,
    required this.selectedRadioColor,
    required this.showAddAccountOption,
    required this.addAccountTapCallback,
    required this.arrowColor,
    required this.backgroundColor,
    required this.unselectedRadioColor,
    required this.selectedTextColor,
    required this.unselectedSubtitleColor,
    required this.unselectedDatetimeColor,
    required this.unselectedTextColor,
  });
  @override
  _SingleAccountSelectionWidgetState createState() =>
      _SingleAccountSelectionWidgetState();
}

class _SingleAccountSelectionWidgetState
    extends State<SingleAccountSelectionWidget> {
  int? currentIndex;
  @override
  void initState() {
    currentIndex = widget.initiallySelectedIndex;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
        color: widget.backgroundColor,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          IconButton(
            icon: Icon(
              Icons.keyboard_arrow_down,
              color: widget.arrowColor,
            ),
            onPressed: () {
              Navigator.of(context).pop();
            },
          ),
          Container(
            child: ConstrainedBox(
              constraints: BoxConstraints(
                minHeight: 30,
                maxHeight: MediaQuery.of(context).size.height * 0.5,
                minWidth: double.maxFinite,
                maxWidth: double.maxFinite,
              ),
              child: Padding(
                padding: const EdgeInsets.only(bottom: 0.0),
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: const EdgeInsets.fromLTRB(0, 6, 4, 6),
                      child: ListTile(
                        leading: ClipOval(
                          child: Container(
                              height: 56,
                              width: 56,
                              decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.grey[200]
                              ),
                              child: index ==
                                      (widget.accountwithselectionList.length - 1)
                                  ? CircleAvatar(
                                      radius: 28,
                                      backgroundColor: Colors.grey[200],
                                      child: Icon(
                                        Icons.add,
                                        color: Colors.black,
                                      ),
                                    )
                                  : widget.accountwithselectionList[index]
                                      .accountImageWidget),
                        ),
                        title: Marquee(
                          child: Row(
                            children: [
                              Text(
                                widget.accountwithselectionList[index].title!,
                                maxLines: 1,
                                style: TextStyle(
                                  color: index == currentIndex
                                      ? widget.selectedTextColor
                                      : widget.unselectedTextColor,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                        subtitle: ListView(
                          shrinkWrap: true,
                          physics: NeverScrollableScrollPhysics(),
                          children: [
                            SizedBox(height: 3,),
                            Marquee(
                              child: Row(
                                children: [
                                  Text(
                                    widget.accountwithselectionList[index].subtitle ?? '',
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: index == currentIndex
                                          ? widget.selectedTextColor
                                          : widget.unselectedSubtitleColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            // SizedBox(height: 1,),
                            SizedBox(height: 3,),
                            Marquee(
                              child: Row(
                                children: [
                                  Text(
                                    widget.accountwithselectionList[index].datetime/* ?? ''*/,
                                    maxLines: 1,
                                    style: TextStyle(
                                      color: index == currentIndex
                                          ? widget.selectedTextColor
                                          : widget.unselectedDatetimeColor,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        isThreeLine: true,
                        trailing: index ==
                                (widget.accountwithselectionList.length - 1)
                            ? Offstage()
                            : Icon(
                                (index == currentIndex)
                                    ? Icons.radio_button_checked
                                    : Icons.radio_button_unchecked,
                                color: (index == currentIndex)
                                    ? widget.selectedRadioColor
                                    : widget.unselectedRadioColor
                        ),
                        onTap: index ==
                                (widget.accountwithselectionList.length - 1)
                            ? widget.addAccountTapCallback as void Function()?
                            : () {
                                setState(() {
                                  currentIndex = index;
                                });
                                if (widget.hideSheetOnItemTap) {
                                  Future.delayed(
                                    Duration(milliseconds: 750),
                                    Navigator.of(context).pop
                                  );
                                  // Navigator.of(context).pop();
                                }
                                widget.tapCallback(index);
                              },
                      ),
                    );
                  },
                  itemCount: widget.showAddAccountOption
                      ? widget.accountwithselectionList.length
                      : widget.accountwithselectionList.length - 1,
                ),
              ),
            ),
          ),
          SizedBox(height: 5,),
        ],
      ),
    );
  }
}
