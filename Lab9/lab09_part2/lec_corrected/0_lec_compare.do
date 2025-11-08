
//=== LEC mode ===
set system mode lec

// mapping the golden and revised keypoint
map key point

// Analyze Setup 
// (Advanced command for resolving setup issues more accurately before compare)
analyze setup -verbose

// Analyze datapath modules 
// (Conformal can automatically resolve multipliers, operator merging, and resource sharing problems)
analyze multiplier -cdp_info
analyze datapath -merge -share -effort medium -verbose

// Comparison
add compare point -all
compare

// Attempt to resolve abort points if any
analyze abort -compare


// Report
report unmap point -notmapped 
report compare data -nonequivalent
report verification

