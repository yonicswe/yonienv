#!/bin/bash -xe

if [ -d "build" ]; then
	/bin/rm -rf build
fi

CORES=$(( $(nproc) -1)) 
mkdir build
cd build
cmake  \
      -DMLX5_DEBUG=True \
      -DCMAKE_BUILD_TYPE=Debug \
      -DCMAKE_INSTALL_BINDIR:PATH=/usr/bin \
      -DCMAKE_INSTALL_SBINDIR:PATH=/usr/sbin \
      -DCMAKE_INSTALL_LIBDIR:PATH=/usr/lib64 \
      -DCMAKE_INSTALL_LIBEXECDIR:PATH=/usr/libexec \
      -DCMAKE_INSTALL_LOCALSTATEDIR:PATH=/var \
      -DCMAKE_INSTALL_SHAREDSTATEDIR:PATH=/var/lib \
      -DCMAKE_INSTALL_INCLUDEDIR:PATH=/usr/include \
      -DCMAKE_INSTALL_INFODIR:PATH=/usr/share/info \
      -DCMAKE_INSTALL_MANDIR:PATH=/usr/share/man \
      -DCMAKE_INSTALL_SYSCONFDIR:PATH=/etc \
      -DCMAKE_INSTALL_SYSTEMD_SERVICEDIR:PATH=/usr/lib/systemd/system \
      -DCMAKE_INSTALL_INITDDIR:PATH=/etc/rc.d/init.d \
      ..
make -j$CORES
# sudo make install
