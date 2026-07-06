import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'home_controller.dart';
import '../history/history_view.dart';
import '../settings/settings_view.dart';
import 'widgets/calculator_view.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() => IndexedStack(
            index: controller.tipController.selectedIndex.value,
            children: const [
              CalculatorView(),
              HistoryView(),
              SettingsView(),
            ],
          )),
      bottomNavigationBar: Obx(() => BottomNavigationBar(
            currentIndex: controller.tipController.selectedIndex.value,
            onTap: (index) => controller.changeTab(index),
            selectedItemColor: Theme.of(context).primaryColor,
            type: BottomNavigationBarType.fixed,
            items: [
              BottomNavigationBarItem(icon: const Icon(Icons.calculate), label: 'calculator'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.history), label: 'history'.tr),
              BottomNavigationBarItem(icon: const Icon(Icons.settings), label: 'settings'.tr),
            ],
          )),
    );
  }
}
