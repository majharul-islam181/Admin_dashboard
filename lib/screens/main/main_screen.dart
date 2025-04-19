import 'package:admin/controllers/menu_app_controller.dart';
import 'package:admin/responsive.dart';
import 'package:admin/screens/dashboard/dashboard_screen.dart';
import 'package:admin/screens/settingScreen/setting_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'components/side_menu.dart';

// class MainScreen extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       key: context.read<MenuAppController>().scaffoldKey,
//       drawer: SideMenu(),
//       body: SafeArea(
//         child: Row(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // We want this side menu only for large screen
//             if (Responsive.isDesktop(context))
//               Expanded(
//                 // default flex = 1
//                 // and it takes 1/6 part of the screen
//                 child: SideMenu(),
//               ),
//             Expanded(
//               // It takes 5/6 part of the screen
//               flex: 5,
//               child: DashboardScreen(),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }


class MainScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final selectedIndex = context.watch<MenuAppController>().selectedIndex;

    Widget getCurrentScreen() {
      switch (selectedIndex) {
        case 0:
          return DashboardScreen();
        // case 1:
        //   return TransactionScreen();
        // case 2:
        //   return OrderHistoryScreen();
        // case 3:
        //   return NotificationScreen();
        // case 4:
        //   return ProfileScreen();
        case 1:
          return SettingScreen();
        default:
          return DashboardScreen();
      }
    }

    return Scaffold(
      key: context.read<MenuAppController>().scaffoldKey,
      drawer: const SideMenu(),
      body: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (Responsive.isDesktop(context))
              const Expanded(child: SideMenu()),
            Expanded(
              flex: 5,
              child: getCurrentScreen(),
            ),
          ],
        ),
      ),
    );
  }
}

