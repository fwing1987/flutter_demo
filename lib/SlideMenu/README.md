@[toc]
网上浏览Flutter教程的时候，找到一篇文章，[Flutter | 超简单仿微信QQ侧滑菜单组件](https://juejin.im/post/5d82130ce51d453b373b4dc6)，研读了全文之后，感觉作者思路清晰，教程简洁明了，忍不住自己实现了一下。

和微信的菜单对比，原文中有一点没有实现：
* 菜单与其他列表没有联动，如其他列表点击后，菜单没有收回，原因是作者提供的是侧滑菜单组件，而不是将整个列表做为一个组件提供。

先看一下最终实现的效果：  
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190923175830222.gif)

### 一、明确需求
1. 列表可以滑动出菜单；
2. 列表滑动不够距离则菜单再次隐藏，距离足够则完全展示菜单；
3. 菜单支持事件处理
4. 菜单样式、个数由使用者传入；
5. 除菜单之外部分点击，如其他列表或本列表非菜单部分，则菜单隐藏；

前面几点原文都有讲解，不过因为这里尝试自己去写，有些点不太一样。

### 二、实现需求
#### 1. 滑动菜单实现使用`SingleChildScrollView`：
```js
SingleChildScrollView(
  scrollDirection:Axis.horizontal,//横向滚动
  controller: controller,
  child: IntrinsicHeight(
    child: Row(
      children: _buildChildren(context),
    ),
  ),
),
```
可以看到中间使用了一个`IntrinsicHeight`，这个类可以保证Row中的Container菜单自动适应和列表同一个高度，如下图是使用与不使用这个widget的差别：
![在这里插入图片描述](https://img-blog.csdnimg.cn/20190923163955752.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3B1cl9l,size_16,color_FFFFFF,t_70)![在这里插入图片描述](https://img-blog.csdnimg.cn/20190923164010434.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3B1cl9l,size_16,color_FFFFFF,t_70)

#### 2. 列表滑动不够距离则菜单再次隐藏，距离足够则完全展示菜单。
这个原文中也有讲解，使用Listener这个Widget，onPointerUp来监听原始指针事件的抬起手势，无论是滑动后抬起还是直接抬起，都可以监听，而不会因手势冲突而收不到事件，详细可以参考：[8.1 原始指针事件处理](https://book.flutterchina.club/chapter8/listener.html)。
```js
Listener(
onPointerUp: (upEvent){
  if(isAnimated) return;//后面再说明
  if(controller.offset < menuWidth / 5){
  //不足菜单5分之1，弹回
    controller.animateTo(0, duration: Duration(milliseconds: 100), curve: Curves.linear);
  }else{
  //否则直接展示所有菜单
    controller.animateTo(menuWidth, duration: Duration(milliseconds: 100), curve: Curves.linear);
  }
},
```

#### 3. 菜单支持事件处理。
#### 4. 菜单样式、个数由使用者传入。
这两个一起说明，传入的菜单其实没有太多特殊处理，只是用`SingleChildScrollView`和`Row`包裹了一下，在传入的child的后面添加了菜单项，所有事件和样式、个数等还是由使用者直接传入。
```js
_buildChildren(BuildContext context){
  var screenSize = MediaQuery.of(context).size;
  List<Widget> childrenWidget = List<Widget>();
  childrenWidget.add(Container(
    width: screenSize.width,
    child: child,
  ));
  childrenWidget.addAll(menus.map((e)=>Container(child: e,)));
  return childrenWidget;
}
```

#### 5. 除菜单之外部分点击，如其他列表或本列表非菜单部分，则菜单隐藏
实现这个需求，其实只要在整个列表上添加一个“按下”事件的监听，如果点击位置不在菜单范围内，则菜单隐藏即可。使用Listener Widget可以完美实现，按下事件的回调可以取到按下的位置。同时，为了在子节点中取到这个“按下位置”，因为没有将控件强关联，所以使用了InheritedWidget，进行数据传递，详见：[7.2 数据共享（InheritedWidget）](https://book.flutterchina.club/chapter7/inherited_widget.html)。

```js
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
```

然后在子节点中，判断点击位置是否是菜单范围内，不在范围内则隐藏菜单。有两个细节：
* 一个是`ScrollController`在build时，还未与`SingleChildScrollView`关联，无法取到偏移量，需要使用`WidgetsBinding.instance.addPostFrameCallback`添加回调：
```js
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
```

* 还有一个是子节点的`onPointerUp`事件会在父节点的`onPointerDown`事件后触发，这样如果点击在菜单左侧区域，如下图：  

![在这里插入图片描述](https://img-blog.csdnimg.cn/20190923174618869.jpg?x-oss-process=image/watermark,type_ZmFuZ3poZW5naGVpdGk,shadow_10,text_aHR0cHM6Ly9ibG9nLmNzZG4ubmV0L3B1cl9l,size_16,color_FFFFFF,t_70)
则会先触发父节点的`onPointerDown`事件，将菜单隐藏，再触发子节点的`onPointerUp`事件，想将菜单展示，发生冲突，所以需要加一个判断，父节点动画未结束时，子结点事件不处理，即保留点击上图红色区域内则菜单隐藏的逻辑。
```js
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
```

