import 'package:flutter/material.dart';

class Popover extends StatelessWidget {
  const Popover({
    Key? key,
    this.child,
  });

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      // margin: const EdgeInsets.all(16.0),
      // height: MediaQuery.of(context).size.height * 0.99,
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        // color: theme.cardColor,
        color: Colors.grey[100],
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16.0),
          topRight: Radius.circular(16.0),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHandle(context),
          if (child != null)
            child!
        ],
      ),
    );
  }

  Widget _buildHandle(BuildContext context) {
    final theme = Theme.of(context);

    return FractionallySizedBox(
      widthFactor: 0.15,
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 12.0,
        ),
        child: Container(
          height: 5.0,
          decoration: BoxDecoration(
            //color: theme.dividerColor,
            color: Colors.grey[400],
            borderRadius: const BorderRadius.all(Radius.circular(2.5)),
          ),
        ),
      ),
    );
  }
}
