# Create Vivado project, with user HDL files & IP.
# Run this in IntegrationTests/xyz/script/ 

# Create project
set projName "Work"
source ../../../../project/fpga.tcl
create_project -force ${projName} ./${projName} -part $FPGA
set_property target_language VHDL [current_project]

# Rebuild user HLS IP repos index before adding any source files
set_property ip_repo_paths "./"  [get_filesets sources_1]
update_ip_catalog -rebuild

# Create .xci files for user HLS IP
create_ip -name MatchCalculator_L3PHIB -module_name MC_L3PHIB -vendor xilinx.com -library hls -version 1.0
create_ip -name MatchCalculator_L4PHIB -module_name MC_L4PHIB -vendor xilinx.com -library hls -version 1.0
create_ip -name MatchCalculator_L5PHIB -module_name MC_L5PHIB -vendor xilinx.com -library hls -version 1.0
create_ip -name MatchCalculator_L6PHIB -module_name MC_L6PHIB -vendor xilinx.com -library hls -version 1.0
create_ip -name TrackBuilder_L1L2 -module_name FT_L1L2 -vendor xilinx.com -library hls -version 1.0

# Provide name of top-level HDL (without .vhd extension).
#set topLevelHDL "SectorProcessor"
set topLevelHDL "SectorProcessorFull"

# Add HDL for algo
add_files -fileset sources_1 [glob ../hdl/SectorProcessor*.vhd]
add_files -fileset sources_1 [glob ../hdl/memUtil_pkg.vhd]
add_files -fileset sources_1 [glob common/hdl/*.vhd]
remove_files -fileset sources_1 [glob common/hdl/latency_monitor.vhd]

# Add HDL for TB
add_files -fileset sim_1 [glob ../tb/tb_tf_top.vhd]

# Add constraints (clock etc.)
add_files -fileset constrs_1 [glob common/hdl/constraints.xdc]

# Set 'sim_1' fileset properties
set_property file_type {VHDL 2008} [get_files -filter {FILE_TYPE == VHDL}]
set_property top -value ${topLevelHDL} -objects [get_filesets sources_1]
set_property top -value "tb_tf_top" -objects [get_filesets sim_1]
set_property xsim.simulate.runtime -value "0us" -objects  [get_filesets sim_1]

update_compile_order -fileset sources_1 

puts "INFO: Project created: ${projName}"

exit
