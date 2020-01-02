# set the working dir, where all compiled verilog goes
vlib work

# compile all verilog modules in mux.v to working dir
# could also have multiple verilog files
vlog W:/ECE241_SIM/main/logic_main.v
vlog W:/ECE241_SIM/main/main_controller.v
vlog W:/ECE241_SIM/main/main_datapath.v
vlog W:/ECE241_SIM/main/main.v

vlog W:/ECE241_SIM/Stage_1_getElement/getElement.v
vlog W:/ECE241_SIM/Stage_1_getElement/getElement_controller.v
vlog W:/ECE241_SIM/Stage_1_getElement/getElement_datapath.v

vlog W:/ECE241_SIM/Stage_2_convertValues/convertValues.v
vlog W:/ECE241_SIM/Stage_2_convertValues/convertValues_controller.v
vlog W:/ECE241_SIM/Stage_2_convertValues/convertValues_datapath.v

vlog W:/ECE241_SIM/misc/bcd7seg.v
vlog W:/ECE241_SIM/misc/clearScreen.v

vlog W:/ECE241_SIM/divider.v
vlog W:/ECE241_SIM/int_to_fp.v
vlog W:/ECE241_SIM/fp_to_int.v
vlog W:/ECE241_SIM/multiplier.v
vlog W:/ECE241_SIM/adder.v
vlog W:/ECE241_SIM/subtractor.v

vlog W:/ECE241_SIM/Stage_3_buildNodeList/buildNodeList.v
vlog W:/ECE241_SIM/Stage_3_buildNodeList/buildNodeList_controller.v
vlog W:/ECE241_SIM/Stage_3_buildNodeList/buildNodeList_datapath.v

vlog W:/ECE241_SIM/Stage_4_chooseRefNode/chooseRefNode.v
vlog W:/ECE241_SIM/Stage_4_chooseRefNode/chooseRefNode_controller.v
vlog W:/ECE241_SIM/Stage_4_chooseRefNode/chooseRefNode_datapath.v

vlog W:/ECE241_SIM/Stage_5_searchSuperNode/searchSuperNode.v
vlog W:/ECE241_SIM/Stage_5_searchSuperNode/searchSuperNode_controller.v
vlog W:/ECE241_SIM/Stage_5_searchSuperNode/searchSuperNode_datapath.v

vlog W:/ECE241_SIM/Stage_6_generateEquations/generateEquations.v
vlog W:/ECE241_SIM/Stage_6_generateEquations/generateEquations_controller.v
vlog W:/ECE241_SIM/Stage_6_generateEquations/generateEquations_datapath.v

vlog W:/ECE241_SIM/Stage_7_solveMatrix/solveMatrix.v
vlog W:/ECE241_SIM/Stage_7_solveMatrix/solveMatrix_controller.v
vlog W:/ECE241_SIM/Stage_7_solveMatrix/solveMatrix_datapath.v

vlog W:/ECE241_SIM/Stage_8_calculateVoltage/calculateVoltage.v
vlog W:/ECE241_SIM/Stage_8_calculateVoltage/calculateVoltage_controller.v
vlog W:/ECE241_SIM/Stage_8_calculateVoltage/calculateVoltage_datapath.v

vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit.v
vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit_controller.v
vlog W:/ECE241_SIM/Stage_10_configureCircuit/configureCircuit_datapath.v

vlog W:/ECE241_SIM/Stage_11_drawCircuit/drawCircuit.v
vlog W:/ECE241_SIM/Stage_11_drawCircuit/drawCircuit_controller.v
vlog W:/ECE241_SIM/Stage_11_drawCircuit/drawCircuit_datapath.v

vlog W:/ECE241_SIM/element.v
vlog W:/ECE241_SIM/float_register.v
vlog W:/ECE241_SIM/nodeHeads.v
vlog W:/ECE241_SIM/nodeToElement.v
vlog W:/ECE241_SIM/refNodes.v
vlog W:/ECE241_SIM/float_matrix.v
vlog W:/ECE241_SIM/nodeVoltage.v
vlog W:/ECE241_SIM/draw_processor.v

vlog vSprite.v
vlog cSprite.v
vlog rSprite.v
vlog dot.v

#load simulation using mux as the top level simulation module
vsim -L altera_mf_ver -L lpm_ver final_project
#final_project


