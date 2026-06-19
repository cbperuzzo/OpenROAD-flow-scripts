if { [find_macros] != "" } {
  if { ![env_var_exists_and_non_empty RTLMP_RPT_DIR] } {
    set ::env(RTLMP_RPT_DIR) "$::env(OBJECTS_DIR)/rtlmp"
  }
  if { ![env_var_exists_and_non_empty RTLMP_RPT_FILE] } {
    set ::env(RTLMP_RPT_FILE) "partition.txt"
  }
  if { ![env_var_exists_and_non_empty RTLMP_BLOCKAGE_FILE] } {
    set ::env(RTLMP_BLOCKAGE_FILE) "$::env(OBJECTS_DIR)/rtlmp/partition.txt.blockage"
  }

  # If wrappers defined replace macros with their wrapped version
  if { [env_var_exists_and_non_empty MACRO_WRAPPERS] } {
    source $::env(MACRO_WRAPPERS)

    set wrapped_macros [dict keys [dict get $wrapper around]]
    set db [ord::get_db]
    set block [ord::get_db_block]

    foreach inst [$block getInsts] {
      if { [lsearch -exact $wrapped_macros [[$inst getMaster] getName]] > -1 } {
        set new_master [dict get $wrapper around [[$inst getMaster] getName]]
        puts "Replacing [[$inst getMaster] getName] with $new_master for [$inst getName]"
        $inst swapMaster [$db findMaster $new_master]
      }
    }
  }

  lassign $::env(MACRO_PLACE_HALO) halo_x halo_y
  set halo_max [expr max($halo_x, $halo_y)]
  set blockage_width $halo_max

  if { [env_var_exists_and_non_empty MACRO_BLOCKAGE_HALO] } {
    set blockage_width $::env(MACRO_BLOCKAGE_HALO)
  }

  if { [env_var_exists_and_non_empty MACRO_PLACEMENT_TCL] } {
    log_cmd source $::env(MACRO_PLACEMENT_TCL)
  }

  if { [env_var_exists_and_non_empty MACRO_PLACEMENT_TCL] } {
    log_cmd source $::env(MACRO_PLACEMENT_TCL)
  }

  # Define apenas as flags de halo aceitas pelo saplace_simulated_annealing
  set all_args [list -halo_width $halo_x -halo_height $halo_y]

  # Executa o comando apenas com os argumentos de halo necessários
  log_cmd saplace_simulated_annealing {*}$all_args

} else {
  puts "No macros found: Skipping macro_placement"
}
