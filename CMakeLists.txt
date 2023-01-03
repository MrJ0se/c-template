#<inclusion if>
if (NOT FILE_CTemplate_CMAKE)
set(FILE_CTemplate_CMAKE ON)
#</inclusion if>

cmake_minimum_required(VERSION 3.10)
project(ctemplate)

include(${CMAKE_CURRENT_LIST_DIR}/common.cmake)

#<configure>
option(CTemplate_STATIC "build static lib" ON)
option(CTemplate_SHARED "build shared lib" ON)
#</configure>

#<source>
file(GLOB_RECURSE CTemplate_SRC
	LIST_DIRECTORIES false
	"${CMAKE_CURRENT_LIST_DIR}/source/*cpp"
)
set(CTemplate_INC "${CMAKE_CURRENT_LIST_DIR}/include" )
#</source>

#<build>
if(CTemplate_STATIC)
	add_library(ctemplatestatic STATIC ${CTemplate_SRC})
	target_include_directories(ctemplatestatic PUBLIC ${CTemplate_INC})
	target_compile_definitions(ctemplatestatic PRIVATE "CTemplate_LIB_BUILD=1")

	applyfix(ctemplatestatic ON OFF)
endif()
if(CTemplate_SHARED)
	add_library(ctemplate SHARED ${CTemplate_SRC})
	target_include_directories(ctemplate PUBLIC ${CTemplate_INC})
	target_compile_definitions(ctemplate PRIVATE "CTemplate_LIB_BUILD=1" "CTemplate_LIB_SHARED=1")

	applyfix(ctemplate ON ON)
endif()
#</build>

#<inclusion endif>
endif()
#</inclusion endif>