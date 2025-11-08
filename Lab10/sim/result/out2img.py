from PIL import Image
import numpy as np
import matplotlib.pyplot as plt
import imageio

def txt2png():
    with open('img_out.dat','r') as f_txt:
        h=sum(1 for line in f_txt)//3
        f_txt.seek(0)
        w=len(f_txt.readline().split('_'))
        print('image size: {0}x{1}'.format(w,h))
        idx = 0
        img_array = np.empty([h,w,3], dtype=np.uint8)
        f_txt.seek(0)
        for line in f_txt:
            row = line.split('_')
            for i in range(len(row)):
                img_array[idx%h,i,idx//h] = int(row[i],base=16)
            idx+=1
    
    img_array = np.asarray(img_array)
    img_array = img_array*1.0 - 128
    # perform rounding ! 
    img_array = (img_array/(2**8) + 0.5)
    img_array = np.round(255*np.clip(img_array, 0.0, 1.0)).astype('uint8')
    

    imageio.imwrite('out.png', img_array)

    return img_array

def cal_psnr(prediction, bicubic):
    imgTar = imageio.imread('../../../../golden/HR_zebra_groundtruth.png')
    # prediction = np.asarray(img)
    # bicubic_ary = np.asarray(bicubic)
    if imgTar.shape == prediction.shape:
        diff_model = (prediction/1.0 - imgTar/1.0)
        diff_bicubic = (bicubic/1.0 - imgTar/1.0)
        mse_model = np.mean( np.square(diff_model) )
        mse_bicubic = np.mean( np.square(diff_bicubic) )
        psnr_model = 10 * np.log10( 255*255 / mse_model)
        psnr_bicubic = 10 * np.log10( 255*255 / mse_bicubic)
        print('===> PSNR model output: {0:.4f} dB'.format(psnr_model))
        print('===> PSNR bicubic output: {0:.4f} dB'.format(psnr_bicubic))
    else:
        print('No target image.')

def show_img(prediction, bicubic):
    prediction_img = Image.fromarray(prediction,'RGB')
    bicubic_img = Image.fromarray(bicubic,'RGB')

    dpi = plt.rcParams['figure.dpi']
    width, height = prediction_img.size
    figsize = width / float(dpi), 1+height / float(dpi)
    fig0 = plt.figure(figsize=figsize)
    ax0 = fig0.add_axes([0, 0, 1, 1])
    ax0.set_axis_off()
    ax0.set_title('model output')
    ax0.imshow(prediction_img)
    fig1 = plt.figure(figsize=figsize)
    ax1 = fig1.add_axes([0, 0, 1, 1])
    ax1.set_axis_off()
    ax1.set_title('bicubic output')
    ax1.imshow(bicubic_img)
    plt.show()

if __name__ == '__main__':
    prediction = txt2png()
    bicubic=imageio.imread('../../../../golden/bicubic_zebra.png')
    cal_psnr(prediction, bicubic)
    show_img(prediction, bicubic)
