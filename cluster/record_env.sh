#!/bin/bash
# Records the node and software of a job.  Usage: cluster/record_env.sh OUTFILE
ROOT=$(cd "$(dirname "$0")/.." && pwd)
{
  echo "date $(date -Iseconds) host $(hostname -s) job ${SLURM_JOB_ID:-none} partition ${SLURM_JOB_PARTITION:-none}"
  echo "exclusive: $(scontrol show job "$SLURM_JOB_ID" 2>/dev/null | grep -o 'OverSubscribe=[A-Z]*')  cpus: ${SLURM_JOB_CPUS_PER_NODE:-?}"
  grep -m1 'model name' /proc/cpuinfo; grep -m1 microcode /proc/cpuinfo; uname -r; grep PRETTY_NAME /etc/os-release
  echo "governor $(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_governor) driver $(cat /sys/devices/system/cpu/cpu3/cpufreq/scaling_driver)"
  echo "no_turbo $(cat /sys/devices/system/cpu/intel_pstate/no_turbo 2>/dev/null) smt $(cat /sys/devices/system/cpu/smt/control)"
  echo "thp $(cat /sys/kernel/mm/transparent_hugepage/enabled)"
  echo "load $(cat /proc/loadavg); processes of other users: $(ps -eo user= | grep -vcE "^(root|$USER|dbus|chrony|polkitd|rpc|munge|slurm|nobody|lldpd|systemd.*|tss|sssd|nslcd|ntp|nscd|avahi|colord|rtkit|libstoragemgmt|gdm|postfix|telegraf|node_exporter|prometheus|zabbix|ganglia|nrpe)$")"
  echo "modules: $(module -t list 2>&1 | tr '\n' ' ')"
  echo "gcc: $(gcc --version | head -1)"
  echo "julia: $("$ROOT/.local/bin/julia" --version)"
  echo "libraries (Manifest):"; grep -A3 -E '^\[\[deps\.(PureBLAS|UlmBLAS|OpenBLAS_jll|blis_jll|MKL_jll|libblastrampoline_jll)\]\]' "$ROOT/cluster/Manifest.toml" | grep -E 'deps|version|git-tree|repo-rev' 
  echo "--- lscpu"; lscpu
  echo "--- numactl"; numactl -H | head -8
} > "$1" 2>&1
