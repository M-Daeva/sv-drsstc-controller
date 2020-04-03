`define width(val) $clog2(val+1)
`define reg(val) reg[$clog2(val+1)-1:0]
`define wire(val) wire[$clog2(val+1)-1:0]

`define div(A, B) A / B + (2*(A % B) >= B ? 1 : 0)


