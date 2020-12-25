clc;
clear;
close all;
EbNoVec = (0:10)';      % Eb/No values (dB)
rate=1/2;
M = 16;                 % Modulation order
k = log2(M);            % Bits per symbol
%%%%% IMAGE PREPROCESSING
in=imread('peppers.png'); % read image data [image should be in same directory]
N=numel(in); % get number of elements in the image to be transmitted
in2=reshape(in,N,1); % reshape the image into a vector column
bin=de2bi(in2,'left-msb'); %
input=reshape(bin',numel(bin),1);
len=length(input);
%%%%% padding zeroes to input %%%
z=len;
while(rem(z,2) || rem(z,4)|| rem(z,6))
    z=z+1;
    input(z,1)=0;
end
input=double(input);
y_16qam = qammod(input,16,'inputtype','bit');
ifft_out_16qam=ifft(y_16qam);
for n = 1:length(EbNoVec)
    SNR = EbNoVec(n) + 10*log10(k*rate);    % Convert Eb/No to SNR dB   
    tx_16qam=awgn(ifft_out_16qam,SNR,'measured');
    % RECEIVER
    k_16qam=fft(tx_16qam);
    l_16qam = qamdemod(k_16qam,16,'outputtype','bit');
    output_16qam=uint8(l_16qam);
    output_16qam=output_16qam(1:len);
    b2=reshape(output_16qam,8,N)';
    dec_16qam=bi2de(b2,'left-msb');
    BER_16qam(n)=biterr(input,l_16qam)/len;
    % Received image data 
    im_16qam=reshape(dec_16qam(1:N),size(in,1),size(in,2),size(in,3));
    imshow(im_16qam);
    title("EbNo="+EbNoVec(n));
end
semilogy(EbNoVec,BER_16qam,...
    EbNoVec,berawgn(EbNoVec,'qam',M),'-*');
figure;
grid;
legend('Actual BER','Theoretical BER');
xlabel('Eb/No');
ylabel('Bit Error Rate');
