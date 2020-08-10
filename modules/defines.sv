/*
calculates bus width from its max value
`width(255) -> 8
*/
`define width(val) $clog2(val+1)


`define reg(val) reg[$clog2(val+1)-1:0]

`define wire(val) wire[$clog2(val+1)-1:0]

/*
defines 2d array reg
`reg_2d(my_array, 255, 4) -> reg[8] my_array [4:0]
*/
`define reg_2d(name, width_val, length_val) reg[$clog2(width_val+1)-1:0] \
 ``name`` [length_val:0]

/*
defines 2d array wire
`wire_2d(my_array, 255, 4) -> wire[8] my_array [4:0]
*/
`define wire_2d(name, width_val, length_val) wire[$clog2(width_val+1)-1:0] \
 ``name`` [length_val:0]

`define div(A, B) A / B + (2*(A % B) >= B ? 1 : 0)


