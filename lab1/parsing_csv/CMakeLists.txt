cmake_minimum_required(VERSION 3.15)

project(parser LANGUAGES C)

add_executable(parser parse.c)

add_library(csv_parser 
    libcsv/libcsv.c
    libcsv/csv.h
    )

include_directories(csv_parser)

target_link_libraries(parser csv_parser)
