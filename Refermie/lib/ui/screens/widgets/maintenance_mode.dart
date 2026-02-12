import 'package:ebroker/exports/main_export.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class MaintenanceMode extends StatelessWidget {
  const MaintenanceMode({super.key});
  static Route<dynamic> route(RouteSettings settings) {
    return CupertinoPageRoute(
      builder: (context) {
        return const MaintenanceMode();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.color.primaryColor,
      body: Column(
        mainAxisAlignment: .center,
        children: [
          Lottie.asset(
            'assets/lottie/${Constant.maintenanceModeLottieFile}',
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: CustomText(
              'maintenanceModeMessage'.translate(context),
              textAlign: .center,
              color: context.color.textColorDark,
            ),
          ),
        ],
      ),
    );
  }
}
