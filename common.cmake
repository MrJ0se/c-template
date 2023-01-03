#c-template 0.1 > common.cmake
# comply with cct patterns

#<inclusion if>
if (NOT FILE_COMMON_CMAKE)
set(FILE_COMMON_CMAKE ON)
#</inclusion if>

set(CMAKE_CXX_STANDARD 17)
set(CMAKE_CXX_STANDARD_REQUIRED ON)
set(CMAKE_POSITION_INDEPENDENT_CODE ON)

#<help functions> use it!
# applyfix(targetname:Project islibrary:boolean isshared:boolean)
# webapp_addfuncs(targetname:Project funcs:string[])
# add_link_flags(targetname:Project flags:string)
# add_compiler_flags(targetname:Project flags:string)
macro (applyfix targetname islibrary isshared)
	if (islibrary)
		_fix_library(${targetname} ${isshared})
	else ()
		_fix_program(${targetname})
	endif()
	_fix_any(${targetname})
endmacro()
macro (webapp_addfuncs targetname funcs)
	if (EMSDK_EXPORTFUNCS__${targetname})
		set(EMSDK_EXPORTFUNCS__${targetname} ${EMSDK_EXPORTFUNCS__${targetname}} ${${funcs}})
	else()
		set(EMSDK_EXPORTFUNCS__${targetname} ${${funcs}})
	endif()
endmacro()
macro (add_link_flags targetname flags)
	get_target_property(_temp ${targetname} LINK_FLAGS)
	if("${_temp}" STREQUAL "_temp-NOTFOUND")
		set_target_properties(${targetname} PROPERTIES LINK_FLAGS "${flags}")
	else()
		set_target_properties(${targetname} PROPERTIES LINK_FLAGS "${_temp} ${flags}")
	endif()
endmacro()
macro (add_compiler_flags targetname flags)
	get_target_property(_temp ${targetname} COMPILE_FLAGS)
	if("${_temp}" STREQUAL "_temp-NOTFOUND")
		set_target_properties(${targetname} PROPERTIES COMPILE_FLAGS "${flags}")
	else()
		set_target_properties(${targetname} PROPERTIES COMPILE_FLAGS "${_temp} ${flags}")
	endif()
endmacro()
#</help functions>

#<boiler-plate> for out-of-cct scenaries
if(NOT CCT_TARGET)
	set(CC_ANDROID_LEVEL 24)
	if (ANDROID_ABI)
		set(CCT_TARGET_PLATFORM "android")
		if ("${ANDROID_ABI}" STREQUAL "armeabi-v7a")
			set(CCT_TARGET android-arm)
		elseif ("${ANDROID_ABI}" STREQUAL "arm64-v8a")
			set(CCT_TARGET android-arm64)
		elseif ("${ANDROID_ABI}" STREQUAL "x86")
			set(CCT_TARGET android-x32)
		else ()
			set(CCT_TARGET android-x64)
		endif ()
	elseif (WIN32)
		set(CCT_TARGET_PLATFORM "win32")
		set(CCT_TARGET win32-x64)
	elseif (APPLE)
		set(CCT_TARGET_PLATFORM "darwin")
		set(CCT_TARGET darwin-x64)
	else ()
		set(CCT_TARGET_PLATFORM "linux")
		set(CCT_TARGET linux-x64)
	endif ()
endif()
#</boiler-plate>

#<fixes> amd optmizations
#make NDK generate a error on no-void functions without return (the default behavior in all another compilers)
if (ANDROID_ABI)
	set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -Werror=return-type")
endif()

#remove unused code on release
if (NOT CMAKE_BUILD_TYPE EQUAL "Debug")
	if (WIN32)
		add_compile_options("/Gy" "/GF")
		add_link_options("/OPT:REF,ICF")
	else()
		add_compile_options(-fdata-sections -ffunction-sections -Wl,--gc-sections)
	endif ()
endif()

#(web) enable threads
if ("${CCT_TARGET_PLATFORM}" STREQUAL "web")
	SET(CMAKE_CXX_FLAGS  "${CMAKE_CXX_FLAGS} -pthreads -s USE_PTHREADS")
	SET(CMAKE_EXE_LINKER_FLAGS  "${CMAKE_EXE_LINKER_FLAGS} -pthreads -s USE_PTHREADS")
endif()
#</fixes>

#<internal methods>
macro (_fix_library targetname isshared)
	if (WIN32)
	else()
		if (${isshared})
			#set not export funcion as default on shared library
			set_target_properties(${targetname} PROPERTIES CXX_VISIBILITY_PRESET hidden)
		endif ()
	endif ()
endmacro ()
macro (_fix_any targetname)
	if (ANDROID_ABI)
		target_link_libraries(${targetname} log android)
	endif()
	if (UNIX OR ANDROID_ABI)
		target_link_libraries(${targetname} m)
	endif()
	if ("${CCT_TARGET_PLATFORM}" STREQUAL "uwp")
		#fix any UWP project
		set_target_properties(${targetname} PROPERTIES
			LINK_FLAGS /SUBSYSTEM:WINDOWS
			VS_WINRT_COMPONENT TRUE
		)
	endif()
endmacro()
macro (_fix_program targetname)
	if ("${CCT_TARGET_PLATFORM}" STREQUAL "web")
		_webapp_get_all_funcs(_temp ${targetname})
		list(REMOVE_DUPLICATES _temp)
		string(REGEX REPLACE "([^\\]|^);" "\\1," EMSDK_EXPORTFUNCS "${_temp}")

		add_link_flags(${targetname} "-s MODULARIZE=1 -s EXPORT_NAME=${targetname}Module -s EXPORTED_FUNCTIONS=[${EMSDK_EXPORTFUNCS}] -s EXPORTED_RUNTIME_METHODS=[\"cwrap\",\"intArrayFromString\",\"ALLOC_NORMAL\",\"allocate\",\"UTF8ToString\"] -s FULL_ES2=1 -s MAX_WEBGL_VERSION=2 -sASYNCIFY -s DISABLE_DEPRECATED_FIND_EVENT_TARGET_BEHAVIOR=1")
	endif()
endmacro ()
macro (_webapp_get_all_funcs output targetname)
	if (${EMSDK_EXPORTFUNCS__${targetname}})
		set(_temp ${EMSDK_EXPORTFUNCS__${targetname}} "_main")
	else()
		set(_temp "_main")
	endif()
	get_target_property(_templibs ${targetname} LINK_LIBRARIES)
	foreach(_templibs_item IN ITEMS ${_templibs})
		set(_temp ${_temp} ${EMSDK_EXPORTFUNCS__${_templibs_item}})
	endforeach()
endmacro()
#</internal methods>

#<inclusion endif>
endif()
#</inclusion endif>