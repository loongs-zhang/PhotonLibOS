# Note: Be aware of the differences between CMake project and Makefile project.
# Makefile project is not able to get BINARY_DIR at configuration.

set(actually_built)

function(build_from_src [dep])
    if (dep STREQUAL "aio")
        set(BINARY_DIR ${PROJECT_BINARY_DIR}/aio-build)
        ExternalProject_Add(
                aio
                URL ${PHOTON_AIO_SOURCE}
                URL_MD5 605237f35de238dfacc83bcae406d95d
                BUILD_IN_SOURCE ON
                CONFIGURE_COMMAND ""
                BUILD_COMMAND make prefix=${BINARY_DIR} install -j
                INSTALL_COMMAND ""
        )
        set(AIO_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(AIO_LIBRARIES ${BINARY_DIR}/lib/libaio.a PARENT_SCOPE)

    elseif (dep STREQUAL "zlib")
        set(BINARY_DIR ${PROJECT_BINARY_DIR}/zlib-build)
        ExternalProject_Add(
                zlib
                URL ${PHOTON_ZLIB_SOURCE}
                URL_MD5 9b8aa094c4e5765dabf4da391f00d15c
                BUILD_IN_SOURCE ON
                CONFIGURE_COMMAND CFLAGS=-fPIC ./configure --prefix=${BINARY_DIR} --static
                BUILD_COMMAND make -j
                INSTALL_COMMAND make install
        )
        set(ZLIB_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(ZLIB_LIBRARIES ${BINARY_DIR}/lib/libz.a PARENT_SCOPE)

    elseif (dep STREQUAL "uring")
        set(BINARY_DIR ${PROJECT_BINARY_DIR}/uring-build)
        ExternalProject_Add(
                uring
                URL ${PHOTON_URING_SOURCE}
                URL_MD5 2e8c3c23795415475654346484f5c4b8
                BUILD_IN_SOURCE ON
                CONFIGURE_COMMAND ./configure --prefix=${BINARY_DIR}
                BUILD_COMMAND V=1 CFLAGS=-fPIC make -C src
                INSTALL_COMMAND make install
        )
        set(URING_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(URING_LIBRARIES ${BINARY_DIR}/lib/liburing.a PARENT_SCOPE)

    elseif (dep STREQUAL "gflags")
        ExternalProject_Add(
                gflags
                URL ${PHOTON_GFLAGS_SOURCE}
                URL_MD5 1a865b93bacfa963201af3f75b7bd64c
                CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                INSTALL_COMMAND ""
        )
        if (CMAKE_BUILD_TYPE STREQUAL "Debug")
            set(POSTFIX "_debug")
        endif ()
        ExternalProject_Get_Property(gflags BINARY_DIR)
        set(GFLAGS_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(GFLAGS_LIBRARIES ${BINARY_DIR}/lib/libgflags${POSTFIX}.a ${BINARY_DIR}/lib/libgflags_nothreads${POSTFIX}.a PARENT_SCOPE)

    elseif (dep STREQUAL "googletest")
        ExternalProject_Add(
                googletest
                URL ${PHOTON_GOOGLETEST_SOURCE}
                URL_MD5 e82199374acdfda3f425331028eb4e2a
                CMAKE_ARGS -DCMAKE_BUILD_TYPE=${CMAKE_BUILD_TYPE} -DINSTALL_GTEST=OFF -DCMAKE_POSITION_INDEPENDENT_CODE=ON
                INSTALL_COMMAND ""
        )
        ExternalProject_Get_Property(googletest SOURCE_DIR)
        ExternalProject_Get_Property(googletest BINARY_DIR)
        set(GOOGLETEST_INCLUDE_DIRS ${SOURCE_DIR}/googletest/include ${SOURCE_DIR}/googlemock/include PARENT_SCOPE)
        set(GOOGLETEST_LIBRARIES ${BINARY_DIR}/lib/libgmock.a ${BINARY_DIR}/lib/libgmock_main.a
                ${BINARY_DIR}/lib/libgtest.a ${BINARY_DIR}/lib/libgtest_main.a PARENT_SCOPE)

    elseif (dep STREQUAL "openssl")
        set(BINARY_DIR ${PROJECT_BINARY_DIR}/openssl-build)
        ExternalProject_Add(
                openssl
                URL ${PHOTON_OPENSSL_SOURCE}
                URL_MD5 bad68bb6bd9908da75e2c8dedc536b29
                BUILD_IN_SOURCE ON
                CONFIGURE_COMMAND ./config -fPIC no-unit-test no-shared --openssldir=${BINARY_DIR} --prefix=${BINARY_DIR}
                BUILD_COMMAND make depend -j ${NumCPU} && make -j ${NumCPU}
                INSTALL_COMMAND make install
        )
        ExternalProject_Get_Property(openssl SOURCE_DIR)
        set(OPENSSL_ROOT_DIR ${SOURCE_DIR} PARENT_SCOPE)
        set(OPENSSL_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(OPENSSL_LIBRARIES ${BINARY_DIR}/lib/libssl.a ${BINARY_DIR}/lib/libcrypto.a PARENT_SCOPE)

    elseif (dep STREQUAL "curl")
        if (${OPENSSL_ROOT_DIR} STREQUAL "")
            message(FATAL_ERROR "OPENSSL_ROOT_DIR not exist")
        endif ()
        set(BINARY_DIR ${PROJECT_BINARY_DIR}/curl-build)
        ExternalProject_Add(
                curl
                URL ${PHOTON_CURL_SOURCE}
                URL_MD5 a66270f11e3fbfad709600bbd1686704
                BUILD_IN_SOURCE ON
                CONFIGURE_COMMAND export CC=${CMAKE_C_COMPILER} && export CXX=${CMAKE_CXX_COMPILER} &&
                    export LD=${CMAKE_LINKER} && export CFLAGS=-fPIC &&
                    autoreconf -i && ./configure --with-ssl=${OPENSSL_ROOT_DIR}
                    --without-libssh2 --enable-static --enable-shared=no --enable-optimize
                    --disable-manual --without-libidn
                    --disable-ftp --disable-file --disable-ldap --disable-ldaps
                    --disable-rtsp --disable-dict --disable-telnet --disable-tftp
                    --disable-pop3 --disable-imap --disable-smb --disable-smtp
                    --disable-gopher --without-nghttp2 --enable-http
                    --with-pic=PIC --prefix=${BINARY_DIR}
                BUILD_COMMAND make -j ${NumCPU}
                INSTALL_COMMAND make install
        )
        set(CURL_INCLUDE_DIRS ${BINARY_DIR}/include PARENT_SCOPE)
        set(CURL_LIBRARIES ${BINARY_DIR}/lib/libcurl.a PARENT_SCOPE)
    endif ()

    list(APPEND actually_built ${dep})
    set(actually_built ${actually_built} PARENT_SCOPE)
endfunction()