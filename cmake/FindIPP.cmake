IF( NOT IPP_FOUND )

  OPTION(IPP_PREFER_SHARED_LIBRARIES "Prefer shared over static libraries." ON)

  set( CMAKE_LIB_ARCH_APPENDIX "" )
	set( CMAKE_MT_LIB_ARCH_APPENDIX "" )

	if( WIN32 )  
    message(STATUS "WIN32")
		if( CMAKE_SIZEOF_VOID_P EQUAL 8 )
			set( HAVE_64_BIT 1 )
			set( CMAKE_LIB_ARCH_APPENDIX "em64t" )
		else( CMAKE_SIZEOF_VOID_P EQUAL 8 )
			set( HAVE_64_BIT 0 )
		endif( CMAKE_SIZEOF_VOID_P EQUAL 8 )
	else( WIN32 )
    if(APPLE)
			set( CMAKE_LIB_ARCH_APPENDIX "" )
			set( CMAKE_MT_LIB_ARCH_APPENDIX "_t" )
      if (CMAKE_SIZEOF_VOID_P MATCHES "8")
        MESSAGE("Mac 64")
  			set( HAVE_64_BIT 1 )
      else()
        MESSAGE("Mac 32")
  			set( HAVE_64_BIT 0 )
      endif (CMAKE_SIZEOF_VOID_P MATCHES "8")
    else(APPLE)
      if (CMAKE_SIZEOF_VOID_P MATCHES "8")
        MESSAGE("Linux 64")
		  	set( HAVE_64_BIT 1 )
			  set( CMAKE_LIB_ARCH_APPENDIX "em64t" )
			  set( CMAKE_MT_LIB_ARCH_APPENDIX "em64t_t" )
      else()
        MESSAGE("Linux 32")
			  set( HAVE_64_BIT 0 )
      endif (CMAKE_SIZEOF_VOID_P MATCHES "8")
    endif(APPLE)
	endif(WIN32)

  #
  # Find absolute path to all libraries!
  #
  # we prefer shared over static libraries. If one does want to use static
  # libraries set the flag correctly.

  # set possible library paths depending on the platform architecture.
  if(HAVE_64_BIT)
    set(IPP_POSSIBLE_INCLUDE_DIRS "em64t/include" "include")
    set(IPP_POSSIBLE_SHARED_LIB_DIRS "em64t/stublib" "em64t/sharedlib" "lib")
    set(IPP_POSSIBLE_STATIC_LIB_DIRS "em64t/stublib" "em64t/lib" "lib")
    message( STATUS "FOUND 64 BIT SYSTEM")
  else()
    set(IPP_POSSIBLE_INCLUDE_DIRS "ia32/include")
    set(IPP_POSSIBLE_SHARED_LIB_DIRS "ia32/stublib" "ia32/sharedlib")
    set(IPP_POSSIBLE_STATIC_LIB_DIRS "ia32/stublib" "ia32/lib")
    message( STATUS "FOUND 32 BIT SYSTEM")
  endif()

  # possible include and library paths
  FILE(GLOB IPP_PATH_0 "$ENV{ProgramFiles}/Intel/IPP/*.*")
  FILE(GLOB IPP_PATH_1 "/opt/intel/ipp/*.*")
  FILE(GLOB IPP_PATH_2 "/usr/local/intel/ipp/*.*")

  SET( IPP_PATH
	  ${IPP_PATH_0}
	  ${IPP_PATH_1}
	  ${IPP_PATH_2}
	  $ENV{IPPROOT}
	  $ENV{IPP_ROOT}
	  )

  # find include path
  FIND_PATH(IPP_INCLUDE_DIR 
    "ippi.h" 
    PATHS ${IPP_PATH} 
    PATH_SUFFIXES ${IPP_POSSIBLE_INCLUDE_DIRS})

  message("IPP_INCLUDE_DIR=${IPP_INCLUDE_DIR}")


  FILE(GLOB IPP_LIBRARY_PATHS_0 "$ENV{ProgramFiles}/Intel/IPP/*.*")
  FILE(GLOB IPP_LIBRARY_PATHS_1 "/opt/intel/ipp/*.*")
  FILE(GLOB IPP_LIBRARY_PATHS_2 "/usr/local/intel/ipp/*.*")

  #
  ## SETUP SHARED LIBRARIES
  #
  
  FIND_LIBRARY( IPP_SHARED_IPPAC    NAMES    ippac${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPCC    NAMES    ippcc${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPCH    NAMES    ippch${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPCOREL NAMES    ippcore${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPCV    NAMES    ippcv${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPDC    NAMES    ippdc${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPI     NAMES    ippi${CMAKE_LIB_ARCH_APPENDIX}    PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPJ     NAMES    ippj${CMAKE_LIB_ARCH_APPENDIX}    PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPM     NAMES    ippm${CMAKE_LIB_ARCH_APPENDIX}    PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPS     NAMES    ipps${CMAKE_LIB_ARCH_APPENDIX}    PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPSC    NAMES    ippsc${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPSR    NAMES    ippsr${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPVC    NAMES    ippvc${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  FIND_LIBRARY( IPP_SHARED_IPPVM    NAMES    ippvm${CMAKE_LIB_ARCH_APPENDIX}   PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
  if(WIN32)
	  FIND_LIBRARY( IPP_SHARED_IOMP5    NAMES    libiomp5md  PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH) 
  else()
	  FIND_LIBRARY( IPP_SHARED_IOMP5    NAMES    iomp5       PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH)
	  FIND_LIBRARY( IPP_SHARED_EXT_PTHREAD NAMES pthread )
    FIND_LIBRARY( IPP_SHARED_EXT_M NAMES m )
  endif()
  

  SET(
    IPP_SHARED_LIBRARIES
    ${IPP_SHARED_IPPAC}
    ${IPP_SHARED_IPPCC}
    ${IPP_SHARED_IPPCH}
    ${IPP_SHARED_IPPCOREL}
    ${IPP_SHARED_IPPCV}
    ${IPP_SHARED_IPPDC}
    ${IPP_SHARED_IPPI}
    ${IPP_SHARED_IPPJ}
    ${IPP_SHARED_IPPM}
    ${IPP_SHARED_IPPS}
    ${IPP_SHARED_IPPSC}
    #${IPP_SHARED_IPPSR}
    ${IPP_SHARED_IPPVC}
    ${IPP_SHARED_IPPVM}
    #${IPP_SHARED_IOMP5}
    ${IPP_SHARED_EXT_PTHREAD}
    ${IPP_SHARED_EXT_M}
    )

  #
  ## SETUP STATIC LIBRARIES
  #

  FIND_LIBRARY(IPP_IPPACEMERGED NAMES ippacemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCCEMERGED NAMES ippccemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCHEMERGED NAMES ippchemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCVEMERGED NAMES ippcvemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPDCEMERGED NAMES ippdcemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPDIEMERGED NAMES ippdiemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPGENEMERGED NAMES ippgenemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPIEMERGED NAMES ippiemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPJEMERGED NAMES ippjemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPMEMERGED NAMES ippmemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPREMERGED NAMES ippremerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSCEMERGED NAMES ippscemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSEMERGED NAMES ippsemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSREMERGED NAMES ippsremerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPVCEMERGED NAMES ippvcemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPVMEMERGED NAMES ippvmemerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPACMERGED_T NAMES ippacmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCCMERGED NAMES ippccmerged${CMAKE_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCHMERGED_T NAMES ippchmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCVMERGED_T NAMES ippcvmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPDCMERGED_T NAMES ippdcmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPDIMERGED_T NAMES ippdimerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPGENMERGED_T NAMES ippgenmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPIMERGED_T NAMES ippimerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPJMERGED_T NAMES ippjmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPMMERGED_T NAMES ippmmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPRMERGED_T NAMES ipprmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSCMERGED_T NAMES ippscmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSMERGED_T NAMES ippsmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPSRMERGED_T NAMES ippsrmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPVCMERGED_T NAMES ippvcmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPVMMERGED_T NAMES ippvmmerged${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  FIND_LIBRARY(IPP_IPPCORE_T NAMES ippcore${CMAKE_MT_LIB_ARCH_APPENDIX} PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS})
  if(WIN32)
	  FIND_LIBRARY( IPP_SHARED_IOMP5    NAMES    libiomp5md  PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_SHARED_LIB_DIRS}  NO_DEFAULT_PATH) 
  else()
	  FIND_LIBRARY( IPP_STATIC_IOMP5    NAMES    iomp5       PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS}  NO_DEFAULT_PATH)
	  # FIND_LIBRARY( IPP_SHARED_EXT_PTHREAD NAMES pthread )
    # FIND_LIBRARY( IPP_SHARED_EXT_M NAMES m )
  endif()

  # FIND_LIBRARY( IPP_IOMP5          NAMES iomp5                                      PATHS ${IPP_PATH} PATH_SUFFIXES ${IPP_POSSIBLE_STATIC_LIB_DIRS} )
  FIND_LIBRARY( IPP_STATIC_EXT_PTHREAD NAMES pthread_nonshared )

  # libircmt 
  # svml_dispmt
  # libmmt
  # libiomp5md


  SET(
    IPP_STATIC_LIBRARIES
    ${IPP_IPPACEMERGED}
    ${IPP_IPPCCEMERGED}
    ${IPP_IPPCHEMERGED}
    ${IPP_IPPCVEMERGED}
    ${IPP_IPPDCEMERGED}
    ${IPP_IPPDIEMERGED}
    ${IPP_IPPGENEMERGED}
    ${IPP_IPPIEMERGED}
    ${IPP_IPPJEMERGED}
    ${IPP_IPPMEMERGED}
    ${IPP_IPPREMERGED}
    ${IPP_IPPSCEMERGED}
    ${IPP_IPPSEMERGED}
    ${IPP_IPPSREMERGED}
    ${IPP_IPPVCEMERGED}
    ${IPP_IPPVMEMERGED}
    ${IPP_IPPACMERGED_T}
    ${IPP_IPPCCMERGED}
    ${IPP_IPPCHMERGED_T}
    ${IPP_IPPCVMERGED_T}
    ${IPP_IPPDCMERGED_T}
    ${IPP_IPPDIMERGED_T}
    ${IPP_IPPGENMERGED_T}
    ${IPP_IPPIMERGED_T}
    ${IPP_IPPJMERGED_T}
    ${IPP_IPPMMERGED_T}
    ${IPP_IPPRMERGED_T}
    ${IPP_IPPSCMERGED_T}
    ${IPP_IPPSMERGED_T}
    ${IPP_IPPSRMERGED_T}
    ${IPP_IPPVCMERGED_T}
    ${IPP_IPPVMMERGED_T}
    ${IPP_IPPCORE_T}  
    ${IPP_STATIC_IOMP5}
    # ${IPP_SHARED_EXT_PTHREAD}
    # ${IPP_SHARED_EXT_M}
    # ${IPP_IOMP5}
    ${IPP_STATIC_EXT_PTHREAD}
    )

  
  if(IPP_PREFER_SHARED_LIBRARIES)
    set( IPP_LIBRARIES ${IPP_SHARED_LIBRARIES})
  elseif(IPP_PREFER_SHARED_LIBRARIES)
    set( IPP_LIBRARIES ${IPP_STATIC_LIBRARIES})
  endif(IPP_PREFER_SHARED_LIBRARIES)

  mark_as_advanced(
    IPP_INCLUDE_DIR
    IPP_SHARED_LIBRARIES
    IPP_STATIC_LIBRARIES
    IPP_LIBRARIES
    )

  # message(STATUS "IPP_INCLUDE_DIR=${IPP_INCLUDE_DIR}")
  # message(STATUS "IPP_SHARED_LIBRARIES=${IPP_SHARED_LIBRARIES}")
  # message(STATUS "IPP_STATIC_LIBRARIES=${IPP_STATIC_LIBRARIES}")
  # message(STATUS "IPP_LIBRARIES=${IPP_LIBRARIES}")

  SET( IPP_FOUND 0 )
  IF( IPP_INCLUDE_DIR )
    SET( IPP_FOUND 1 )
	  ADD_DEFINITIONS( -DHAVE_IPP )
    
    if(NOT IPP_FIND_QUITELY)
      message(STATUS "Found IPP:")
      message(STATUS "      IPP_INCLUDE_DIR = ${IPP_INCLUDE_DIR}")
      #message(STATUS "      IPP_LIBRARY_DIR = ${IPP_LIBRARY_DIR}")
      message(STATUS "      IPP_LIBRARIES   = ${IPP_LIBRARIES}")
    endif(NOT IPP_FIND_QUITELY)
  #  message(STATUS "  IPP_PATH=${IPP_PATH}")
  # message(STATUS "  IPP_POSSIBLE_SHARED_LIB_DIRS=${IPP_POSSIBLE_SHARED_LIB_DIRS}")
  # message(STATUS "  IPP_POSSIBLE_STATIC_LIB_DIRS=${IPP_POSSIBLE_STATIC_LIB_DIRS}")

    INCLUDE_DIRECTORIES(${IPP_INCLUDE_DIR})
  ELSE( IPP_INCLUDE_DIR )
    if(NOT IPP_FIND_QUITELY)
      message(STATUS "NOT found IPP")
    endif(NOT IPP_FIND_QUITELY)
  ENDIF( IPP_INCLUDE_DIR )

ENDIF( NOT IPP_FOUND )
