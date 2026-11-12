# Aide-Mémoire — Table des Appels Système Linux x86_64

## Registres d'appel des Syscalls :
- **Numéro** : `RAX`
- **Arguments** : `RDI`, `RSI`, `RDX`, **`R10`**, `R8`, `R9`
- **Retour** : `RAX` (si entre -4095 et -1 : code d'erreur = `-errno`)
- **Détruits** : `RCX` et `R11` sont systématiquement écrasés !

---

| RAX | Syscall | RDI | RSI | RDX | R10 | R8 | R9 |
|:---:|---|---|---|---|---|---|---|
| **0** | `sys_read` | `unsigned int fd` | `char *buf` | `size_t count` | - | - | - |
| **1** | `sys_write` | `unsigned int fd` | `const char *buf` | `size_t count` | - | - | - |
| **2** | `sys_open` | `const char *filename` | `int flags` | `umode_t mode` | - | - | - |
| **3** | `sys_close` | `unsigned int fd` | - | - | - | - | - |
| **8** | `sys_lseek` | `unsigned int fd` | `off_t offset` | `unsigned int whence` | - | - | - |
| **9** | `sys_mmap` | `void *addr` | `size_t length` | `int prot` | `int flags` | `int fd` | `off_t offset` |
| **11**| `sys_munmap`| `void *addr` | `size_t length` | - | - | - | - |
| **12**| `sys_brk` | `unsigned long brk` | - | - | - | - | - |
| **22**| `sys_pipe` | `int pipefd[2]` | - | - | - | - | - |
| **33**| `sys_dup2` | `int oldfd` | `int newfd` | - | - | - | - |
| **35**| `sys_nanosleep`| `struct timespec *req` | `struct timespec *rem` | - | - | - | - |
| **39**| `sys_getpid`| - | - | - | - | - | - |
| **41**| `sys_socket`| `int family` | `int type` | `int protocol` | - | - | - |
| **42**| `sys_connect`| `int sockfd` | `struct sockaddr *addr`| `int addrlen` | - | - | - |
| **43**| `sys_accept`| `int sockfd` | `struct sockaddr *addr`| `int *addrlen` | - | - | - |
| **49**| `sys_bind` | `int sockfd` | `struct sockaddr *addr`| `int addrlen` | - | - | - |
| **50**| `sys_listen`| `int sockfd` | `int backlog` | - | - | - | - |
| **57**| `sys_fork` | - | - | - | - | - | - |
| **59**| `sys_execve`| `const char *filename`| `char **argv` | `char **envp` | - | - | - |
| **60**| `sys_exit` | `int error_code` | - | - | - | - | - |
| **61**| `sys_wait4`| `pid_t pid` | `int *wstatus` | `int options` | `struct rusage *ru` | - | - |

---

## Constantes Usuelles
- `O_RDONLY` = `0`
- `O_WRONLY` = `1`
- `O_RDWR`   = `2`
- `O_CREAT`  = `64` (`0x40`)
- `AF_INET`  = `2`
- `SOCK_STREAM` = `1`
- `SEEK_SET` = `0`, `SEEK_CUR` = `1`, `SEEK_END` = `2`
