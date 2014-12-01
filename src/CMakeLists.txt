set(CLIENT_SOURCE
    main.vala
    PhotoStream.vala
    MainWindow.vala
    LoginWindow.vala
    Networking.vala
    JsonParse.vala
    NewsParse.vala
    Utils/Debug.vala
    Utils/Objects.vala
    Utils/Settings.vala 
    Utils/TagsWrapping.vala
    Widgets/PhotoStack.vala  
    Widgets/PostList.vala
    Widgets/PostBox.vala
    Widgets/UserWindowBox.vala
    Widgets/CommentsList.vala
    Widgets/CommentsBox.vala
    Widgets/HashTagList.vala
    Widgets/HashTagBox.vala
    Widgets/UserList.vala
    Widgets/UserBox.vala
    Widgets/MediaWindow.vala
    Widgets/HashTagFeedBox.vala
    Widgets/LocationFeedBox.vala
    Widgets/LocationMapWindow.vala
)

set (CLIENT_VALAC_OPTIONS
  ${GLOBAL_VALAC_OPTIONS}
  --define=USE_GRANITE_DECORATED_WINDOW
  #--define=HAVE_ADD_PLAYLIST_AS_BUTTON
  #--define=HAVE_SMART_ALBUM_COLUMN
  #--define=ENABLE_EXPERIMENTAL
)

set (CLIENT_VAPI ${SRC_TARGET})

vala_precompile (CLIENT_VALA_C ${SRC_TARGET}
  ${CLIENT_SOURCE}
  PACKAGES
  ${CORE_PKG}
  OPTIONS
  ${CLIENT_VALAC_OPTIONS}
  GENERATE_VAPI
  ${CLIENT_VAPI}
  GENERATE_HEADER
  ${CLIENT_VAPI}
)

set (EXEC_NAME ${SRC_TARGET})

add_definitions (${DEPS_CFLAGS})
link_directories (${DEPS_LIBRARY_DIRS})

add_executable (${EXEC_NAME} ${CLIENT_VALA_C})

execute_process(COMMAND pkg-config --cflags gstreamer-1.0 OUTPUT_VARIABLE CMAKE_C_FLAGS)
string(REPLACE "\n" "" CMAKE_C_FLAGS ${CMAKE_C_FLAGS})
message("CMAKE_C_FLAGS: ${CMAKE_C_FLAGS}")

execute_process(COMMAND pkg-config --libs gstreamer-1.0 OUTPUT_VARIABLE CMAKE_LINK_FLAGS)
string(REPLACE "\n" "" CMAKE_LINK_FLAGS ${CMAKE_LINK_FLAGS})
message("CMAKE_LINK_FLAGS: ${CMAKE_LINK_FLAGS}")

set_target_properties(${EXEC_NAME} 
                      PROPERTIES COMPILE_FLAGS ${CMAKE_C_FLAGS}
                                 LINK_FLAGS ${CMAKE_LINK_FLAGS})

target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
