#!/bin/sh
# Copyright 2020 Efabless Corporation
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

if [ -e "$1" ]; then
    fault_points=$(perl -ne 'print "$1 $2 $3" if /^Found\s(\d+) fault sites in\s(\d+) gates and\s(\d+) ports\.$/' $1)
    run_time=$(perl -ne 'print "$1" if /^Time elapsed: (\d+\.\d+)s\.$/' $1)
    coverage=$(perl -ne 'print "$1" if /^Simulations concluded: Coverage (\d+\.\d+)%$/' $1)
    echo "Fault Sites: " $fault_points
    echo "Run time: $run_time s"
    echo "Coverage: $coverage %"
fi

if [ -e "$2" ]; then
    internal_flipflops=$(perl -ne 'print "$1" if /^Internal scan chain successfuly constructed\. Length:\s+(\d+)$/' $2)
    boundary_scan_cells=$(perl -ne 'print "$1" if /^Boundary scan cells successfuly chained\. Length:\s+(\d+)$/' $2)
    scan_chain_len=$(perl -ne 'print "$1" if /^Total scan-chain length:\s+(\d+)$/' $2)

    echo "Number of Scan Flip-Flops:  $internal_flipflops"
    echo "Number of Boundary Scan cells: $boundary_scan_cells"
    echo "Total Scan Chain Length: $scan_chain_len"
fi
