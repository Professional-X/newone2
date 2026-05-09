import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';

import '/ui/screens/Home/home_screen_controller.dart';
import '/ui/screens/Settings/settings_screen_controller.dart';
import '../ui/player/player_controller.dart';
import '../ui/player/player.dart';
import '../utils/helper.dart';
import '../ui/navigator.dart';

import 'widgets/bottom_nav_bar.dart';
import 'widgets/scroll_to_hide.dart';
import 'widgets/sliding_up_panel.dart';
import 'widgets/snackbar.dart';
import 'widgets/up_next_queue.dart';
import 'widgets/admob_banner.dart';
import 'player/components/mini_player.dart';

class Home extends StatelessWidget {
  const Home({super.key});
  static const routeName = '/appHome';

  @override
  Widget build(BuildContext context) {
    printINFO("Home");

    // 🟢 SAFE CONTROLLER ACCESS (NO CRASH)
    final playerController =
        Get.isRegistered<PlayerController>()
            ? Get.find<PlayerController>()
            : Get.put(PlayerController());

    final settingsScreenController =
        Get.isRegistered<SettingsScreenController>()
            ? Get.find<SettingsScreenController>()
            : Get.put(SettingsScreenController());

    final homeScreenController =
        Get.isRegistered<HomeScreenController>()
            ? Get.find<HomeScreenController>()
            : Get.put(HomeScreenController());

    final size = MediaQuery.of(context).size;
    final isWideScreen = size.width > 800;

    if (!playerController.initFlagForPlayer &&
        settingsScreenController.isBottomNavBarEnabled.isFalse) {
      playerController.playerPanelMinHeight.value =
          isWideScreen ? 105 + Get.mediaQuery.padding.bottom : 75 + Get.mediaQuery.padding.bottom;
    }

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        if (playerController.playerPanelController.isPanelOpen) {
          playerController.playerPanelController.close();
          return;
        }

        final navState = Get.nestedKey(ScreenNavigationSetup.id)?.currentState;

        if (navState != null && navState.canPop()) {
          navState.pop();
          return;
        }

        if (homeScreenController.tabIndex.value != 0) {
          settingsScreenController.isBottomNavBarEnabled.isTrue
              ? homeScreenController.onBottonBarTabSelected(0)
              : homeScreenController.onSideBarTabSelected(0);
          return;
        }

        if (playerController.buttonState.value == PlayButtonState.playing) {
          SystemNavigator.pop();
          return;
        }

        // 🟢 SAFE AUDIO SAVE SESSION
        try {
          if (Get.isRegistered<AudioHandler>()) {
            await Get.find<AudioHandler>().customAction("saveSession");
          }
        } catch (_) {}

        exit(0);
      },

      child: Obx(
        () => Scaffold(
          bottomNavigationBar:
              settingsScreenController.isBottomNavBarEnabled.isTrue
                  ? ScrollToHideWidget(
                      isVisible:
                          homeScreenController.isHomeSreenOnTop.isTrue &&
                              playerController.isPanelGTHOpened.isFalse,
                      child: const BottomNavBar(),
                    )
                  : null,

          key: playerController.homeScaffoldkey,

          endDrawer: GetPlatform.isDesktop || isWideScreen
              ? Container(
                  constraints: const BoxConstraints(maxWidth: 600),
                  margin: const EdgeInsets.only(top: 5, bottom: 106),
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        color: Theme.of(context).canvasColor,
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text("${playerController.currentQueue.length} songs"),
                              Text("Up Next"),
                              Row(
                                children: [
                                  IconButton(
                                    onPressed: playerController.toggleQueueLoopMode,
                                    icon: const Icon(Icons.loop),
                                  ),
                                  IconButton(
                                    onPressed: playerController.shuffleQueue,
                                    icon: const Icon(Icons.shuffle),
                                  ),
                                  IconButton(
                                    onPressed: playerController.clearQueue,
                                    icon: const Icon(Icons.clear),
                                  ),
                                ],
                              )
                            ],
                          ),
                        ),
                      ),
                      const Expanded(
                        child: UpNextQueue(isQueueInSlidePanel: false),
                      ),
                    ],
                  ),
                )
              : null,

          body: Obx(
            () => SlidingUpPanel(
              controller: playerController.playerPanelController,
              minHeight: playerController.playerPanelMinHeight.value,
              maxHeight: size.height,
              isDraggable: !isWideScreen,
              onPanelSlide: playerController.panellistener,
              onSwipeUp: playerController.queuePanelController.open,
              panel: const Player(),
              body: Column(
                children: [
                  const Expanded(child: ScreenNavigation()),
                  const AdmobBanner(),
                ],
              ),
              header: !isWideScreen
                  ? InkWell(
                      onTap: playerController.playerPanelController.open,
                      child: const MiniPlayer(),
                    )
                  : const MiniPlayer(),
            ),
          ),
        ),
      ),
    );
  }
}
