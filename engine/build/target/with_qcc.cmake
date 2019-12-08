add_library(gmqcclib ${OBJ_QCC})

add_executable(gmqcc ${ENGINE_DIR}/gmqcc/main.cpp)
target_link_libraries(gmqcc gmqcclib)

add_executable(testsuite ${ENGINE_DIR}/gmqcc/test.cpp)
target_link_libraries(testsuite gmqcclib)

add_executable(qcvm ${ENGINE_DIR}/gmqcc/exec.cpp)
target_link_libraries(qcvm gmqcclib)
