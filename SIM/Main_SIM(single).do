# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files


vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit.v
vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit_controller.v
vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit_datapath.v



#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver -L lpm_ver configureCircuit_main
#final_project


#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module


add wave {/*}


force {clk} 1 0ns, 0 {10ns} -r 20ns
force {program_reset} 1
run 30ns

force {program_reset} 0
run 200ns