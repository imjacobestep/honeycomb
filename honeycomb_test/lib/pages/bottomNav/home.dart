import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:honeycomb_test/model/user.dart';
import 'package:honeycomb_test/ui_components/clients_ui.dart';
import 'package:honeycomb_test/ui_components/resource_ui.dart';
import '../../proxy.dart';
import '../../utilities.dart';
import 'package:honeycomb_test/pages/bottomNav/navbar.dart';
import 'package:bottom_sheet_bar/bottom_sheet_bar.dart';

class HomePage extends StatefulWidget {
  @override
  HomePageState createState() => HomePageState();
  Proxy proxyModel = Proxy();
  String userID = FirebaseAuth.instance.currentUser!.uid;
  MPUser? user;
  Iterable? favs;
  Iterable? clients;
  BottomSheetBarController sheetCont = BottomSheetBarController();

  HomePage();
}

class HomePageState extends State<HomePage> {
  @override
  void initState() {
    //loadData();
    Future.delayed(Duration.zero, () async {
      String var1 = await testfunction();
      //here is the async code, you can execute any async code here
      print(var1);
    });
    super.initState();
  }

  Future<String> testfunction() async {
    widget.user = await widget.proxyModel.getUser(widget.userID) as MPUser;
    widget.favs = await widget.proxyModel.listUserFavorites(widget.user!);
    widget.clients = await widget.proxyModel.listUserClients(widget.user!);
    print("This is test function");
    return Future(() => "abc");
  }

  loadData() async {
    widget.user = await widget.proxyModel.getUser(widget.userID);
    widget.favs = await widget.proxyModel.listUserFavorites(widget.user!);
    widget.clients = await widget.proxyModel.listUserClients(widget.user!);
    setState(() {});
  }

  Widget clientsList() {
    if (widget.clients == null) {
      return Center(
        child: Text("no clients yet"),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.clients!.isEmpty ? 0 : 3,
        itemBuilder: (BuildContext context, int index) {
          if (widget.clients!.isEmpty) {
            return Container();
          } else {
            return clientCard(context, widget.clients!.elementAt(index));
          }
        },
      );
    }
  }

  Widget favsList() {
    if (widget.favs == null) {
      return Center(
        child: Text("no favs yet"),
      );
    } else {
      return ListView.builder(
        padding: const EdgeInsets.all(8),
        physics: const NeverScrollableScrollPhysics(),
        shrinkWrap: true,
        itemCount: widget.favs!.isEmpty ? 0 : 3,
        itemBuilder: (BuildContext context, int index) {
          if (widget.favs!.isEmpty) {
            return Container();
          } else {
            return resourceCard(context, widget.favs!.elementAt(index));
          }
        },
      );
    }
  }

  Widget filterCard(IconData icon, String label) {
    return Card(
      child: InkWell(
        onTap: () {
          filters["Categories"]![label] = !filters["Categories"]![label]!;
        },
        onLongPress: () {
          resetFilters();
        },
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Row(
            children: [
              Icon(icon),
              getSpacer(10),
              Expanded(
                child: Text(
                  label,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 3,
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    //String? userEmail = FirebaseAuth.instance.currentUser?.email;
    //String? displayName = FirebaseAuth.instance.currentUser?.displayName;
    // User? user = widget.user;

    String? userName = widget.user != null ? widget.user?.name : "u";
    //String? userName = "u";

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(4.0),
          child: Image.asset("lib/assets/icon/icon.png"),
        ),
        //leading: Image(image: AssetImage('../lib/assets/icon/icon.png')),
        centerTitle: true,
        shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(bottom: Radius.circular(20))),
        title: Text("Hello, $userName"),
        actions: [
          IconButton(
              onPressed: () {
                Navigator.pushNamed(context, '/profile');
              },
              icon: const Icon(Icons.account_circle_outlined))
        ],
        //backgroundColor: const Color(0xFF2B2A2A),
        //foregroundColor: Colors.white,
      ),
      body: ListView(
        children: [
          sectionHeader("Find by Category", context),
          GridView.count(
            shrinkWrap: true,
            crossAxisCount: 3,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(8),
            childAspectRatio: 2,
            children: [
              filterCard(Icons.home_work, "Shelter"),
              filterCard(Icons.sports_kabaddi, "Domestic Violence"),
              filterCard(Icons.psychology, "Mental Health"),
              filterCard(Icons.food_bank, "Food"),
              filterCard(Icons.medical_services, "Medical Help"),
              filterCard(Icons.gavel, "Legal"),
            ],
          ),
          getDivider(context),
          sectionHeader("Recent Clients", context),
          clientsList(),
          getDivider(context),
          sectionHeader("Favorites", context),
          favsList(),
        ],
      ),
      bottomNavigationBar: customNav(context, 0),
    );
  }
}
