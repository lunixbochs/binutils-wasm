#include <assert.h>

typedef int sigjmp_buf;
static int sigsetjmp(sigjmp_buf env, int savemask) {
    return 0;
}
__attribute__((noreturn))
static int siglongjmp(sigjmp_buf env, int val) {
    printf("siglongjmp attempted\n");
    abort();
}

typedef int jmp_buf;
static int setjmp(jmp_buf env) {
     return 0;
}
__attribute__((noreturn))
static int longjmp(jmp_buf env, int val) {
    printf("longjmp attempted\n");
    abort();
}
