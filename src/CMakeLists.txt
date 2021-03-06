project(imageutilities_lib)
cmake_minimum_required(VERSION 2.8)

# cleanup
set(${IU_PUBLIC_HEADERS} "")
option(IU_BUILD_STATIC "Build static libs too." OFF)

# general settings
#set(CMAKE_DEBUG_POSTFIX "d")

if(NOT CMAKE_BUILD_TYPE)
	set(CMAKE_BUILD_TYPE "RelWithDebInfo" CACHE STRING "Choose the type of build, options are: Debug Release RelWithDebInfo MinSizeRel." FORCE)
endif()
#set(CMAKE_CONFIGURATION_TYPES "Debug;RelWithDebInfo" CACHE STRING "Multiple Configurations" FORCE)

file(TO_CMAKE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/../cmake" OT_IU_CMAKE_MODULE_PATH)
set(CMAKE_MODULE_PATH ${OT_IU_CMAKE_MODULE_PATH})

##-----------------------------------------------------------------------------
## Current version number:
##-----------------------------------------------------------------------------
set(IMAGEUTILITIES_VERSION "2.1.0")

string(REGEX MATCHALL "[0-9]" IMAGEUTILITIES_VERSION_PARTS "${IMAGEUTILITIES_VERSION}")

list(GET IMAGEUTILITIES_VERSION_PARTS 0 IMAGEUTILITIES_VERSION_MAJOR)
list(GET IMAGEUTILITIES_VERSION_PARTS 1 IMAGEUTILITIES_VERSION_MINOR)
list(GET IMAGEUTILITIES_VERSION_PARTS 2 IMAGEUTILITIES_VERSION_PATCH)
set(IMAGEUTILITIES_SOVERSION "${IMAGEUTILITIES_VERSION_MAJOR}.${IMAGEUTILITIES_VERSION_MINOR}${IMAGEUTILITIES_VERSION_PATCH}")
set(IMAGEUTILITIES_DLLVERSION "${IMAGEUTILITIES_VERSION_MAJOR}${IMAGEUTILITIES_VERSION_MINOR}${IMAGEUTILITIES_VERSION_PATCH}")

if(WIN32)
    # Postfix of DLLs:
    #set(IMAGEUTILITIES_DEBUG_POSTFIX d)
else()
    # Postfix of so's:
    #set(IMAGEUTILITIES_DLLVERSION "${IMAGEUTILITIES_VERSION_MAJOR}${IMAGEUTILITIES_VERSION_MINOR}${IMAGEUTILITIES_VERSION_PATCH}")
    #set(IMAGEUTILITIES_DLLVERSION "")
    #set(IMAGEUTILITIES_DEBUG_POSTFIX)
endif()

##------------------------INSTALL RPATH----------------------------------------
#---Configure Install RPATH, see https://cmake.org/Wiki/CMake_RPATH_handling; Relative Rpath: http://stackoverflow.com/questions/3960641/how-to-link-to-shared-lib-from-shared-lib-with-relative-path
SET(CMAKE_INSTALL_RPATH "$ORIGIN")
###SET(CMAKE_SKIP_BUILD_RPATH  FALSE)
###SET(CMAKE_BUILD_WITH_INSTALL_RPATH FALSE) 
###SET(CMAKE_INSTALL_RPATH "${CMAKE_INSTALL_PREFIX}/lib")
###SET(CMAKE_INSTALL_RPATH_USE_LINK_PATH TRUE)

##-----------------------------------------------------------------------------
## Flags if modules are used.
## The modules are included per default unless dependencies not found or omitted by the user.
## (the core module is always included!)

if(ANDROID)
option(IU_USE_IO "Including IO module." ON)
option(IU_USE_GUI "Including GUI module." OFF)
option(IU_USE_MATH "Including Math module." OFF)
option(IU_USE_NDARRAY "Include NDArray module" OFF)
option(WITH_FLYCAPTURE2 "Use FlyCapture2 - build pgrvideosource class." OFF)
option(WITH_OPENEXR "Use OpenEXR - build OpenEXRIO classes." OFF)
option(WITH_PYTHON "Use Python - include imageutilities <-> python interface. Requires boost.python and Eigen" OFF)
option(WITH_MATLAB "Use Matlab - include imageutilities <-> matlab interface. Requires matlab" OFF)
set(ANDROID_TOOLCHAIN_NAME arm-linux-androideabi-4.6)
set(CUDA_PROPAGATE_HOST_FLAGS OFF)
else(ANDROID)
option(IU_USE_IO "Including IO module." ON)
option(IU_USE_GUI "Including GUI module." ON)
option(IU_USE_MATH "Including Math module." ON)
option(IU_USE_NDARRAY "Include NDArray module" ON)
option(WITH_FLYCAPTURE2 "Use FlyCapture2 - build pgrvideosource class." OFF)
option(WITH_OPENEXR "Use OpenEXR - build OpenEXRIO classes." ON)
option(WITH_PYTHON "Use Python - include imageutilities <-> python interface. Requires numpy, boost.python and Eigen" OFF)
option(WITH_MATLAB "Use Matlab - include imageutilities <-> matlab interface. Requires matlab" OFF)
endif(ANDROID)


#------------- for compiler flags see cmake/compiler_settings.cmake.txt -----------------

if(WITH_PYTHON)
    find_package(PythonInterp) # run this such that lib and interpreter path match.
    find_package(PythonLibs 2.7 REQUIRED)
    
    include_directories(${PYTHON_INCLUDE_DIRS})
    message(STATUS "Python libraries: " ${PYTHON_LIBRARIES})
    
    # Extract boost root dir. Should be the same as the Python lib dir.
    get_filename_component(PYTHON_LIBRARY_DIR ${PYTHON_LIBRARIES} DIRECTORY)
    get_filename_component(BOOST_ROOT ${PYTHON_LIBRARY_DIR} DIRECTORY)
    
    message(STATUS "Boost root: " ${BOOST_ROOT})
    
    find_package(NumPy REQUIRED)
    include_directories(${NUMPY_INCLUDE_DIRS})
    
    find_package(Boost REQUIRED COMPONENTS python)
    message(STATUS "Boost libraries:" ${Boost_LIBRARIES})
    
    if(NOT (${PYTHON_LIBRARY_DIR} MATCHES  ${Boost_LIBRARY_DIRS}))
        message(FATAL_ERROR "Boost library dir does not match python library dir. Is boost installed? "
                            "If you use anaconda, type `conda install boost`. "
                            "If you use system python (ubuntu), type `sudo apt-get install libboost-python`.")
    endif(NOT (${PYTHON_LIBRARY_DIR} MATCHES  ${Boost_LIBRARY_DIRS}))
endif(WITH_PYTHON)

if(WITH_MATLAB)
    find_package(Matlab_ICG)
endif(WITH_MATLAB)

##-----------------------------------------------------------------------------
## IO MODULE: OpenCV for Image I/O
if(ANDROID)
    set(OpenCV_DIR $ENV{NVPACK_CUDA_ROOT_DIR}/../OpenCV-2.4.8.2-Tegra-sdk/sdk/native/jni)
endif(ANDROID)
find_package( OpenCV QUIET COMPONENTS opencv_core opencv_highgui opencv_videostab)
# only include if IO module is used and OpenCV found.
if(IU_USE_IO AND OpenCV_LIBS)

  message("[+] ImageUtilities include IO module")
  include_directories(${OpenCV_INCLUDE_DIRS})

  set( IU_PUBLIC_HEADERS
    ${IU_PUBLIC_HEADERS}
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio.h

    )

  set( IU_IO_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio/imageio.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio/videosource.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio/iuioapi.h
    #${CMAKE_CURRENT_SOURCE_DIR}/iuio/videocapture_private.h
    )
  set(IU_PUBLIC_IO_HEADERS
      ${CMAKE_CURRENT_SOURCE_DIR}/iuio/iuvideosource.h
      ${CMAKE_CURRENT_SOURCE_DIR}/iuio/videosource.h
      ${CMAKE_CURRENT_SOURCE_DIR}/iuio/opencvsource.h
      ${CMAKE_CURRENT_SOURCE_DIR}/iuio/iuioapi.h
   )

  set( IU_IO_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio/imageio.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iuio/opencvsource.cpp
    )
  message("Found OpenCV Version: " ${OpenCV_VERSION_MAJOR} "." ${OpenCV_VERSION_MINOR})
  # check for OpenCV greaterequal 2.4
  if(${OpenCV_VERSION_MAJOR} MATCHES "3")
    message("Enabling fixes for OpenCV >= 3")
    add_definitions(-DOPENCV_3)
    find_package( OpenCV QUIET COMPONENTS opencv_videoio opencv_core opencv_imgcodecs opencv_imgproc opencv_highgui)
  endif(${OpenCV_VERSION_MAJOR} MATCHES "3")


  ######################
  # Flycapture2 for pointgrey cameras
  ######################
  if(WITH_FLYCAPTURE2)
    find_package(FlyCapture2 REQUIRED QUIET)
    if(FLYCAPTURE2_FOUND)
      message("  [+] build io module with Flycapture2/Pointgrey support")
      add_definitions(-DIUIO_PGR)
      include_directories(${FLYCAPTURE2_INCLUDE_DIR})

      set( IU_IO_HEADERS ${IU_IO_HEADERS}
        ${CMAKE_CURRENT_SOURCE_DIR}/iuio/pgrsource.h
       )
      set(IU_PUBLIC_IO_HEADERS ${IU_PUBLIC_IO_HEADERS}
        ${CMAKE_CURRENT_SOURCE_DIR}/iuio/pgrsource.h
        )
      set( IU_IO_SOURCES ${IU_IO_SOURCES}
        ${CMAKE_CURRENT_SOURCE_DIR}/iuio/pgrsource.cpp
        ${CMAKE_CURRENT_SOURCE_DIR}/iuio/pgrcameradata.h
       )
      set(ADDITIONAL_IUIO_DEPENDENCIES
         ${FLYCAPTURE2_LIBRARIES}
        )
    endif(FLYCAPTURE2_FOUND)
    
  else(WITH_FLYCAPTURE2)
      message("  [-] build io module without Flycapture2/Pointgrey support")
      set(ADDITIONAL_IUIO_DEPENDENCIES "")
  endif(WITH_FLYCAPTURE2)

  ######################
  # OpenEXR
  ######################
  if(WITH_OPENEXR)
    find_package(OpenEXR REQUIRED QUIET)
    if(OPENEXR_FOUND)
        message("  [+] build io module with OpenEXR support")
        include_directories(${OPENEXR_INCLUDE_DIRS})
        #cuda_include_directories(${OPENEXR_INCLUDE_DIRS})
        message("include dirs: " ${OPENEXR_INCLUDE_DIRS})
        add_definitions(-DIUIO_EXR)

        find_package(Eigen3 QUIET)
        if(EIGEN3_FOUND)
            add_definitions(-DIUIO_EIGEN3)
        endif(EIGEN3_FOUND)


        set( IU_IO_HEADERS ${IU_IO_HEADERS}
          ${CMAKE_CURRENT_SOURCE_DIR}/iuio/openexrio.h
         )
        set(IU_PUBLIC_IO_HEADERS ${IU_PUBLIC_IO_HEADERS}
          ${CMAKE_CURRENT_SOURCE_DIR}/iuio/openexrio.h
          )
        set( IU_IO_SOURCES ${IU_IO_SOURCES}
          ${CMAKE_CURRENT_SOURCE_DIR}/iuio/openexrio.cpp
         )

        set(ADDITIONAL_IUIO_DEPENDENCIES ${ADDITIONAL_IUIO_DEPENDENCIES}
            ${OPENEXR_LIBRARIES}
          )

    
    endif(OPENEXR_FOUND)
  else(WITH_OPENEXR)
        message("  [-] build io module without OpenEXR support")
  endif(WITH_OPENEXR)


else()
  message("[-] ImageUtilities omitting IO module")
  set(IU_USE_IO OFF CACHE PATH "IU: Omit IO module." FORCE)

  # empty libraries
  set(OpenCV_LIBS "")

endif()



##-----------------------------------------------------------------------------
## GUI MODULE: Qt5 for ImagepuWidget
find_package(Qt5Core 5.4 QUIET)
find_package(Qt5Widgets 5.4 QUIET)
find_package(Qt5OpenGL 5.4 QUIET)
find_package(OpenGL QUIET)
if(IU_USE_GUI AND Qt5Widgets_FOUND AND Qt5OpenGL_FOUND)

  message("[+] ImageUtilities include GUI module")
  set(CMAKE_AUTOMOC ON)

  set( IU_PUBLIC_HEADERS
    ${IU_PUBLIC_HEADERS}
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui.h
   )
  set(IU_PUBLIC_GUI_HEADERS
      ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5imagegpuwidget.h
      ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5disparitymapgpuwidget.h
      ${CMAKE_CURRENT_SOURCE_DIR}/iugui/iuguiapi.h
   )
  set( IU_GUI_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/iuguiapi.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5imagegpuwidget.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5disparitymapgpuwidget.h
  )
  set( IU_GUI_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5imagegpuwidget.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5disparitymapgpuwidget.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5imagegpuwidget.cu
    ${CMAKE_CURRENT_SOURCE_DIR}/iugui/qt5disparitymapgpuwidget.cu
  )


else(IU_USE_GUI AND Qt5Widgets_FOUND AND Qt5OpenGL_FOUND)
  message("[-] ImageUtilities omitting GUI module")
  set(IU_USE_GUI OFF CACHE PATH "IU: Omit GUI module." FORCE)

endif(IU_USE_GUI AND Qt5Widgets_FOUND AND Qt5OpenGL_FOUND)

if(IU_USE_MATH)
  message("[+] ImageUtilities include Math module")

  set( IU_PUBLIC_HEADERS
    ${IU_PUBLIC_HEADERS}
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath.h
   )

  set(IU_PUBLIC_MATH_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/iumathapi.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/typetraits.h
   )

  set( IU_MATH_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/thrust_kernels.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/arithmetics.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/statistics.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/complex.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/fft.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/fftplan.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath.h
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/iumathapi.h
  )
  set( IU_MATH_SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath/fft_kernels.cuh
    ${CMAKE_CURRENT_SOURCE_DIR}/iumath.cu
  )


else(IU_USE_MATH)
  message("[-] ImageUtilities omitting Math module")
  set(IU_USE_MATH OFF CACHE PATH "IU: Omit Math module." FORCE)
endif(IU_USE_MATH)

##-----------------------------------------------------------------------------
## local settings, headers and sources
include_directories(
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/..
  ${CMAKE_CURRENT_LIST_DIR}
  )
cuda_include_directories(
  ${CMAKE_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}
  ${CMAKE_CURRENT_SOURCE_DIR}/..
  )

# SPLITTING ALL THE HEADERS FOR THE INSTALL DIRECTORIES (PUBLIC) AND HEADERS
# THAT ARE NOT INSTALLED (public not as keyword)!
SET( IU_PUBLIC_HEADERS
  ${IU_PUBLIC_HEADERS}
  ${CMAKE_CURRENT_SOURCE_DIR}/iudefs.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucutil.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iuhelpermath.h
  )
if(WITH_PYTHON)
  SET( IU_PUBLIC_HEADERS
      ${IU_PUBLIC_HEADERS}
      ${CMAKE_CURRENT_SOURCE_DIR}/iupython.h
  )
endif(WITH_PYTHON)

if(WITH_MATLAB)
  SET( IU_PUBLIC_HEADERS
      ${IU_PUBLIC_HEADERS}
      ${CMAKE_CURRENT_SOURCE_DIR}/iumatlab.h
  )
endif(WITH_MATLAB)

# 
SET( IU_PUBLIC_CORE_HEADERS
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/iucoreapi.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/coredefs.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/memorydefs.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/linearmemory.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/linearhostmemory.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/lineardevicememory.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/tensor_cpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/tensor_gpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/image.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/image_allocator_cpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/image_cpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/image_allocator_gpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/image_gpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/volume.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/volume_allocator_cpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/volume_cpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/volume_allocator_gpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/volume_gpu.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/copy.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/vector.h
#   ${CMAKE_CURRENT_SOURCE_DIR}/iucore/imagepyramid.h
  )

SET( IU_PUBLIC_COMMON_HEADERS
  ${CMAKE_CURRENT_SOURCE_DIR}/common/derivative_kernels.cuh
  ${CMAKE_CURRENT_SOURCE_DIR}/common/bind_textures.cuh
)

# 
# # all the additional headers follow here below (we split that two for better overview and the seperated libs)
SET( IU_CORE_HEADERS
#  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/setvalue.h
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/convert.h
  )

SET( IU_HEADERS
  ${IU_PUBLIC_HEADERS}
  ${IU_PUBLIC_CORE_HEADERS}
  ${IU_CORE_HEADERS}
  )
# 
SET( IU_SOURCES
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/convert.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/convert.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/copy.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/copy.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/filter.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/filter.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/filterbspline_kernels.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/transform.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/reduce.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/reduce.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/prolongate.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/prolongate.cu
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/remap.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/remap.cu
  )
# 
# # denote kernel files as header only to not confuse the compiler
# set_source_files_properties(
#   # ${CMAKE_CURRENT_SOURCE_DIR}/iutransform/transform.cu
#   # ${CMAKE_CURRENT_SOURCE_DIR}/iutransform/remap.cu
#   # ${CMAKE_CURRENT_SOURCE_DIR}/iutransform/prolongate.cu
#   # ${CMAKE_CURRENT_SOURCE_DIR}/iutransform/reduce.cu
#   ${CMAKE_CURRENT_SOURCE_DIR}/iufilter/filterbspline_kernels.cu
#   PROPERTIES HEADER_FILE_ONLY yes
#   )
# 
# ##-----------------------------------------------------------------------------
# set( IU_ALL_FILES
#   ${IU_HEADERS}
#   ${IU_SOURCES}
#   ${IU_SPARSE_SOURCES}
#   ${IU_SPARSE_HEADERS}
#   ${IU_MATLAB_HEADERS}
#   ${IU_MATLAB_SOURCES}
#   #${IU_GUI_MOC_HEADERS}
#   ${IU_GUI_HEADERS}
#   ${IU_GUI_SOURCES}
#   ${IU_GUI_MOC_SOURCES}
#   ${IU_IO_HEADERS}
#   ${IU_IO_SOURCES}
# )

# denote kernel files as header only to not confuse the compiler
set_source_files_properties(
  ${CMAKE_CURRENT_SOURCE_DIR}/iucore/transform.cu
  PROPERTIES HEADER_FILE_ONLY yes
  )
  
##-build ndarray---------------------------------------------------------------
	if(IU_USE_NDARRAY)
        message("[+] ImageUtilities include ndarray module")
		add_subdirectory(ndarray)
        #message("NDARRAY_LIB" = ${NDARRAY_LIB})
	if(NOT NDARRAY_LIB)
        message("[-] ImageUtilities omitting ndarray module")
	  #set(IU_USE_NDARRAY OFF CACHE PATH "IU: Omit NDArray module." FORCE)
	endif()
endif()

if(IU_BUILD_STATIC)
  message("[+] building static library")
else(IU_BUILD_STATIC)
  message("[-] do not build static library")
endif(IU_BUILD_STATIC)

set(IU_LIBS "") # variable where all libs that are built are saved
set(IU_LIBS_STATIC "") # variable where all libs that are built are saved

##-----------------------------------------------------------------------------
## documentation
SET(DOXYGEN_OUTPUT ${CMAKE_CURRENT_SOURCE_DIR}/../doc/html/index.html)
SET(DOXYGEN_EXECUTABLE doxygen)
SET(DOXYGEN_INPUT ${CMAKE_CURRENT_SOURCE_DIR}/../doc/doxconfig)
CONFIGURE_FILE(${CMAKE_CURRENT_SOURCE_DIR}/../doc/doxconfig.in
                       ${DOXYGEN_INPUT})

ADD_CUSTOM_TARGET( apidoc
 COMMAND ${CMAKE_COMMAND} --build . --target install
 COMMAND ${CMAKE_COMMAND} -E echo_append "Building API Documentation..."
 COMMAND ${DOXYGEN_EXECUTABLE} ${DOXYGEN_INPUT}
 COMMAND ${CMAKE_COMMAND} -E echo "Done."
 WORKING_DIRECTORY ${CMAKE_CACHEFILE_DIR}
 DEPENDS ${DOXYGEN_INPUT}
 )



##-----------------------------------------------------------------------------
## build core library
set(IU_CORE_LIB iucore)

cuda_add_library( ${IU_CORE_LIB} ${IU_HEADERS} ${IU_SOURCES})
set_target_properties(${IU_CORE_LIB} PROPERTIES
  DEFINE_SYMBOL IUCORE_DLL_EXPORTS
  VERSION ${IMAGEUTILITIES_VERSION}
  SOVERSION ${IMAGEUTILITIES_SOVERSION}
  PUBLIC_HEADER "${IU_PUBLIC_HEADERS}"
  )

target_link_libraries( ${IU_CORE_LIB} ${CUDA_LIBRARIES} ${NDARRAY_LIB})
set(IU_LIBS ${IU_LIBS} ${IU_CORE_LIB})

if(IU_BUILD_STATIC)
  cuda_add_library( ${IU_CORE_LIB}_static STATIC ${IU_HEADERS} ${IU_SOURCES})
  target_link_libraries( ${IU_CORE_LIB}_static ${CUDA_LIBRARIES} ${NDARRAY_LIB})
  set(IU_LIBS_STATIC ${IU_LIBS_STATIC} ${IU_CORE_LIB}_static)
endif(IU_BUILD_STATIC)



message("additional iuio libs: ${ADDITIONAL_IUIO_DEPENDENCIES}")
##-----------------------------------------------------------------------------
## build io library
set(IU_IO_LIB iuio)
if(IU_USE_IO)
  cuda_add_library( ${IU_IO_LIB} ${IU_IO_HEADERS} ${IU_IO_SOURCES} )
  set_target_properties(${IU_IO_LIB} PROPERTIES
    DEFINE_SYMBOL IUIO_DLL_EXPORTS
    VERSION ${IMAGEUTILITIES_VERSION}
    SOVERSION ${IMAGEUTILITIES_SOVERSION}
    )
  target_link_libraries( ${IU_IO_LIB} iucore
    ${CUDA_LIBRARIES} ${OpenCV_LIBS} ${ADDITIONAL_IUIO_DEPENDENCIES}
    )
  set(IU_LIBS ${IU_LIBS} ${IU_IO_LIB})
  
  message(${OpenCV_LIBS})
  if(IU_BUILD_STATIC)
    cuda_add_library( ${IU_IO_LIB}_static STATIC ${IU_IO_HEADERS} ${IU_IO_SOURCES} )
    target_link_libraries( ${IU_IO_LIB}_static
    ${CUDA_LIBRARIES} ${OpenCV_LIBS} ${ADDITIONAL_IUIO_DEPENDENCIES}
    )
    set(IU_LIBS_STATIC ${IU_LIBS_STATIC} ${IU_IO_LIB}_static)
  endif(IU_BUILD_STATIC)
endif(IU_USE_IO)


##-----------------------------------------------------------------------------
## build gui library
set(IU_GUI_LIB iugui)
if(IU_USE_GUI)
  cuda_add_library( ${IU_GUI_LIB} ${IU_GUI_HEADERS} ${IU_GUI_SOURCES})
  set_target_properties(${IU_GUI_LIB} PROPERTIES
    DEFINE_SYMBOL IUGUI_DLL_EXPORTS
    VERSION ${IMAGEUTILITIES_VERSION}
    SOVERSION ${IMAGEUTILITIES_SOVERSION}
    )
  target_link_libraries( ${IU_GUI_LIB}
    Qt5::Widgets Qt5::OpenGL ${CUDA_LIBRARIES} ${OPENGL_LIBRARIES}
    )
  set(IU_LIBS ${IU_LIBS} ${IU_GUI_LIB})
  

  if(IU_BUILD_STATIC)
    cuda_add_library( ${IU_GUI_LIB}_static STATIC ${IU_GUI_HEADERS} ${IU_GUI_SOURCES})
    target_link_libraries( ${IU_GUI_LIB}_static
    Qt5::Widgets Qt5::OpenGL ${CUDA_LIBRARIES} ${OPENGL_LIBRARIES}
    )
    set(IU_LIBS_STATIC ${IU_LIBS_STATIC} ${IU_GUI_LIB}_static)
  endif(IU_BUILD_STATIC)
endif(IU_USE_GUI)

##-----------------------------------------------------------------------------
## build math library
set(IU_MATH_LIB iumath)
if(IU_USE_MATH)
  # The OPTIONS "-DIUMATH_DLL_EXPORTS" is used to manually propagate symbol to nvcc compiler
  # because CUDA_SET_PROPAGATE_HOST_FLAGS is turend off.
  cuda_add_library( ${IU_MATH_LIB} ${IU_MATH_HEADERS} ${IU_MATH_SOURCES}
	  OPTIONS "-DIUMATH_DLL_EXPORTS")
  set_target_properties(${IU_MATH_LIB} PROPERTIES
    DEFINE_SYMBOL IUMATH_DLL_EXPORTS
    VERSION ${IMAGEUTILITIES_VERSION}
    SOVERSION ${IMAGEUTILITIES_SOVERSION}
    )
  target_link_libraries( ${IU_MATH_LIB}
    ${CUDA_LIBRARIES}
    )
  cuda_add_cufft_to_target(${IU_MATH_LIB})
  set(IU_LIBS ${IU_LIBS} ${IU_MATH_LIB})


  if(IU_BUILD_STATIC)
    cuda_add_library( ${IU_MATH_LIB}_static STATIC ${IU_MATH_HEADERS} ${IU_MATH_SOURCES})
    target_link_libraries( ${IU_MATH_LIB}_static
     ${CUDA_LIBRARIES} ${CUDA_CUFFT_LIBRARIES}
    )
    set(IU_LIBS_STATIC ${IU_LIBS_STATIC} ${IU_MATH_LIB}_static)
  endif(IU_BUILD_STATIC)
endif(IU_USE_MATH)

##-----------------------------------------------------------------------------
## Install target

## Two different types of installation supported:
## *) local: for developement (e.g. svn checkout -- currently the default)
## *) global: for usage only (care about mixing up the two -> the global one will be preffered!)

OPTION(IU_INSTALL_LOCAL "Installation of the ImageUtilities binaries in the local imageutilities tree." ON)



if(IU_INSTALL_LOCAL )
  if(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
    set(CMAKE_INSTALL_PREFIX $ENV{IMAGEUTILITIES_ROOT} CACHE PATH "ImageUtilities install prefix" FORCE)
  endif(CMAKE_INSTALL_PREFIX_INITIALIZED_TO_DEFAULT)
endif(IU_INSTALL_LOCAL)

if(NOT IU_INSTALL_LOCAL OR NOT CMAKE_INSTALL_PREFIX)
  if(NOT UNIX)
    #set(CMAKE_INSTALL_PREFIX $ENV{ProgramFiles}/VMLibraries CACHE PATH "ImageUtilities install prefix" FORCE)
    set(CMAKE_INSTALL_PREFIX ${CMAKE_SOURCE_DIR} CACHE PATH "ImageUtilities install prefix" FORCE)
  else(NOT UNIX)
    set(CMAKE_INSTALL_PREFIX /usr/local CACHE PATH "ImageUtilities install prefix" FORCE)
  endif(NOT UNIX)
endif(NOT IU_INSTALL_LOCAL OR NOT CMAKE_INSTALL_PREFIX)

# set the cmake-files that should be installed with the package
set( IU_CMAKE_FILES
  ${CMAKE_CURRENT_SOURCE_DIR}/../cmake/FindFlyCapture2.cmake
  )
if(ANDROID)
set( IU_CMAKE_FILES
  ${IU_CMAKE_FILES}
  )
endif(ANDROID)

# set default install path
#set(CMAKE_INSTALL_PREFIX ${CMAKE_CURRENT_SOURCE_DIR}/.. CACHE PATH "ImageUtilities install prefix" FORCE)

message("install: ${CMAKE_INSTALL_PREFIX}")

# install the libraries
if(ANDROID)
install( TARGETS ${IU_LIBS} ${IU_LIBS_STATIC}
  RUNTIME         DESTINATION   binARM
  ARCHIVE         DESTINATION   libARM
  LIBRARY         DESTINATION   libARM
  PUBLIC_HEADER   DESTINATION   include/iu
  )
else(ANDROID)
install( TARGETS ${IU_LIBS} ${IU_LIBS_STATIC}
  RUNTIME         DESTINATION   bin
  ARCHIVE         DESTINATION   lib
  LIBRARY         DESTINATION   lib
  PUBLIC_HEADER   DESTINATION   include/iu
  )
endif(ANDROID)
# install header files
# set(IMAGE_HELPER ${CMAKE_CURRENT_SOURCE_DIR}/helper_math.h)
# install(FILES ${IMAGE_HELPER}
# 	DESTINATION include
# 	COMPONENT Headers
# 	)

install(FILES ${IU_PUBLIC_CORE_HEADERS}
  DESTINATION include/iu/iucore
  COMPONENT Headers
  )
install(FILES ${IU_PUBLIC_COMMON_HEADERS}
  DESTINATION include/iu/common
  COMPONENT Headers
  )
install(FILES ${IU_PUBLIC_IO_HEADERS}
  DESTINATION include/iu/iuio
  COMPONENT Headers
  )
install(FILES ${IU_PUBLIC_GUI_HEADERS}
  DESTINATION include/iu/iugui
  COMPONENT Headers
  )
install(FILES ${IU_PUBLIC_MATH_HEADERS}
  DESTINATION include/iu/iumath
  COMPONENT Headers
  )
install(FILES ${IU_PUBLIC_HEADERS}
  DESTINATION include/iu
  COMPONENT Headers
  )

install(FILES ${IU_CMAKE_FILES}
  DESTINATION cmake
  )

if(ANDROID)
  message("Compiler Flags NVCC: " ${nvcc_flags})
  message("Compiler Flags GCC:  " ${CMAKE_C_FLAGS})

endif(ANDROID)

