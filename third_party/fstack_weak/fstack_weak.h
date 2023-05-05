/*
Copyright 2022 The Photon Authors

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

    http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
*/

#pragma once

#include <sys/types.h>
#include <sys/socket.h>

#ifdef __cplusplus
extern "C" {
#endif

using ff_run_func_t = int (*)(void*);

int ff_init(int argc, char* const argv[]);
void ff_run(ff_run_func_t loop, void* arg);

int ff_socket(int domain, int type, int protocol);
int ff_connect(int s, const struct linux_sockaddr* name, socklen_t namelen);
int ff_bind(int s, const struct linux_sockaddr* addr, socklen_t addrlen);
int ff_listen(int s, int backlog);
int ff_accept(int s, struct linux_sockaddr* addr, socklen_t* addrlen);
int ff_shutdown(int s, int how);
int ff_close(int fd);

ssize_t ff_send(int s, const void* buf, size_t len, int flags);
ssize_t ff_recv(int s, void* buf, size_t len, int flags);
ssize_t ff_recvmsg(int s, struct msghdr* msg, int flags);
ssize_t ff_sendmsg(int s, const struct msghdr* msg, int flags);

int ff_ioctl(int fd, unsigned long request, ...);
int ff_setsockopt(int s, int level, int optname, const void* optval, socklen_t optlen);
int ff_getsockopt(int s, int level, int optname, void* optval, socklen_t* optlen);

int ff_kqueue(void);
int ff_kevent(int kq, const struct kevent* changelist, int nchanges, struct kevent* eventlist, int nevents,
              const struct timespec* timeout);

#ifdef __cplusplus
}
#endif
