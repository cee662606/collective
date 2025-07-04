# Neuronal Avalanches & Self-Organized Criticality (SOC) in Neural Data

This repository presents a rigorous, fully independent MATLAB-based pipeline for analyzing **neuronal avalanches** and probing **self-organized criticality (SOC)** in high-density neural recordings. The code is designed to handle real extracellular spike data (e.g., from tetrodes or stereotrodes), convert them into structured spike sets, extract avalanche statistics, and compute key SOC observables.

---

## Project Highlights

- **Fully self-developed**: Designed, implemented, and tested independently with no code dependencies.
- **Supports multiple formats**: Handles `.ntt`, `.spike`, `.clusters`, and `.bounds` formats from **Neuralynx** and MClust ecosystem.
- **Precise spike set construction**: Aligns timestamps, waveforms, and clustering info into one coherent `spikeset` struct.
- **Statistical robustness**: Validated for avalanche size/distribution, inter-avalanche intervals, and scaling collapse.
- **Tailored for SOC research**: Easily extendable to power-law fitting, branching ratio estimation, finite-size scaling, etc.
- Used in a formal SOC study on rodent cortical recordings.

---

## Structure & Key Scripts

| File | Purpose |
|------|---------|
| `make_spikeset.m` | Constructs the full spike structure from `.ntt`/`.spike` and `.clusters` files. |
| `FindInCluster.m` | Interprets cluster polygons and extracts point indices from `.clusters` files. |
| `loadDotspike.m` (if included) | Parses custom `.spike` formats. |
| `Nlx2MatSpike.mex*` | C++/MATLAB interface to read Neuralynx `.ntt` spike files. Required. |

---

## Output Data Structure

The primary output is a `spikeset` MATLAB structure with fields:

```matlab
spikeset.primary.times            % Vector of spike timestamps (μs)
spikeset.waveforms                % 3D matrix: [samples x channels x spikes]
spikeset.cluster.membership       % Logical matrix: [spikes x clusters]
spikeset.u                        % Mean waveform per cluster
spikeset.params.sampling_frequency