#log all signals and add some signals to waveform window
log {/*}
# add wave {/*} would add all items in top level simulation module


add wave {CLOCK_50}
add wave {KEY[3]}
add wave {KEY}
add wave {SW}
add wave {LEDR}

#add wave {element_addr}
#add wave {element_data}
#add wave {element_wren}
#add wave {element_out}
#
#add wave {int_to_fp_data}
#add wave {int_to_fp_out}
#add wave {multiplier_data_a}
#add wave {multiplier_data_b}
#add wave {multiplier_out}
#add wave {divider_data_a}
#add wave {divider_data_b}
#add wave {divider_out}
#
#
#add wave {float_register_addr}
#add wave {float_register_data}
#add wave {float_register_wren}
#add wave {float_register_out}





add wave {CLOCK_50}
add wave {nodeToElement_wren}
add wave {nodeToElement_addr}
#add wave {nodeToElement_data}
# 1 ? end of list : not end
add wave {nodeToElement_out[63]}
# addr of next element
#add wave {nodeToElement_out[62:58]}
# 1 ? curr node is node A : node B
add wave {nodeToElement_out[44]}
# addr of the other node
add wave {nodeToElement_out[43:39]}
# addr of the current node
add wave {nodeToElement_out[38:34]}
# element type
add wave {nodeToElement_out[33:32]}
# element value
add wave {nodeToElement_out[31:0]}

add wave {cs}
add wave {ns}
add wave {cs10}
add wave {ns10}
add wave {cs11}
add wave {ns11}
#add wave {cs1}
#add wave {ns1}
#add wave {cs2}
#add wave {ns2}
#add wave {cs3}
#add wave {ns3}
#add wave {cs4}
#add wave {ns4}
#add wave {cs5}
#add wave {ns5}
#add wave {cs6}
#add wave {ns6}
#add wave {cs7}
#add wave {ns7}
#add wave {cs8}
#add wave {ns8}

add wave {numElements}
add wave {numNodes}
add wave {numRefNodes}
add wave {ground_node}
add wave {numCommands}

##Stage 10
#add wave {data_reset_done}
#add wave {signals_cleared}
#add wave {dashed_node_line_written}
#add wave {go_reset_data}
#add wave {go_clear_signals}
#add wave {write_dashed_node_line}

#stage 11
add wave {go_reset_data}
add wave {go_read_processor}
add wave {go_clear_signal}
add wave {data_reset_done}
add wave {finished_all}
add wave {command_read}
add wave {signals_cleared}
add wave {done_draw_command}





#add wave {CLOCK_50}
#add wave {refNodes_wren}
#add wave {refNodes_addr}
#add wave {refNodes_data}
#add wave {refNodes_out}

add wave {CLOCK_50}
add wave {nodeHeads_wren}
add wave {nodeHeads_addr}
#add wave {nodeHeads_data}
#builded ? 
#ref node set ?
add wave {nodeHeads_out[63]}

#current addr for search
#add wave {nodeHeads_out[51:47]}
#first addr for search
add wave {nodeHeads_out[46:42]}

#index for eqn
add wave {nodeHeads_out[41:37]}

#addr of ref node
add wave {nodeHeads_out[36:32]}

#voltage diff
add wave {nodeHeads_out[31:0]}

add wave {CLOCK_50}
add wave {matrix_wren_a}
add wave {matrix_addr_a}
#add wave {matrix_data_a}
add wave {matrix_out_a}
#add wave {matrix_wren_b}
#add wave {matrix_addr_b}
#add wave {matrix_data_b}
#add wave {matrix_out_b}

add wave {CLOCK_50}
#add wave {nodeVoltage_wren}
#add wave {nodeVoltage_addr}
#add wave {nodeVoltage_data}
#add wave {nodeVoltage_out}
add wave {processor_addr}
#add wave {processor_data}
add wave {processor_wren}
add wave {processor_out[47]}
add wave {processor_out[46:38]}
add wave {processor_out[37:29]}
add wave {processor_out[28:19]}
add wave {processor_out[18:10]}
add wave {processor_out[9:0]}


add wave {CLOCK_50}
add wave {vga_x}
add wave {vga_y}
add wave {vga_wren}
add wave {vga_in}


force {CLOCK_50} 1 0ns, 0 {10ns} -r 20ns
force {SW} 10'b0000000010
force {KEY} 4'b1110
#force {go} 0 0ns, 1 {80ns} -r 160ns
#
#force {program_reset} 1
#force {input_reset} 0
#force {input_over} 0
#force {go} 0
#force {data_in} 10'b0
#force {start_process} 0
#
#run 50ns
#
#force {program_reset} 0
#force {start_process} 1
#run 40ns

run 30ns
force {KEY[0]} 1
run 20ns

force {KEY[1]} 0
run 40ns

force {KEY[1]} 1

run 40ns

#####################

#start element no#1
force {KEY[3]} 0
run 20ns

force {KEY[3]} 1
run 20ns

# voltage
force {SW} 10'd0 
force {KEY[3]} 0
run 20ns

force {KEY[3]} 1
run 20ns

# 20V
force {SW} 10'd2
force {KEY[3]} 0
run 20ns

force {KEY[3]} 1
run 20ns

# E1
force {SW} 10'd1
force {KEY[3]} 0
run 20ns

force {KEY[3]} 1
run 20ns

# Node A-1, Node B-2
force {SW} 10'b0000100010
force {KEY[3]} 0
run 20ns

force {KEY[3]} 1
run 100ns
#end

#######################

force {KEY[2]} 0
run 20ns

force {KEY[2]} 1

run 10000ns

force {KEY[3]} 0
run 40ns

force {KEY[3]} 1
run 40ns


force {KEY[3]} 0
run 40ns

force {KEY[3]} 1
run 40ns

force {SW} 10'd1

force {KEY[2]} 0
run 40ns

force {KEY[2]} 1
run 40ns

run 30000ns

#####################################################
force {KEY[0]} 0

run 60ns

force {KEY[0]} 1