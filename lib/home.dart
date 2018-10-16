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

  /// 页面主题
  Widget _changBodyWidget(){
    switch(_currentIndex){
      case 0: return Bookshelf();
      case 1: return Text("t1");
      case 2: return Text("t2");
      case 3: return Text("t3");
      default: return null;
    }
  }
  /// 标题
  AppBar _changAppBarWidget(){
    String title;
    switch(_currentIndex){
      case 0: title="书架"; break;
      case 1: title="书城"; break;
      case 2: title="发现"; break;
      case 3: title="我的"; break;
      default: title =  "";
    }
    return AppBar(backgroundColor:Colors.blue,title: Text(title),);
  }

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     home: Scaffold(
       appBar: _changAppBarWidget(),
       backgroundColor:Colors.grey[300],
       body: Center(
         child:_changBodyWidget(),
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
