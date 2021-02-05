proc write_cut_netlist {args}  {
    puts_info "Generating Cut Netlist..."
    if {![info exists ::env(DFT_IGNORED_INPUTS)]} {
		set ::env(DFT_IGNORED_INPUTS) $::env(CLOCK_PORT)
	}
    
    set dff_list ""
    foreach dff $::env(DFF_CELLS) {
        append dff_list "," $dff
    }

    try_catch fault cut $::env(CURRENT_NETLIST) --dff $dff_list -o $::env(dft_result_file_tag).cut.v \
    |& tee $::env(TERMINAL_OUTPUT) $::env(dft_log_file_tag)_cut.fault.log
}

proc run_pgen {args} {
    puts_info "Running Test Vector Simulations..."
    set scl_verilog $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/$::env(STD_CELL_LIBRARY).v
    set scl_primitive $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/primitives.v

    set ignored_list ""
    foreach input $::env(DFT_IGNORED_INPUTS) {
        append ignored_list "," $input
    }
    append ignored_list "," $::env(CLOCK_PORT)
    append ignored_list "," $::env(RESET_PORT)

    set sim_define ""
    foreach def $::env(SIM_DEFINE) {
        append sim_define $def ","
    }

    set hold_low_flag ""
    if { $::env(DFT_RESET_ACTIVE_LOW) == 0 } {
        # hold reset signal to low if it is active high
        set hold_low_flag "--holdLow"         
    }

    try_catch fault $::env(dft_result_file_tag).cut.v -r $::env(DFT_NUM_THREADS) -v $::env(DFT_NUM_THREADS) -m $::env(DFT_MIN_COVERAGE) --ceiling $::env(DFT_TV_CEILING) --ignoring $ignored_list \
                $hold_low_flag -c $scl_verilog --inc $scl_primitive --define $sim_define -o $::env(dft_result_file_tag).pgen \
    |& tee $::env(TERMINAL_OUTPUT) $::env(dft_log_file_tag)_pgen.fault.log
}


proc ins_scan_chain {args} {
    puts_info "Running Scan-Chain Insertion..."

    set sim_options ""
    if { $::env(DFT_RUN_CHAIN_SIM) == 1} {
        set scl_verilog $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/$::env(STD_CELL_LIBRARY).v
        set scl_primitive $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/primitives.v
        foreach def $::env(SIM_DEFINE) {
            append sim_define $def ","
        }
        append sim_define "," "CLOCK_PERIOD=10"
        set sim_flags [list "-c" $scl_verilog "--inc" $scl_primitive "--define" $sim_define]
        foreach flag $sim_flags {
            append sim_options $flag " "
        }
    }

    set dff_list ""
    foreach dff $::env(DFF_CELLS) {
        append dff_list $dff ","
    }

    set ignored_list ""
    foreach input $::env(DFT_IGNORED_INPUTS) {
        append ignored_list $input ","
    }
    
    set active_low_flag ""
    if { $::env(DFT_RESET_ACTIVE_LOW) == 1 } {
        append active_low_flag --activeLow
    }

    try_catch fault chain $::env(CURRENT_NETLIST) "$active_low_flag" $sim_options --ignoring $ignored_list --clock $::env(CLOCK_PORT) --reset $::env(RESET_PORT) --dff $dff_list -o $::env(dft_result_file_tag).chained.v -l $::env(LIB_SYNTH) \
    |& tee $::env(TERMINAL_OUTPUT) $::env(dft_log_file_tag)_chain.fault.log
}

proc ins_tap_port {args} {
    puts_info "Running JTAG Port Insertion..."
    set sim_flags ""
    if { $::env(DFT_RUN_JTAG_SIM) == 1} {
        set scl_verilog $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/$::env(STD_CELL_LIBRARY).v
        set scl_primitive $::env(PDK_ROOT)/$::env(PDK)/libs.ref/$::env(STD_CELL_LIBRARY)/verilog/primitives.v

        set sim_define "CLOCK_PERIOD=10"
        foreach def $::env(SIM_DEFINE) {
            append sim_define $def ","
        }   
        
        set sim_flags "-c $scl_verilog --inc $scl_primitive --define $sim_define \
            -g $::env(dft_result_file_tag).bin.out.bin \
            -t $::env(dft_result_file_tag).bin.vec.bin"
    }

    set ignored_list ""
    foreach input $::env(DFT_IGNORED_INPUTS) {
        append ignored_list $input ","
    }

    set active_low_flag ""
    if { $::env(DFT_RESET_ACTIVE_LOW) == 1 } {
        set active_low_flag "--activeLow"
    }

   try_catch fault tap $::env(dft_result_file_tag).chained.v --ignoring $ignored_list --clock $::env(CLOCK_PORT) --reset $::env(RESET_PORT) \ 
   -l $::env(LIB_SYNTH) -o $::env(dft_result_file_tag).tap.v \
   $active_low_flag $sim_flags \
   |& tee $::env(TERMINAL_OUTPUT) $::env(dft_log_file_tag)_jtag.fault.log
}

proc run_asm {args} {
    puts_info "Assembling Test vectors..."
    try_catch fault asm -o $::env(dft_result_file_tag).bin  $::env(dft_result_file_tag).pgen.tv.json $::env(dft_result_file_tag).chained.v
}

proc re_run_synth {args} {
    puts_info "Re-synthesizing DFT Netlist..."
    set options {
	{-netlist required}
    }
    set flags {}
    parse_key_args "re_run_synth" args arg_values $options flags_map $flags

    set ::env(VERILOG_FILES) $arg_values(-netlist)
    set ::env(SYNTH_READ_BLACKBOX_LIB) 1
    run_yosys
}

proc run_dft {args} {
    puts_info "Running DFT flow..."
	# |----------------------------------------------------|
	# |----------------   1.1. DFT       ------------------|
	# |----------------------------------------------------|
    write_cut_netlist 

    if { $::env(DFT_RUN_PGEN) == 1 } {
        run_pgen
    }

    ins_scan_chain
    
    set ::env(CLOCK_NET) [list "tck" "\__dut__.__uuf__.__clk_source__"] 
    puts_info  "Setting clock nets to $::env(CLOCK_NET)"
    
    re_run_synth -netlist $::env(dft_result_file_tag).chained.v.intermediate.v

    if { $::env(DFT_INSERT_JTAG) == 1} {        
        run_asm
        ins_tap_port
        re_run_synth -netlist $::env(dft_result_file_tag).tap.v.intermediate.v
    }

    exec $::env(SCRIPTS_DIR)/fault_report.sh $::env(dft_log_file_tag)_pgen.fault.log $::env(dft_log_file_tag)_chain.fault.log >> $::env(dft_report_file_tag).rpt
    puts_info "DFT was successful."
}

package provide openlane 0.9
