# MAP-T-BR-Benchmarking

This repository contains the Maptperf benchmarking tool and configuration scripts used to configure MAP-T Border Relay (BR) implementations for the experiments. The repository is organized into two top-level directories: `Maptperf/` and `DUT configuration/`.

## MAPTPERF: A Benchmarking Tool for MAP-T

MAPTPERF is a high-performance benchmarking tool designed to evaluate the performance and scalability of Mapping of Address and Port using Translation (MAP-T) Border Relay (BR) implementations. Developed in C++ using the Data Plane Development Kit (DPDK), MAPTPERF generates and measures network traffic at high packet rates, enabling systematic evaluation of MAP-T forwarding performance.

The tool supports benchmarking of key performance metrics, including throughput, latency, Packet Delay Variation (PDV), and Frame Loss Rate (FLR). It provides configurable test parameters, traffic generation, packet transmission and reception statistics, and test results that help characterize MAP-T Border Relay performance under different traffic conditions and resource configurations.

MAPTPERF was developed to facilitate systematic and reproducible benchmarking of MAP-T implementations. Its benchmarking methodology is based on the recommendations of RFC 8219 and according to its single Device Under Test (DUT) test setup, providing a foundation for evaluating MAP-T performance under controlled experimental conditions.

This repository contains the MAPTPERF source code, test scripts, tester configuration, and example configuration files for the MAP-T Border Relay under test. The following sections describe the repository structure, configuration procedures, and execution of the available benchmarking tests.

## Repository structure

```text
MAP-T-BR-Benchmarking/
├── DUT configuration/
│   ├── Jool/
│   │   └── Jool-BR-Configuration setter.sh
│   └── VPP/
│       ├── VPP-BR-configuration setter.sh
│       └── startup.conf
└── Maptperf/
    ├── Source files/
    │   ├── Makefile
    │   ├── Makefile-lat
    │   ├── Makefile-pdv
    │   ├── Makefile-tp
    │   ├── defines.h
    │   ├── includes.h
    │   ├── latency.c
    │   ├── latency.h
    │   ├── main-lat.c
    │   ├── main-pdv.c
    │   ├── main-tp.c
    │   ├── pdv.c
    │   ├── pdv.h
    │   ├── throughput.c
    │   └── throughput.h
    ├── Test scripts/
    │   ├── FLR.sh
    │   ├── Latency.sh
    │   ├── PDV.sh
    │   └── Throughput.sh
    └── maptperf.conf
```

## Contents

### `Maptperf/`

This directory contains the tester software and experiment scripts.

- **`Source files/`** contains the C source and header files, together with separate Makefiles for the general build and throughput, latency, and packet-delay-variation (PDV) test programs.
- **`Test scripts/Throughput.sh`** runs repeated throughput trials using a binary search for the offered packet rate. Its parameters include the frame size, traffic direction, foreground/background traffic mix, experiment duration, timeout, measurement error window, number of repetitions, and results directory.
- **`Test scripts/Latency.sh`** runs latency trials at the packet rate measured by the throughput experiment, and includes parameters for the identifying tags used by the latency measurement.
- **`Test scripts/PDV.sh`** runs PDV trials at the packet rate measured by the throughput experiment.
- **`Test scripts/FLR.sh`** runs frame-loss-rate trials using iteration of configured frame rates.
- **`maptperf.conf`** provides tester-side settings, including interface addresses and MAC addresses, port ranges and port variation, MAP rule parameters, simulated CE count, CPU-core assignments, memory-channel count, traffic directions, and promiscuous mode state.

The test scripts contain experiment-specific parameter values in their parameter sections. Review and adjust those values for the intended test before running a script. In particular, check the implementation label, direction, frame size, offered-rate limit, duration, foreground/background mix, repetition count, and output directory.

### `DUT configuration/`

This directory contains the scripts and startup configuration for the two MAP-T BR implementations, Jool and FD.io VPP.

- **`Jool/Jool-BR-Configuration setter.sh`** configures the Linux interfaces and routes, enables IPv4/IPv6 forwarding, creates a Jool MAP-T instance and forwarding-map rule, installs the relevant iptables rules, and sets neighbour information. The comments identify it as a configuration for the BME R730 (TS1) with EA length 13 bits.
- **`VPP/VPP-BR-configuration setter.sh`** configures the VPP interfaces, creates the MAP-T domain and route, enables MAP-T on the interfaces, and sets neighbour information. Its comments likewise identify the BME R730 (TS1) and EA length 13 bits.
- **`VPP/startup.conf`** is the VPP startup configuration supplied in this repository. It includes CPU settings and configuration sections for other VPP facilities. Check the active and commented-out settings in this file against the VPP version and test setup before reusing it.

## Configuration notes

The checked-in tester and BR scripts use example/documentation IPv4 and IPv6 prefixes and specific interface names, MAC addresses, and CPU assignments. These values must match the actual testbed before execution. Do not run the scripts unchanged on a different machine or network without checking their commands and adapting the settings.

The scripts include settings for an EA length of 13 bits. If a different EA length or MAP rule is tested, the MAP domain/forwarding-map settings and the corresponding tester configuration must be made consistent.

The configuration files are supplied as experiment artifacts; their presence alone does not establish that every parameter is appropriate for every VPP/Jool version or test setup. Record the exact software versions and any local modifications used for a reported experiment.

