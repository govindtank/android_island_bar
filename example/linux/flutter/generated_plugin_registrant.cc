//
//  Generated file. Do not edit.
//

// clang-format off

#include "generated_plugin_registrant.h"

#include <android_island_bar/android_island_bar_plugin.h>

void fl_register_plugins(FlPluginRegistry* registry) {
  g_autoptr(FlPluginRegistrar) android_island_bar_registrar =
      fl_plugin_registry_get_registrar_for_plugin(registry, "AndroidIslandBarPlugin");
  android_island_bar_plugin_register_with_registrar(android_island_bar_registrar);
}
