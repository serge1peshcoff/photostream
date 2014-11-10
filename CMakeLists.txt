cmake_minimum_required (VERSION 2.8)
cmake_policy (VERSION 2.8)
project (photostream)
list (APPEND CMAKE_MODULE_PATH ${CMAKE_SOURCE_DIR}/cmake) # adding cmake/ folder to find modules

#enable_testing() #don't need this one now

set (GETTEXT_PACKAGE ${CMAKE_PROJECT_NAME})
set (RELEASE_NAME "Luna")
set (VERSION "0.3.0")
set (VERSION_INFO "Stable Release")

include (GNUInstallDirs)
set (DATADIR ${CMAKE_INSTALL_PREFIX}/share) #like /usr/share
set (PKG_DATADIR ${DATADIR}/${CMAKE_PROJECT_NAME}) #like /usr/share/photostream
set (ICON_DIR ${DATADIR}/${CMAKE_PROJECT_NAME}/icons) #like /usr/share/photostream/icons
set (IMAGES_DIR ${DATADIR}/${CMAKE_PROJECT_NAME}/images) #like /usr/share/photostream/images

add_definitions ("-DGETTEXT_PACKAGE=\"${GETTEXT_PACKAGE}\"") #that is added to the compiler

# Comment this out to enable C compiler warnings
add_definitions (-w)

# Add 'make dist' command for creating release tarball
#set (CPACK_PACKAGE_VERSION ${VERSION})
#set (CPACK_SOURCE_GENERATOR "TGZ")
#set (CPACK_SOURCE_PACKAGE_FILE_NAME "${CMAKE_PROJECT_NAME}-${CPACK_PACKAGE_VERSION}")
#set (CPACK_SOURCE_IGNORE_FILES "/build/;/.bzr/;/.bzrignore;~$;${CPACK_SOURCE_IGNORE_FILES}")

#include (CPack)
#add_custom_target (dist COMMAND ${CMAKE_MAKE_PROGRAM} package_source)

set (SRC_TARGET ${CMAKE_PROJECT_NAME})

#
# *_PACKAGES are used with the vala compiler (not versioned.)
# *_PKG are used with PKG-Config and for linking, etc. (They can contain versions.)
#
# Both should contain *the same packages*, except for those whose VAPI file has
# a different name. In such case, *_PACKAGES would use the name of the VAPI while
# *_PKG would use the name of the package known by pkg-config.
#

set (CORE_PKG
  gtk+-3.0
  granite
  glib-2.0>=2.32
  gio-2.0
  json-glib-1.0
  webkitgtk-3.0
  libxml-2.0
)

find_package (PkgConfig)

pkg_check_modules (CORE_DEPS REQUIRED ${CORE_PKG})
pkg_check_modules (DEPS REQUIRED ${DEPS_PKG} ${CORE_PKG})

set (BASIC_VALAC_OPTIONS
  --vapidir=${CMAKE_SOURCE_DIR}/vapi
  --target-glib=2.32
  --thread
  # Remove it when vala bindings are no more experimental (see https://bugzilla.gnome.org/show_bug.cgi?id=719597)
  --enable-experimental
)

set (GLOBAL_VALAC_OPTIONS
  --vapidir=${CMAKE_BINARY_DIR}/core
  --vapidir=${CMAKE_BINARY_DIR}/src
  ${BASIC_VALAC_OPTIONS}
)

find_package (Vala REQUIRED)
include (ValaVersion)
ensure_vala_version ("0.23.2" MINIMUM)
include (ValaPrecompile)

set (DEPS_LIBRARIES ${DEPS_LIBRARIES} -lm)
add_subdirectory (schema)
add_subdirectory (src)
add_subdirectory (images)


# Tests

#add_test (core core/tests/noise-core_tests)