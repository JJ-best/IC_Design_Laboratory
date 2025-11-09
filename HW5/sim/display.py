import numpy as np
import os

if __name__ == '__main__':
    
    BW = 10
    softmax_FL = 10
    
    
    golden_num = int(input("Number of pattern (0 ~ 99): "))
    if golden_num < 0 or golden_num > 99:
        print("pattern index out of range!!")
        os._exit(0)

    print("0:Patch embedding and position encoding")
    print("1:Normalization")
    print("2:Q projection")
    print("3:K projection")
    print("4:V projection")
    print("5:Q@K")
    print("6:Softmax")
    print("7:Softmax@V")
    print("8:O projection")
    print("9:Residual add")

    layer = int(input("Which layer? (0 ~ 9): ")) 
    if layer < 0 or layer > 12:
        print("layer index out of range!!")
        os._exit(0)
        
    if layer == 5 or layer == 6:
        head = int(input("Which head? (0 or 1): "))
        if head < 0 or head > 1:
            print("head out of range!!")
            os._exit(0)

    src_root = './feature_map'    
    layer_list = ['pos_enc', 'norm1', 'q_proj', 'k_proj', 'v_proj', 'attn_before_softmax', 'attn_after_softmax', 'qv', 'o_proj', 'residual_add1']    
    src_path = os.path.join(src_root, layer_list[layer], layer_list[layer] + '_{}.npy'.format(str(golden_num).zfill(3)))
    act = np.load(src_path)
    
    Height = 8
    Width = 8
    if layer == 5 or layer == 6:
        B, H, N, CH = act.shape
        act = act.astype(int)
        print("\n============================================== activation ==============================================\n")
        for j in range(64):
            print("\n===============================================  row{:3}  ===============================================\n".format(j))
            print("col 0~15", end='')
            for i in range(16):
                    print('{:6}'.format(act[0, head, j, i]), end='')
            print("\r")
            print("col16~31", end='')
            for i in range(16):
                    print('{:6}'.format(act[0, head, j, i + 16]), end='')
            print("\r")
            print("col32~47", end='')
            for i in range(16):
                    print('{:6}'.format(act[0, head, j, i + 32]), end='')
            print("\r")
            print("col48~63", end='')
            for i in range(16):
                    print('{:6}'.format(act[0, head, j, i + 48]), end='')
            print("\r")
        print("\n============================================== activation ==============================================\n")
    elif layer == 7:
        B, H, N, CH = act.shape
        act = act.astype(int)
        print("\n============================================== activation ==============================================\n")
        print("          ", end='')
        for i in range(16):
            print('{:6}'.format('ch{:2}'.format(i)), end='')
        print("\r")
        for i in range(64):
            print("token{:2} ".format(i), end='')
            for j in range(8):
                print('{:6}'.format(act[0, 0, i, j]), end='')
            for j in range(8):
                print('{:6}'.format(act[0, 1, i, j]), end='')
            print("\r")
        print("\n============================================== activation ==============================================\n")
    else:
        B, N, CH = act.shape
        act = act.astype(int)
        print("\n============================================== activation ==============================================\n")
        print("          ", end='')
        for i in range(16):
            print('{:6}'.format('ch{:2}'.format(i)), end='')
        print("\r")
        for i in range(64):
            print("token{:2} ".format(i), end='')
            for j in range(16):
                print('{:6}'.format(act[0, i, j]), end='')
            print("\r")
        print("\n============================================== activation ==============================================\n")
    

