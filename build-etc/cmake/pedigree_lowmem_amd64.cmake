# Low memory build configuration for Pedigree
# Includes the regular AMD64 toolchain and adds low-memory optimizations

include(${CMAKE_CURRENT_LIST_DIR}/pedigree_amd64.cmake)

# Reduce memory usage during linking
set(CMAKE_SHARED_LINKER_FLAGS "${CMAKE_SHARED_LINKER_FLAGS} -Wl,--reduce-memory-overheads -Wl,--no-as-needed")
set(CMAKE_EXE_LINKER_FLAGS "${CMAKE_EXE_LINKER_FLAGS} -Wl,--reduce-memory-overheads -Wl,--no-as-needed")

# Reduce compiler optimization to lower memory usage during compilation
if(NOT CMAKE_BUILD_TYPE STREQUAL "Debug")
    set(CMAKE_C_FLAGS "${CMAKE_C_FLAGS} -O1")
    set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -O1")
endif()