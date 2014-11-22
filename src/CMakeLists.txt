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

target_link_libraries (${EXEC_NAME} ${DEPS_LIBRARIES})

install (TARGETS ${EXEC_NAME} RUNTIME DESTINATION ${CMAKE_INSTALL_FULL_BINDIR})
