## ICLAB2025 HW2 Part3 VCS simulation script ##
# Note: You need to pass all simulation to get the full scores! 
# Do not modify !!!

# +define+ENCRYPT: Enigma encrypt plaintext to ciphertext, crypt_mode == 1'b0
# +define+DECRYPT: Enigma decrypt ciphertext to plaintext, crypt_mode == 1'b1
# +define+PAT1: Use pat/plaintext1_part3.dat and pat/ciphertext1_part3.dat
# +define+PAT2: Use pat/plaintext2_part3.dat and pat/ciphertext2_part3.dat
# +define+PAT_LEN={number}: Length of the pattern

# Mode: encrypt; Pattern: PAT1
vcs -R +v2k -full64 -f rtl_sim.f +define+ENCRYPT +define+PAT1 +define+PAT_LEN=29 -debug_access+all -l vcs_encrypt_pat1.log
# Mode: decrypt; Pattern: PAT1
vcs -R +v2k -full64 -f rtl_sim.f +define+DECRYPT +define+PAT1 +define+PAT_LEN=29 -debug_access+all -l vcs_decrypt_pat1.log

# Mode: encrypt; Pattern: PAT2
vcs -R +v2k -full64 -f rtl_sim.f +define+ENCRYPT +define+PAT2 +define+PAT_LEN=111 -debug_access+all -l vcs_encrypt_pat2.log
# Mode: decrypt; Pattern: PAT2
vcs -R +v2k -full64 -f rtl_sim.f +define+DECRYPT +define+PAT2 +define+PAT_LEN=111 -debug_access+all -l vcs_decrypt_pat2.log
