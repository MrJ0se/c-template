#pragma once

#if defined(DOXYGEN)

#else

#	define CTemplateFunc
#	if defined(_WIN32)
#		define FORCE_INLINE __forceinline
#		if defined(CTemplate_LIB_BUILD)
#			if defined(CTemplate_LIB_SHARED)
#				undef CTemplateFunc
#				define CTemplateFunc __declspec(dllexport)
#			endif
#		elif defined(CTemplate_LIB_SHARED)
#			undef CTemplateFunc
#			define CTemplateFunc __declspec(dllimport)
#		endif
#	else
#		define FORCE_INLINE __attribute__((always_inline))
#		if defined(CTemplate_LIB_BUILD) && defined(CTemplate_LIB_SHARED)
#			undef CTemplateFunc
#			define CTemplateFunc __attribute__((visibility("default")))
#		endif
#	endif

#	if defined(__EMSCRIPTEN__)
#		define P_WEB 1
#	elif defined(__ANDROID__)
#		define P_ANDROID 1
#	elif defined(__linux__)
#		define P_LINUX 1
#	elif defined(_WIN32)
#		include <winapifamily.h>
#		if defined(WINAPI_FAMILY) && (WINAPI_FAMILY == WINAPI_FAMILY_APP)
#			define P_UWP 1
#		else
#			define P_WINDOWS 1
#		endif
#	elif defined(__APPLE__) || defined(__OSX__)
#       include <TargetConditionals.h>
#		if defined(__OSX__) || (TARGET_OS_MAC==1)
#			define P_MAC 1
#		else
#			define P_IOS 1
#		endif
#	else
#		error Sistema não reconhecido
#	endif

#	define IS_ENUM_FLAG(EnumName) \
	inline EnumName operator|(EnumName a, EnumName b) {\
		return static_cast<EnumName>(static_cast<int>(a) | static_cast<int>(b));\
	}\
	inline EnumName operator&(EnumName a, EnumName b) {\
		return static_cast<EnumName>(static_cast<int>(a) & static_cast<int>(b));\
	}\
	inline EnumName operator^(EnumName a, EnumName b) {\
		return static_cast<EnumName>(static_cast<int>(a) ^ static_cast<int>(b));\
	} \
	inline EnumName operator|=(EnumName& a, EnumName b) {\
		a = static_cast<EnumName>(static_cast<int>(a) | static_cast<int>(b));\
		return a;\
	}\
	inline EnumName operator&=(EnumName& a, EnumName b) {\
		a = static_cast<EnumName>(static_cast<int>(a) & static_cast<int>(b));\
		return a;\
	}\
	inline EnumName operator^=(EnumName& a, EnumName b) {\
		a = static_cast<EnumName>(static_cast<int>(a) ^ static_cast<int>(b));\
		return a;\
	}

#endif