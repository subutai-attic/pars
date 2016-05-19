set PROJ_NAME tx_selio_lvds
set BD_DESIGN system 
set PROJ_TCL tx.tcl
set BD_TCL tx_BD.tcl
 
# Create the project
source $PROJ_TCL -notrace
set proj_dir [get_property directory [current_project]]
    
# Create the block design inside of the project
puts "Create bd..."
source $BD_TCL -notrace
puts "Created $BD_DESIGN"
 
# Update the blockdiagram
regenerate_bd_layout; save_bd_design;
 
# Create the hdl wrapper files for the block design and add them to the project
# make_wrapper -files [get_files $BD_DESIGN.bd] -top -import
make_wrapper -files [get_files $proj_dir/${PROJ_NAME}.srcs/sources_1/bd/$BD_DESIGN/$BD_DESIGN.bd] -top
add_files -norecurse $proj_dir/${PROJ_NAME}.srcs/sources_1/bd/$BD_DESIGN/hdl/${BD_DESIGN}_wrapper.v
update_compile_order -fileset sources_1   
puts "Created bd_design $BD_DESIGN for $PROJ_NAME"
