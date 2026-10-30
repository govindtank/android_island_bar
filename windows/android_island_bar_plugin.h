#ifndef FLUTTER_PLUGIN_ANDROID_ISLAND_BAR_PLUGIN_H_
#define FLUTTER_PLUGIN_ANDROID_ISLAND_BAR_PLUGIN_H_

#include <flutter/method_channel.h>
#include <flutter/plugin_registrar_windows.h>

#include <memory>

namespace android_island_bar {

class AndroidIslandBarPlugin : public flutter::Plugin {
 public:
  static void RegisterWithRegistrar(flutter::PluginRegistrarWindows *registrar);

  AndroidIslandBarPlugin();

  virtual ~AndroidIslandBarPlugin();

  // Disallow copy and assign.
  AndroidIslandBarPlugin(const AndroidIslandBarPlugin&) = delete;
  AndroidIslandBarPlugin& operator=(const AndroidIslandBarPlugin&) = delete;

  // Called when a method is called on this plugin's channel from Dart.
  void HandleMethodCall(
      const flutter::MethodCall<flutter::EncodableValue> &method_call,
      std::unique_ptr<flutter::MethodResult<flutter::EncodableValue>> result);
};

}  // namespace android_island_bar

#endif  // FLUTTER_PLUGIN_ANDROID_ISLAND_BAR_PLUGIN_H_
