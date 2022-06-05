#!/bin/bash -u

CFLAGS="-W -Wall -Wstrict-prototypes -Wshadow -I../../zlib --sysroot=/wasi-sdk-16.0/share/wasi-sysroot -D_WASI_EMULATED_SIGNAL"
LDFLAGS="-lwasi-emulated-signal -lwasi-emulated-getpid -L./../zlib"

libtool() {
    ./libtool --silent --tag=CC --mode=link /wasi-sdk-16.0/bin/clang $CFLAGS $LDFLAGS "$@"
}

CFLAGS2="$CFLAGS -DHAVE_CONFIG_H -I. -I../../binutils  -I. -I../../binutils -I../bfd -I../../binutils/../bfd -I../../binutils/../include -DLOCALEDIR="\"/opt/binutils-wasi/share/locale\"" -Dbin_dummy_emulation=bin_vanilla_emulation"
YACC_RENAMES="yylex yyparse yynerrs yychar yylval"
GLOBAL_RENAMES="main program_name"
for name in size addr2line ar cxxfilt elfedit nm objcopy objdump readelf srconv strings sysdump windmc \
                 arlex arparse mclex mcparse; do
    yyname="$name"
    path="../../binutils/${name}.c"
    LOCAL_RENAMES="$GLOBAL_RENAMES"
    case "$name" in
        ar|addr2line) yyname=ar;;
        windmc|mclex) yyname=mc;;
        arlex|arparse) yyname=ar; path="${name}.c";;
        mcparse) yyname=mc; path="${name}.c";;
        readelf)
            LOCAL_RENAMES="$GLOBAL_RENAMES load_debug_section free_debug_section close_debug_file open_debug_file reloc_at"
        ;;
    esac
    RENAMES=""
    for sym in $LOCAL_RENAMES; do
        RENAMES="$RENAMES -D${sym}=_${name}_${sym}"
    done
    for sym in $YACC_RENAMES; do
        RENAMES="$RENAMES -D${sym}=_${yyname}_${sym}"
    done
    echo "$name"
    clang $RENAMES $CFLAGS2 -c -o "${name}.o" "$path" -DOBJDUMP_PRIVATE_VECTORS="&objdump_private_desc_xcoff,"
done

common_objs="arlex.o arparse.o arsup.o binemul.o bucomm.o coffgrok.o debug.o demanguse.o dwarf.o elfcomm.o emul_vanilla.o filemode.o mclex.o mcparse.o od-xcoff.o prdbg.o rdcoff.o rddbg.o rename.o stabs.o unwind-ia64.o version.o winduni.o wrstabs.o"
main_objs="addr2line.o ar.o cxxfilt.o elfedit.o nm.o objcopy.o objdump.o readelf.o size.o srconv.o strings.o sysdump.o windmc.o"
libraries="../opcodes/libopcodes.la ../libctf/libctf.la ../bfd/libbfd.la ../libiberty/libiberty.a"

libtool -o binutils /root/binutils.c $main_objs $common_objs $libraries
