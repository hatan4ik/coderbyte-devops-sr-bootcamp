# Chaos Drill: Pod Kill Loop

Simple chaos script to delete pods matching a label every N seconds to observe resilience (PDB/HPA/anti-affinity) behavior.

## Usage
```bash
./chaos.sh app=hardened-app 60
```
- First arg: label selector (e.g., `app=observability-slo`).
- Second arg: interval seconds (default 60).

Ensure PDB/HPA and readiness/liveness probes are in place before running. Stop with Ctrl+C.
