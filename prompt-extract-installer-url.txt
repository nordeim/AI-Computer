please meticulously review the app installation script attached and then extract the actual download URL for the app installer based on my OS detail below.

OS: Ubuntu Linux 24.04.4

$ uname -a
Linux pop-os 6.11.0-26-generic #26~24.04.1-Ubuntu SMP PREEMPT_DYNAMIC Thu Apr 17 19:20:47 UTC 2 x86_64 x86_64 x86_64 GNU/Linux

$ cat /proc/cpuinfo 
processor       : 0
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz
stepping        : 7
microcode       : 0x2f
cpu MHz         : 1680.461
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 0
cpu cores       : 4
apicid          : 0
initial apicid  : 0
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid xsaveopt dtherm ida arat pln pts vnmi md_clear flush_l1d
vmx flags       : vnmi preemption_timer invvpid ept_x_only flexpriority tsc_offset vtpr mtf vapic ept vpid unrestricted_guest
bugs            : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit mmio_unknown
bogomips        : 6584.65
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

processor       : 1
vendor_id       : GenuineIntel
cpu family      : 6
model           : 42
model name      : Intel(R) Core(TM) i5-2500 CPU @ 3.30GHz
stepping        : 7
microcode       : 0x2f
cpu MHz         : 1596.301
cache size      : 6144 KB
physical id     : 0
siblings        : 4
core id         : 1
cpu cores       : 4
apicid          : 2
initial apicid  : 2
fpu             : yes
fpu_exception   : yes
cpuid level     : 13
wp              : yes
flags           : fpu vme de pse tsc msr pae mce cx8 apic sep mtrr pge mca cmov pat pse36 clflush dts acpi mmx fxsr sse sse2 ht tm pbe syscall nx rdtscp lm constant_tsc arch_perfmon pebs bts rep_good nopl xtopology nonstop_tsc cpuid aperfmperf pni pclmulqdq dtes64 monitor ds_cpl vmx smx est tm2 ssse3 cx16 xtpr pdcm pcid sse4_1 sse4_2 x2apic popcnt tsc_deadline_timer aes xsave avx lahf_lm epb pti ssbd ibrs ibpb stibp tpr_shadow flexpriority ept vpid xsaveopt dtherm ida arat pln pts vnmi md_clear flush_l1d
vmx flags       : vnmi preemption_timer invvpid ept_x_only flexpriority tsc_offset vtpr mtf vapic ept vpid unrestricted_guest
bugs            : cpu_meltdown spectre_v1 spectre_v2 spec_store_bypass l1tf mds swapgs itlb_multihit mmio_unknown
bogomips        : 6584.65
clflush size    : 64
cache_alignment : 64
address sizes   : 36 bits physical, 48 bits virtual
power management:

---

Based on the installation script provided and your system details, here is the step-by-step extraction of the actual download URL:

1.  **Platform Detection:** Your `uname -a` output starts with `Linux`. The script maps this to `platform="linux"`.
2.  **Architecture Detection:** Your `uname -a` output contains `x86_64`. The script maps this to `architecture="x64"`.
3.  **AVX2 Support Detection:** The script checks `/proc/cpuinfo` for the `avx2` flag. Looking at your provided CPU flags (`fpu vme de ... aes xsave avx ...`), your Intel Core i5-2500 processor supports `avx` but **does not** support `avx2` (AVX2 was introduced in later Intel generations like Haswell). Because `avx2` is missing, the script sets `has_avx2=false` and appends `-baseline` to the architecture string, resulting in `droid_architecture="x64-baseline"`.
4.  **Version and Base URL:** The script defines `VER="0.153.1"` and `BASE_URL="https://downloads.factory.ai"`.
5.  **Binary Name:** The script defines `binary_name="droid"`.

Using the script's URL construction template (`$BASE_URL/factory_cli/releases/$VER/$platform/$droid_architecture/$binary_name`), your exact download URL is:

**https://downloads.factory.ai/factory_cli/releases/0.153.1/linux/x64-baseline/droid**

https://chat.qwen.ai/s/d4aad627-0ea3-4423-9fdd-63b2966a092c?fev=0.2.66 
