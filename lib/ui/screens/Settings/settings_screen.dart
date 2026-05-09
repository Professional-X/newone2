import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:musify/utils/helper.dart';
import 'package:musify/utils/lang_mapping.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../widgets/common_dialog_widget.dart';
import '../../widgets/cust_switch.dart';
import '../../widgets/export_file_dialog.dart';
import '../../widgets/backup_dialog.dart';
import '../../widgets/restore_dialog.dart';
import '../Library/library_controller.dart';
import '../../widgets/snackbar.dart';
import '/ui/widgets/link_piped.dart';
import '/services/music_service.dart';
import '/ui/player/player_controller.dart';
import '/ui/utils/theme_controller.dart';
import 'components/custom_expansion_tile.dart';
import 'settings_screen_controller.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({
    super.key,
    this.isBottomNavActive = false,
  });

  final bool isBottomNavActive;

  @override
  Widget build(BuildContext context) {
    final settingsController = Get.find<SettingsScreenController>();
    final topPadding = context.isLandscape ? 50.0 : 90.0;
    final isDesktop = GetPlatform.isDesktop;

    return Padding(
      padding: isBottomNavActive
          ? EdgeInsets.only(left: 20, top: topPadding, right: 15)
          : EdgeInsets.only(top: topPadding, left: 5, right: 5),
      child: Column(
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "settings".tr,
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ),

          Expanded(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(bottom: 200, top: 20),
              children: [
                Obx(
                  () => settingsController.isNewVersionAvailable.value
                      ? ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          tileColor:
                              Theme.of(context).colorScheme.secondary,
                          leading: const CircleAvatar(
                            child: Icon(Icons.download),
                          ),
                          title: Text("newVersionAvailable".tr),
                          subtitle: Text(
                            "goToDownloadPage".tr,
                            style: Theme.of(context)
                                .textTheme
                                .bodyMedium!
                                .copyWith(
                                    color: Colors.white70, fontSize: 13),
                          ),
                          onTap: () {},
                        )
                      : const SizedBox.shrink(),
                ),

                CustomExpansionTile(
                  title: "personalisation".tr,
                  icon: Icons.palette,
                  children: [
                    ListTile(
                      title: Text("themeMode".tr),
                      subtitle: Obx(
                        () => Text(
                          settingsController.themeModetype.value ==
                                  ThemeType.dynamic
                              ? "dynamic".tr
                              : settingsController.themeModetype.value ==
                                      ThemeType.system
                                  ? "systemDefault".tr
                                  : settingsController.themeModetype.value ==
                                          ThemeType.dark
                                      ? "dark".tr
                                      : "light".tr,
                        ),
                      ),
                      onTap: () {},
                    ),

                    ListTile(
                      title: Text("language".tr),
                      subtitle: Text("languageDes".tr),
                      trailing: Obx(
                        () => DropdownButton(
                          value: settingsController
                              .currentAppLanguageCode.value,
                          items: langMap.entries
                              .map(
                                (lang) => DropdownMenuItem(
                                  value: lang.key,
                                  child: Text(lang.value),
                                ),
                              )
                              .toList(),
                          onChanged: settingsController.setAppLanguage,
                        ),
                      ),
                    ),

                    if (!isDesktop)
                      ListTile(
                        title: Text("enableBottomNav".tr),
                        subtitle: Text("enableBottomNavDes".tr),
                        trailing: Obx(
                          () => CustSwitch(
                            value: settingsController
                                .isBottomNavBarEnabled.isTrue,
                            onChanged:
                                settingsController.enableBottomNavBar,
                          ),
                        ),
                      ),
                  ],
                ),

                CustomExpansionTile(
                  title: "content".tr,
                  icon: Icons.music_video,
                  children: [
                    ListTile(
                      title: Text("setDiscoverContent".tr),
                      subtitle: Obx(
                        () => Text(
                          settingsController.discoverContentType.value,
                        ),
                      ),
                      onTap: () {},
                    ),

                    ListTile(
                      title: Text("homeContentCount".tr),
                      trailing: Obx(
                        () => DropdownButton(
                          value: settingsController
                              .noOfHomeScreenContent.value,
                          items: [3, 5, 7, 9, 11]
                              .map(
                                (e) => DropdownMenuItem(
                                  value: e,
                                  child: Text("$e"),
                                ),
                              )
                              .toList(),
                          onChanged:
                              settingsController.setContentNumber,
                        ),
                      ),
                    ),
                  ],
                ),

                CustomExpansionTile(
                  title: "music&Playback".tr,
                  icon: Icons.music_note,
                  children: [
                    ListTile(
                      title: Text("streamingQuality".tr),
                      trailing: Obx(
                        () => DropdownButton(
                          value:
                              settingsController.streamingQuality.value,
                          items: [
                            DropdownMenuItem(
                              value: AudioQuality.Low,
                              child: Text("low".tr),
                            ),
                            DropdownMenuItem(
                              value: AudioQuality.High,
                              child: Text("high".tr),
                            ),
                          ],
                          onChanged:
                              settingsController.setStreamingQuality,
                        ),
                      ),
                    ),

                    if (GetPlatform.isAndroid)
                      ListTile(
                        title: Text("loudnessNormalization".tr),
                        trailing: Obx(
                          () => CustSwitch(
                            value: settingsController
                                .loudnessNormalizationEnabled.value,
                            onChanged: settingsController
                                .toggleLoudnessNormalization,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
