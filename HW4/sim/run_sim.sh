# Rank A
vcs -f hdl.f -full64 -R -debug_access+all +v2k \
+define+RANK_A+DEBUG_MODE+PAT_L=0+PAT_U=299

# Rank B
vcs -f hdl.f -full64 -R -debug_access+all +v2k \
+define+RANK_B+DEBUG_MODE+PAT_L=0+PAT_U=199

# Rank C
vcs -f hdl.f -full64 -R -debug_access+all +v2k \
+define+RANK_C+DEBUG_MODE+PAT_L=0+PAT_U=179

# Rank D
vcs -f hdl.f -full64 -R -debug_access+all +v2k \
+define+RANK_D+DEBUG_MODE+PAT_L=0+PAT_U=59


