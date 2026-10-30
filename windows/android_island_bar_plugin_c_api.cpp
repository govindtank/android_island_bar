#include "include/android_island_bar/android_island_bar_plugin_c_api.h"

#include <flutter/plugin_registrar_windows.h>

#include "android_island_bar_plugin.h"

void AndroidIslandBarPluginCApiRegisterWithRegistrar(
    FlutterDesktopPluginRegistrarRef registrar) {
  android_island_bar::AndroidIslandBarPlugin::RegisterWithRegistrar(
      flutter::PluginRegistrarManager::GetInstance()
          ->GetRegistrar<flutter::PluginRegistrarWindows>(registrar));
}
