#!/bin/sh
# Records hardware, OS, compilers and pinned revisions to results/environment.txt.
ROOT=$(cd "$(dirname "$0")/.." && pwd); cd "$ROOT"; O=results/environment.txt
{
echo "date: $(date -u +%FT%TZ)"; sw_vers; uname -a | sed 's/^Darwin [^ ]* /Darwin /'
for k in machdep.cpu.brand_string hw.model hw.memsize hw.pagesize hw.cachelinesize hw.perflevel0.physicalcpu hw.perflevel1.physicalcpu \
  hw.perflevel0.l1dcachesize hw.perflevel0.l2cachesize hw.perflevel1.l1dcachesize hw.perflevel1.l2cachesize \
  hw.optional.arm.FEAT_SME hw.optional.arm.FEAT_SME2 hw.optional.arm.FEAT_SME_F64F64 hw.optional.arm.sme_max_svl_b; do echo "$k: $(sysctl -n $k 2>/dev/null)"; done
echo "power: $(pmset -g batt | head -2 | tr '\n' ' ')"; pmset -g | grep -i lowpowermode
echo "apple clang: $(/usr/bin/clang --version | head -1)"
echo "julia: $(.local/bin/julia --version)"
echo "PureBLAS rev: $(grep -A8 'deps.PureBLAS' Manifest.toml | grep repo-rev)"; echo "UlmBLAS rev: $(grep -A8 'deps.UlmBLAS' Manifest.toml | grep repo-rev)"
echo "BLIS PR #921: $(git -C .local/src/blis-pr921 rev-parse HEAD 2>/dev/null)"
echo "Homebrew OpenBLAS: $(brew list --versions openblas)"
echo "ulmBLAS artifact sha256: $(shasum -a 256 .local/depot/artifacts/*/lib/sme/libulmblas_lbt.dylib | cut -d' ' -f1)"
echo "other long-running processes at record time:"; ps -Ao etime,pcpu,comm -r | sed -n 2,6p | cut -c1-80
} > "$O"; cat "$O"
