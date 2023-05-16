add_force {/porfgen/clk} -radix hex {0 0ns} {1 50000ps} -repeat_every 100000ps
add_force {/porfgen/arst} -radix hex {1 0ns} -cancel_after 10us
run 10 us
add_force {/porfgen/arst} -radix hex {0 0ns}
run 10 us
add_force {/porfgen/arst} -radix hex {1 0ns} -cancel_after 10us
run 10 us
add_force {/porfgen/arst} -radix hex {0 0ns}
run 10 us
add_force {/porfgen/arst} -radix hex {1 0ns} -cancel_after 10us
run 10 us
add_force {/porfgen/arst} -radix hex {0 0ns}
run 10 us

