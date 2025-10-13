cmake_minimum_required(VERSION 3.10)

project(MyDocumentation LANGUAGES NONE)

add_custom_target(
    readme ALL
    COMMAND cat README.md
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR} # Set correct path where main.go is located
)
