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

# dft defaults
set ::env(DFT_TV_CEILING) "10"
set ::env(DFT_MIN_COVERAGE) "80"
set ::env(DFT_NUM_THREADS) "10"
set ::env(DFT_RESET_ACTIVE_LOW) 0
set ::env(DFT_IGNORED_INPUTS) ""
set ::env(DFT_INSERT_JTAG)  1
set ::env(DFT_RUN_JTAG_SIM) 1
set ::env(DFT_RUN_CHAIN_SIM) 1
set ::env(DFT_RUN_PGEN) 1

set ::env(RUN_DFT) 1

# Move to open_pdk ? 
set ::env(DFF_CELLS)  "sky130_fd_sc_hd__dfrtp_1 sky130_fd_sc_hd__dfrtp_2 sky130_fd_sc_hd__dfrtp_4 sky130_fd_sc_hd__dfxtp_1 sky130_fd_sc_hd__dfxtp_2 sky130_fd_sc_hd__dfxtp_4 \
                       sky130_fd_sc_hd__dfstp_1 sky130_fd_sc_hd__dfstp_2 sky130_fd_sc_hd__dfstp_4"
set ::env(SIM_DEFINE) "FUNCTIONAL UNIT_DELAY=#1"

