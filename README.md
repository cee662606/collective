# Neural Avalanche Detection & Self-Organized Criticality (SOC) in Neural Data

This repository presents a rigorous, fully independent MATLAB-based pipeline for analyzing **neuronal avalanches** and probing **self-organized criticality (SOC)** in neural spike recordings.

---

## Project Highlights

- **Fully self-developed**: Designed, implemented, and tested independently with no external dependencies.
- **Supports multiple formats**: Handles `.ntt`, `.spike`, `.bounds` from **Neuralynx** and **MClust** ecosystems.
- **Precise spike set construction**: Aligns timestamps, waveforms, and clustering info into one coherent `spikeset` struct.
- **Statistical robustness**: Validated for avalanche size/distribution, inter-avalanche intervals, and scaling collapse.
- **Tailored for SOC research**: Easily extendable to power-law fitting, branching ratio estimation, finite-size scaling, etc.
- Used in a formal SOC study on rodent cortical recordings.

---

## Structure & Key Scripts

| File                | Purpose                                                                 |
|---------------------|-------------------------------------------------------------------------|
| `make_spikeset.m`   | Constructs the full spike structure from `.ntt`/`.spike` and `.clusters` files. |
| `FindInCluster.m`   | Interprets cluster polygons and extracts points from `.clusters` files. |
| `loadDotspike.m`    | (Optional) Parses custom `.spike` formats.                              |
| `Nlx2MatSpike.mex`  | C++/MATLAB interface to read Neuralynx `.ntt` spike files. Required.    |

---

## Output Data Structure

The primary output is a MATLAB struct named `spikeset` with the following fields:

## MATLAB
spikeset.primary.times               % Vector of spike timestamps
spikeset.waveforms                   % 30 matrix: waveforms [channels × spikes]
spikeset.cluster_membership          % Logical matrix: [spikes × clusters]
spikeset.u                           % Mean waveform per cluster
spikeset.params.sampling_frequency   % Sampling rate of recording

---

This framework is suitable for scaling analysis and criticality diagnostics.
The code is standalone: no external libraries or toolboxes are required. But need external data to study.
Fully compatible with custom datasets, but assumes pre-sorted spikes with cluster metadata.