## Building Maptperf

The repository provides the following Makefiles under `Maptperf/Source files/`:

- `Makefile`
- `Makefile-tp`
- `Makefile-lat`
- `Makefile-pdv`

Build instructions depend on the installed DPDK/toolchain environment and the Makefile variables. Inspect the relevant Makefile and ensure its dependency paths and compiler settings match the test machine. The shell scripts invoke the resulting executables from `Maptperf/` under `./build/`, including `maptperf-tp`, `maptperf-lat`, and `maptperf-pdv`; ensure the required binaries are built at those paths before running the scripts. The FLR script should likewise be checked for its expected executable paths and dependencies.

## Binding DPDK Interfaces on the DUT

Before running an experiment, the network interfaces of the DUT must be bound to the appropriate DPDK-compatible driver. The binding procedure depends on the targeted MAP-T implementation (Jool or VPP).

1. Jool Implementation

When Jool is the targeted implementation, the DUT interfaces must be bound manually using dpdk-devbind.py and the uio_pci_generic driver. The PCI addresses depend on the DUT used in the test setup; therefore, the addresses shown below apply only to the Jool DUT in TS1 and must be adjusted for any other test system setup if its PCI addresses differ.

For TS1, the following commands on the Jool DUT can be used:

modprobe uio_pci_generic

dpdk-devbind.py --bind=uio_pci_generic 0000:01:00.0

dpdk-devbind.py --bind=uio_pci_generic 0000:01:00.1

dpdk-devbind.py --status

The final command displays the current device-to-driver bindings, allowing the user to verify that the intended interfaces are bound to uio_pci_generic. For any other test system setup, replace the example PCI addresses with those corresponding to the interfaces of the DUT.

2. VPP Implementation

When VPP is the targeted implementation, the DUT interfaces are bound through VPP's DPDK configuration in the startup.conf file. The relevant interfaces must be specified in the [DPDK] section of this file using their corresponding PCI addresses. VPP performs the binding when it starts, according to this configuration.

This procedure applies to any other test system setup. However, the PCI addresses specified in startup.conf must correspond to the interfaces installed in the DUT used for the respective test system setup.

## Running the test scripts

Run the relevant script from the `Maptperf/` directory after configuring the tester and the DUT, and after verifying the script's parameter values. For example, the throughput script is:

```bash
cd Maptperf
bash "Test scripts/Throughput.sh"
```

The other supplied scripts are `Latency.sh`, `PDV.sh`, and `FLR.sh` in the same directory. These scripts initiate repeated experiments and write log/CSV output; inspect each script for its output filenames and result-handling behavior before a run. A complete experiment also requires the corresponding tester and DUT setup to be active and the network interfaces to be connected as in the experimental topology.

## Test Outputs and Generated Files

Upon completion of a Maptperf test, several output files are generated. The files provided in this repository are examples; their contents may differ depending on the type of test performed, the test configuration, and the measured results.

The principal output files are described below.

1. maptperf.conf — Tester Configuration

The maptperf.conf file contains the configuration parameters used by Maptperf to configure the tester for the experiment. It specifies the tester and DUT network parameters, including IP and MAC addresses, port-selection parameters, MAP rule parameters, CPU-core assignments, and traffic directions.

This file should be retained with the experimental results because it documents the tester configuration used for the test. The supplied maptperf.conf is an example, and its parameter values should not be assumed to apply to every experiment.

2. nohup.out — Test Execution Output

The nohup.out file contains the output produced during test execution when the program's standard output is redirected through nohup. It records the offered testing rates, the commands executed, the numbers of frames sent and received in each direction, and the outcome of individual test iterations. For example, an iteration may be reported as TEST PASSED or TEST FAILED, depending on whether the received frame counts satisfy the test requirements.

This file provides a record of the test execution and is useful for examining the sequence of tested rates and identifying the rates at which packet loss or other test failures occur.

3. ratetest.log — Detailed Test Log

The ratetest.log file contains a detailed record of the rate-testing procedure. It includes the test identification and configuration parameters, timestamps, offered frame rates, iteration numbers, frame transmission and reception statistics, and pass/fail outcomes. It also records the progression of the rate-search procedure as Maptperf adjusts the offered rate to determine the maximum rate satisfying the test criteria.

This log is useful for examining the measurement procedure in detail and understanding how the final reported rate was obtained.

4. rate.csv — Summary of Rate Measurements

The rate.csv file contains a tabular summary of the rate-test results. Its columns include the test number, frame size, traffic direction, parameters n and m, test duration, initial rate, timeout, measurement error, date, number of iterations, and final measured rate.

This file provides a convenient way to collect and compare results across repeated test runs without examining the detailed logs individually.

## Reproducibility information to record

For each published measurement, record at least:

- test setup/topology ;
- DUT implementation and exact software version (VPP or Jool, plus relevant operating-system and DPDK versions);
- hardware, NICs, link speed, CPU model/frequency, and CPU/worker assignments;
- the exact versions of `startup.conf`, the BR setter script, `maptperf.conf`, and the test script used;
- frame size, traffic direction, foreground/background traffic proportions, offered-rate/search settings, duration, repetitions, and any deviations from the checked-in defaults;
- The tester configuration used for the experiments (i.e., Maptperf.conf contents) and the resulting logs/CSV files.


