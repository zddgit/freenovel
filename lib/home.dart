import 'package:flutter/material.dart';
import 'package:freenovel/views/bookshelf.dart';

/// 首页
class Home extends StatefulWidget{
  @override
  HomeState createState() {
    return HomeState();
  }

}
class HomeState extends State<Home>  {

  int _currentIndex = 2;
  @override
  void initState() {
    super.initState();
  }

  Widget changWidget(){

    switch(_currentIndex){
      case 0: return Bookshelf();
      case 1: return Text("t1");
      case 2: return Text("t2");
      case 3: return Text("t3");
      default: return null;
    }
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: Scaffold(
       body: Center(
         child:changWidget(),
       ),
       bottomNavigationBar: Container(
         decoration: BoxDecoration(border:BorderDirectional(top:BorderSide(color: Colors.grey[500])) ),
         child: Padding(
           padding: const EdgeInsets.only(top: 1.2),
           child: BottomNavigationBar(
             items: <BottomNavigationBarItem>[
               BottomNavigationBarItem(icon: Icon(Icons.add),title: Text("书架"),activeIcon: Icon(Icons.add_box),backgroundColor: Colors.blue),
               BottomNavigationBarItem(icon: Icon(Icons.account_balance),title: Text("书城"),activeIcon: Icon(Icons.account_balance_wallet),backgroundColor: Colors.blue),
               BottomNavigationBarItem(icon: Icon(Icons.find_in_page),title: Text("发现"),activeIcon: Icon(Icons.find_in_page),backgroundColor: Colors.blue),
               BottomNavigationBarItem(icon: Icon(Icons.person),title: Text("我的"),activeIcon: Icon(Icons.account_circle),backgroundColor: Colors.blue),
             ],
             currentIndex: _currentIndex,
             type: BottomNavigationBarType.fixed,
             fixedColor: Colors.red,
             iconSize: 24.0,
             onTap:(index){
               setState(() {
                 _currentIndex = index;
               });
             },
           ),
         ),
       ),
     ),
   );
  }

}
