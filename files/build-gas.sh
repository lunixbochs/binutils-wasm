#!/bin/bash -u

# derived from gas/configure.tgt
fixed_targets="loongarch32 loongarch64 ns32k-pc532-mach ns32k-pc532-uxpv ns32k-pc532-lites ns32k-unknown-netbsd"
wildcard_targets="aout scout cloudabi dragonfly freebsd kfreebsd-gnu generic xray hms sim elf rtems sysv4 solaris aros vxworks windiss"

install_target() {
    make -j$(nproc) &>> "log/$1.log"
    make install &>> "log/$1.log"
    if [[ -e "/opt/binutils-wasi/bin/as-$1" ]]; then
        echo "PASS: $1"
    else
        echo "FAIL: $1"
    fi
}

mkdir -p log
for target in $fixed_targets; do
    [[ -e "/opt/binutils-wasi/bin/as-$target" ]] && continue
    ../../gas/configure --target "$target" --program-suffix="-$target" "$@" &>> "log/$target.log"
    install_target "$target"
done

for cpu in aarch64 aarch64_be alpha am33_2.0 arceb armeb arm bfin c4x cr16 crisv32 crx epiphany fido hppa i386 ia16 ia64 ip2k iq2000 lm32 loongarch32 loongarch64 m32c m32r m32rle m5200 m68008 m68000 m6811 m68300 s12z mep microblazeel microblaze mipsel mips mt nds32be nds32le or1k pjl pj powerpcle powerpc riscv64be riscv64 riscvbe riscv rs6000 rl78 rx s390x s390 scoreel score shle sh sparc64 sparc86x sparclet sparclite sparc tilegxbe tilegx v850 visium wasm32 x86_64 xgate xtensa; do

    special_targets=
    case cpu in
        aarch64*) special_targets="fuschia haiku genode linux linux-gnu_ilp32 netbsd";;
        alpha*)   special_targets="vms osf linux linux-ecoff netbsd";;
        arc*)     special_targets="linux";;
        arm*)     special_targets="phoenix eabi kaos conix freebsd9 linux-eabi linux nacl netbsd wince-pe pe fuchsia haiku";;
        bfin*)    special_targets="linux-uclibc uclinux";;
        csky*)    special_targets="elf_abiv1 linux linux_abiv1";;
        frv*)     special_targets="linux";;
        hppa*)    special_targets="linux lites netbsd openbsd osf hpux hpux11 mpeix bsd hiux";;
        h8300*)   special_targets="linux";;
        i386*)    special_targets="beospe beos elfiamcu fuchsia haiku genode bsd netbsd openbsd linux lynxos redox msdosdjgpp go32 gnu msdos moss pe cygwin interix mingw nto-qnx nt rdos darwin";;
        ia64*)    special_targets="vms aix linux hpux netbsd";;
        m32r*)    special_targets="linux";;
        m68k*)    special_targets="linux uclinux gnu netbsd haiku";;
        metag*)   special_targets="linux";;
        mcore*)   special_targets="pe";;
        mips*)    special_targets="irix5 irix6 linux sde mti img haiku netbsd openbsd";;
        mn10300*) special_targets="linux";;
        moxie*)   special_targets="uclinux moxiebox";;
        nds32*)   special_targets="linux";;
        nios2*)   special_targets="linux";;
        ork1k*)   special_targets="linux";;
        ppc*)     special_targets="aix5.0 aix beos netbsd eabi haiku linux macos nto kaos";;
        riscv*)   special_targets="haiku";;
        rx*)      special_targets="linux";;
        s390*)    special_targets="linux tpf";;
        sh*)      special_targets="linux netbsd uclinux coff nto pe kaos";;
        shle*)    special_targets="kaos";;
        sparc*)   special_targets="haiku linux";;
        tic30*)   special_targets="coff";;
        tic4x*)   special_targets="coff";;
        c4x*)     special_targets="coff";;
        tic54x*)  special_targets="coff";;
        c54x*)    special_targets="coff";;
        vax*)     special_targets="netbsdaout netbsd linux-unknown";;
        z80*)     special_targets="coff";;
    esac

    for suffix in $special_targets $wildcard_targets; do
        target="$cpu-unknown-$suffix"
        [[ -e "/opt/binutils-wasi/bin/as-$target" ]] && continue
        ../../gas/configure --target "$target" --program-suffix="-$target" "$@" &>> "log/$target.log"
        install_target "$target"
    done
done
