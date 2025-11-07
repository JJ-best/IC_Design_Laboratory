
// Hierarchical compare
// Generate hierarchical dofile script
write hier_compare dofile hier.do \
    -prepend_string "analyze setup -verbose; \
                     analyze multiplier -cdp_info; \
                     analyze datapath -merge -share -effort medium -verbose;" \
    -append_string "analyze abort -compare" -replace

// static compare (not recommended to use)
//dofile hier.do  

// dynamic compare
run hier_compare hier.do


// Report
report verification

