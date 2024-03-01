add_executable(sum_arrays sum_arrays.cu)
target_link_libraries(sum_arrays
        ${PROJECT_NAME}.common
        glog
)