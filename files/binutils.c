#include <stdio.h>
#include <string.h>

// NOTE: these may be wrong, we might need to set the program name for some aliased invocations.
const char *_addr2line_program_name = "addr2line";
const char *_ar_program_name        = "ar";
const char *_cxxfilt_program_name   = "c++filt";
const char *_nm_program_name        = "nm";
const char *_objcopy_program_name   = "objcopy";
const char *_objdump_program_name   = "objdump";
const char *_size_program_name      = "size";
const char *_srconv_program_name    = "srconv";
const char *_strings_program_name   = "strings";
const char *_sysdump_program_name   = "sysdump";
const char *_windmc_program_name    = "windmc";

// TODO: `as` command
extern int _addr2line_main (int argc, char **argv);
extern int _ar_main        (int argc, char **argv);
extern int _cxxfilt_main   (int argc, char **argv);
extern int _elfedit_main   (int argc, char **argv);
extern int _nm_main        (int argc, char **argv);
extern int _objcopy_main   (int argc, char **argv);
extern int _objdump_main   (int argc, char **argv);
extern int _readelf_main   (int argc, char **argv);
extern int _size_main      (int argc, char **argv);
extern int _srconv_main    (int argc, char **argv);
extern int _strings_main   (int argc, char **argv);
extern int _sysdump_main   (int argc, char **argv);
extern int _windmc_main    (int argc, char **argv);
// extern int _ranlib_main    (int argc, char **argv);
// extern int _strip_main     (int argc, char **argv);

typedef struct {
    const char *name;
    int (* main_fn)(int, char **);
} main_dispatch;

int is_strip = 0;
int is_ranlib = 0;

static int _ranlib_main(int argc, char **argv) {
    is_ranlib = 1;
    return _ar_main(argc, argv);
}

static int _strip_main(int argc, char **argv) {
    is_strip = 1;
    return _objcopy_main(argc, argv);
}

static main_dispatch dispatch[] = {
    {"addr2line", _addr2line_main},
    {"ar",        _ar_main},
    {"c++filt",   _cxxfilt_main},
    {"elfedit",   _elfedit_main},
    {"nm",        _nm_main},
    {"objcopy",   _objcopy_main},
    {"objdump",   _objdump_main},
    {"ranlib",    _ranlib_main},
    {"readelf",   _readelf_main},
    {"size",      _size_main},
    {"srconv",    _srconv_main},
    {"strings",   _strings_main},
    {"strip",     _strip_main},
    {"sysdump",   _sysdump_main},
    {"windmc",    _windmc_main},
    {0, 0},
};

static void usage(const char *argv0) {
    fprintf(stderr, "Usage:\n");
    fprintf(stderr, "    %s <command>    [arguments...]\n", argv0);
#if 0
    fprintf(stderr, "\nGNU Assembler:\n");
    fprintf(stderr, "    %s as <cpu>     [arguments...]\n", argv0);
    fprintf(stderr, "    %s as <triplet> [arguments...]\n", argv0);
    fprintf(stderr, "    %s -c, --cpus\n", argv0);
    fprintf(stderr, "    %s -t, --triplets\n", argv0);
#endif
    fprintf(stderr, "\nCommands:\n");
    fprintf(stderr, "    as\n");
    main_dispatch *pos = dispatch;
    while (pos->name) {
        fprintf(stderr, "    %s\n", pos->name);
        pos++;
    }
    fprintf(stderr, "\n");
}

static main_dispatch *get_cmd(const char *name) {
    main_dispatch *pos = dispatch;
    while (pos->name) {
        if (strcmp(pos->name, name) == 0) {
            return pos;
        }
        pos++;
    }
    return NULL;
}

int main(int argc, char **argv) {
    if (argc < 1) {
        usage("binutils");
        return 1;
    }
    main_dispatch *cmd = get_cmd(argv[0]);
    if (! cmd) {
        const char *name = argv[1];
#if 0
        if (strcmp(name, "as") == 0) {
            fprintf(stderr, "error: as not yet supported\n");
            return 1;
        } else if (strcmp(name, "-c") == 0 || strcmp(name, "--cpus") == 0) {
            fprintf(stderr, "error: as not yet supported\n");
            return 1;
        } else if (strcmp(name, "-t") == 0 || strcmp(name, "--triplets") == 0) {
            fprintf(stderr, "error: as not yet supported\n");
            return 1;
        }
#endif
        cmd = get_cmd(name);
    }
    if (cmd) {
        return cmd->main_fn(argc - 1, argv + 1);
    }
    usage(argv[0]);
    return 1;
}
