cmake_minimum_required(VERSION 3.12)
project(service_template CXX)

set(USERVER_FEATURE_POSTGRESQL ON CACHE BOOL "" FORCE)
set(USERVER_FEATURE_CRYPTOPP_BLAKE2 OFF CACHE BOOL "" FORCE)
set(USERVER_FEATURE_GRPC_CHANNELZ OFF CACHE BOOL "" FORCE)
set(USERVER_FEATURE_REDIS_HI_MALLOC ON CACHE BOOL "" FORCE)
set(USERVER_FEATURE_PATCH_LIBPQ OFF CACHE BOOL "" FORCE)
if (NOT DEFINED service_template_CLANG_FORMAT)
    set(service_template_CLANG_FORMAT "" CACHE STRING "clang format used by userver chaotic")
endif()
message(STATUS "service_template_CLANG_FORMAT: ${service_template_CLANG_FORMAT}")
include (cmake/deps.cmake)

file(GLOB_RECURSE SCHEMAS ${CMAKE_CURRENT_SOURCE_DIR}/schemas/*.yaml)
userver_target_generate_chaotic(${PROJECT_NAME}-gen
    ARGS
        # Map '/components/schemas/*' JSONSchema types to C++ types in 'samples::hello' namespace
        -n "/components/schemas/([^/]*)/=codegen::{0}"
        -f "(.*)={0}"
        # Don't call clang-format
        --clang-format=${service_template_CLANG_FORMAT}
        # Generate serializers for responses
        --generate-serializers
    OUTPUT_DIR
        ${CMAKE_CURRENT_BINARY_DIR}/codegen
    SCHEMAS
        ${SCHEMAS}
    RELATIVE_TO
        ${CMAKE_CURRENT_SOURCE_DIR}
)
userver_setup_environment()



file(GLOB_RECURSE OBJS ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
# Common sources
add_library(${PROJECT_NAME}_objs OBJECT
   ${OBJS}
)
target_include_directories(${PROJECT_NAME}_objs PUBLIC src)
target_link_libraries(${PROJECT_NAME}_objs PUBLIC userver::postgresql ${PROJECT_NAME}-gen)

# The Service
add_executable(${PROJECT_NAME} service/main.cpp)
target_link_libraries(${PROJECT_NAME} PRIVATE ${PROJECT_NAME}_objs)


file(GLOB_RECURSE UNIT_TESTS ${CMAKE_CURRENT_SOURCE_DIR}/unit_tests/*.cpp)
# Unit Tests
add_executable(${PROJECT_NAME}_unittest
    ${UNIT_TESTS}
)
target_link_libraries(${PROJECT_NAME}_unittest PRIVATE ${PROJECT_NAME}_objs userver::utest)
add_google_tests(${PROJECT_NAME}_unittest)


file(GLOB_RECURSE BENCHS ${CMAKE_CURRENT_SOURCE_DIR}/benchs/*.cpp)
# Benchmarks
add_executable(${PROJECT_NAME}_benchmark
    ${BENCHS}
)
target_link_libraries(${PROJECT_NAME}_benchmark PRIVATE ${PROJECT_NAME}_objs userver::ubench)
#add_google_benchmark_tests(${PROJECT_NAME}_benchmark) uncomment if you want run benchmark with tests


# Functional Tests
include(UserverTestsuite)

userver_testsuite_add_simple()

