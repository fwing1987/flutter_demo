import 'package:flutter/material.dart';
import 'package:flutter_wf/SlideMenu/SlideMenu.dart';
import 'package:flutter_wf/SlideMenu/SlideMenuItem.dart';

class SlideMenuTest extends StatefulWidget {
  @override
  _SlideMenuTestState createState() => _SlideMenuTestState();
}

class _SlideMenuTestState extends State<SlideMenuTest> {
  @override
  Widget build(BuildContext context) {
    return SlideMenu(itemCount:1000,builder: (context,index){
      if(index % 2 == 0){
        return Divider(height: 1,);
      }
      return SlideMenuItem(
        menuWidth: 150,
        child:GestureDetector(
          onTap: (){
            print("这是${index}个");
          },
          child: ListTile(
            title: Center(
              child: Text("这是第${index}个"),
            ),
          ),
        ),
        menus: <Widget>[
          GestureDetector(
            onTap: (){
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("删除被点击"),duration: Duration(seconds: 1),));
            },
            child: Container(
              width: 75,
              decoration: BoxDecoration(
                  color: Colors.grey
              ),
              child: (Center(
                child: Text("删除"),
              )),
            ),
          ),
          GestureDetector(
            onTap: (){
              Scaffold.of(context).showSnackBar(SnackBar(content: Text("置顶被点击"),duration: Duration(seconds: 1)));
            },
            child: Container(
              width: 75,
              decoration: BoxDecoration(
                  color: Colors.red
              ),
              child: (Center(
                child: Text("置顶"),
              )),
            ),
          )
        ],
      );
    },);
  }
}

