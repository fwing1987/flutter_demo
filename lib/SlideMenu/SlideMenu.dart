import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

typedef SlideMenuBuilder = Widget Function(BuildContext context, int index);
typedef TouchDownCallback = void Function(Offset offset);

class SlideMenu extends StatefulWidget {
  final List<Widget> child;
  final SlideMenuBuilder builder;
  final int itemCount;

  const SlideMenu({Key key, this.child, this.builder, this.itemCount})
      : super(key: key);
  @override
  _SlideMenuState createState() => _SlideMenuState();
}

class _SlideMenuState extends State<SlideMenu> {
  Offset tapDownOffset;
  @override
  Widget build(BuildContext context) {
    return ToggleMenuData(
      tapDownOffset: tapDownOffset,
      child: Listener(
      onPointerDown: (downEvent){
        setState(() {
          tapDownOffset = downEvent.position;
        });
      },
      child: ListView.builder(
          itemCount: widget.itemCount, itemBuilder: widget.builder),
    ));
  }
}

class ToggleMenuData extends InheritedWidget {
  final Offset tapDownOffset;

  ToggleMenuData({@required this.tapDownOffset, Widget child})
      : super(child: child);

  static ToggleMenuData of(BuildContext context) {
    return context.inheritFromWidgetOfExactType(ToggleMenuData);
  }

  @override
  bool updateShouldNotify(ToggleMenuData oldWidget) {
    return oldWidget.tapDownOffset != tapDownOffset;
  }
}
