import 'package:flutter/material.dart';
import 'package:flutter_wf/SlideMenu/SlideMenu.dart';

class SlideMenuItem extends StatelessWidget {
  SlideMenuItem({this.menuWidth, this.child, this.menus});
  final Widget child;
  final List<Widget> menus;
  final double menuWidth;

  bool isAnimated = false;
  ScrollController controller = ScrollController();

  _buildChildren(BuildContext context) {
    var screenSize = MediaQuery.of(context).size;
    List<Widget> childrenWidget = List<Widget>();
    childrenWidget.add(Container(
      width: screenSize.width,
      child: child,
    ));
    childrenWidget.addAll(menus.map((e) => Container(
          child: e,
        )));
    return childrenWidget;
  }

  @override
  Widget build(BuildContext context) {
//    print("rebuild SlideMenuItem");
    var screenSize = MediaQuery.of(context).size;
    WidgetsBinding.instance.addPostFrameCallback((duration) {
      Offset tapDownOffset = ToggleMenuData.of(context).tapDownOffset;
      if (tapDownOffset != null && controller.hasClients) {
        RenderBox renderBox = context.findRenderObject();
        Offset myOffset = renderBox.localToGlobal(Offset(0, 0));
        Size mySize = renderBox.size;
        //菜单点击位置不在按钮范围内
        if (controller.offset > 0 &&
            (screenSize.width - controller.offset > tapDownOffset.dx ||
                myOffset.dy > tapDownOffset.dy ||
                myOffset.dy + mySize.height < tapDownOffset.dy)) {
          isAnimated = true;
          controller
              .animateTo(0,
                  duration: Duration(milliseconds: 100), curve: Curves.linear)
              .then((v) {
            isAnimated = false;
          });
        }
      }
    });
    return Listener(
        onPointerUp: (upEvent) {
          //如果已在动画中，不处理
          if (isAnimated) return;
          if (controller.offset < menuWidth / 5) {
            //不足菜单5分之1，弹回
            controller.animateTo(0,
                duration: Duration(milliseconds: 100), curve: Curves.linear);
          } else {
            //否则直接展示所有菜单
            controller.animateTo(menuWidth,
                duration: Duration(milliseconds: 100), curve: Curves.linear);
          }
        },
        child: SingleChildScrollView(
          scrollDirection: Axis.horizontal, //横向滚动
          controller: controller,
          child: IntrinsicHeight(
            child: Row(
              children: _buildChildren(context),
            ),
          ),
        ));
  }
}
