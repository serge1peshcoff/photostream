install (FILES photostream.desktop DESTINATION ${APPLICATIONS_DIR})
install (CODE
"execute_process (COMMAND update-desktop-database)"
)