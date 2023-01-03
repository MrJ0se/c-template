cmake_minimum_required(VERSION 3.10)
project(test)

include(${CMAKE_CURRENT_LIST_DIR}/../CMakeLists.txt)

#<configure>
#</configure>

#<source>
file(GLOB_RECURSE SRC
	LIST_DIRECTORIES false
	"${CMAKE_CURRENT_LIST_DIR}/source/*cpp"
)
#</source>

#<build>
add_executable(test ${SRC})

if(CTemplate_SHARED)
	target_link_libraries(test ctemplate)
	target_compile_definitions(test PRIVATE "CTemplate_LIB_SHARED=1")
elseif(CTemplate_STATIC)
	target_link_libraries(test ctemplatestatic)
else()
	message(FATAL_ERROR "no static or dynamic library to link")
endif()
applyfix(test OFF OFF)
#</build>

#</build>