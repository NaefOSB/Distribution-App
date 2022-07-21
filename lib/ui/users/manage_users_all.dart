import 'package:flutter/material.dart';
import 'package:store/ui/users/manage_users_single_level.dart';
import 'manage_users_multi_levels.dart';

class ManageUsersAll extends StatefulWidget {
  var length;
  var userLevel;

  ManageUsersAll({this.length,this.userLevel});

  @override
  _ManageUsersAllState createState() => _ManageUsersAllState();
}

class _ManageUsersAllState extends State<ManageUsersAll>
    with SingleTickerProviderStateMixin {
  TabController _tabController;

  @override
  void initState() {
    super.initState();

    _tabController = TabController(length: widget.length, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text('إدارة المستخدمين',style: TextStyle(color: Colors.white),),
          centerTitle: true,
          leading: IconButton(
            onPressed: () => Navigator.pop(context),
            icon: Icon(Icons.arrow_back_ios,color: Colors.white,),
          ),
          brightness: Brightness.dark,
          bottom: TabBar(
            controller: _tabController,
            labelColor: Colors.white,
            tabs: (widget.length == 2)
                ? [
                    Tab(
                      text: 'المستخدمين',
                      icon: Icon(Icons.group),
                    ),
                    Tab(
                      text: 'عمالي',
                      icon: Icon(Icons.supervisor_account),
                    ),
                  ]
                : [
                    Tab(
                      text: 'المستخدمين',
                      icon: Icon(Icons.group),
                    ),
                    Tab(
                      text: 'الموظفين',
                      icon: Icon(Icons.supervisor_account),
                    ),
                    Tab(
                      text: 'المدراء',
                      icon: Icon(Icons.person),
                    ),
                  ],
          ),
        ),
        body: TabBarView(
          controller: _tabController,
          children: (widget.length == 2)
              ? [
                  //For Level 1
                  ManageUsersMultiLevels(userLevel: widget.userLevel,), // to manage level 3,4
                  ManageUsersSingleLevel(
                    managed_level: 2,
                    userLevel: widget.userLevel,
                  ), // to manage level 2
                ]
              : [
                  // For Level 0
                  ManageUsersMultiLevels(userLevel: widget.userLevel,), // to manage level 3,4
                  ManageUsersSingleLevel(
                    managed_level: 2,
                    userLevel: widget.userLevel,
                  ), // to manage level 2
                  ManageUsersSingleLevel(
                    managed_level: 1,
                    userLevel: widget.userLevel,
                  ), // to manage level 1
                ],
        ),
      ),
    );
  }
}
