cmake_minimum_required(VERSION 3.9 FATAL_ERROR)
Project(CUDA_Freshman CXX C CUDA)
set(CMAKE_CUDA_FLAGS "-arch=native -g -G -O3")
include_directories(./include)

add_library(${PROJECT_NAME}.common
    include/timer.cc
)

macro(subdirlist result curdir)
  file(GLOB children RELATIVE ${curdir} ${curdir}/*)
  set(dirlist "")
  foreach(child ${children})
    if(EXISTS ${curdir}/${child}/CMakeLists.txt)
      list(APPEND dirlist ${child})
    endif()
  endforeach()
  set(${result} ${dirlist})
endmacro()

subdirlist(SUBDIRS ${PROJECT_SOURCE_DIR})
foreach(subdir ${SUBDIRS})
    add_subdirectory(${subdir})
endforeach()

