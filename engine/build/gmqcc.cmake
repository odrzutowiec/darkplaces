cmake_minimum_required(VERSION 2.8)
project(gmqcc)

set(GMQCC_PLAT_FLAGS "-std=c++11 -Wall -Wextra -fno-exceptions -fno-rtti")

set(CMAKE_CXX_FLAGS "${GMQCC_PLAT_FLAGS}")

set(OBJ_QCC
    ${ENGINE_DIR}/gmqcc/algo.h
    ${ENGINE_DIR}/gmqcc/ast.cpp
    ${ENGINE_DIR}/gmqcc/ast.h
    ${ENGINE_DIR}/gmqcc/code.cpp
    ${ENGINE_DIR}/gmqcc/conout.cpp
    ${ENGINE_DIR}/gmqcc/fold.cpp
    ${ENGINE_DIR}/gmqcc/fold.h
    ${ENGINE_DIR}/gmqcc/ftepp.cpp
    ${ENGINE_DIR}/gmqcc/gmqcc.h
    ${ENGINE_DIR}/gmqcc/intrin.cpp
    ${ENGINE_DIR}/gmqcc/intrin.h
    ${ENGINE_DIR}/gmqcc/ir.cpp
    ${ENGINE_DIR}/gmqcc/ir.h
    ${ENGINE_DIR}/gmqcc/lexer.cpp
    ${ENGINE_DIR}/gmqcc/lexer.h
    ${ENGINE_DIR}/gmqcc/opts.cpp
    ${ENGINE_DIR}/gmqcc/parser.cpp
    ${ENGINE_DIR}/gmqcc/parser.h
    ${ENGINE_DIR}/gmqcc/stat.cpp
    ${ENGINE_DIR}/gmqcc/utf8.cpp
    ${ENGINE_DIR}/gmqcc/util.cpp
)

include(${MODULE_DIR}/target/with_qcc.cmake)
