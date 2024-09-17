import 'package:cj/services/auth/auth_service.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class MainWrapper extends StatefulWidget {
  const MainWrapper({
    required this.navigationShell,
    super.key,
  });
  final StatefulNavigationShell navigationShell;

  @override
  State<MainWrapper> createState() => _MainWrapperState();
}

class _MainWrapperState extends State<MainWrapper> {
  int selectedIndex = 0;

  void _goBranch(int index) {
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == widget.navigationShell.currentIndex,
    );
  }

  

  

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: widget.navigationShell,
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: () {
      //     context.push(context.namedLocation('Player'));
      //   },
      //   backgroundColor: Colors.deepPurpleAccent,
      //   child: const Icon(Icons.play_arrow),
      // ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        iconSize: 30,
        onTap: (index) {
          setState(() {
            selectedIndex = index;
          });
          _goBranch(selectedIndex);
        },
        
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long),
            label: 'Invoice',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.inventory_2),
            label: 'Stock',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.store),
            label: 'Shop',
          ),
        ],
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.grey,
        backgroundColor: Colors.white,
        type: BottomNavigationBarType.fixed,
      ),
    );
  }
}
