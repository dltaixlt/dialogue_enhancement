addpath(genpath('C:\sap-voicebox'))

clear

% parameter
snr_test = [9, 6, 3, 0, -3, -6];

%
% read clean speech signal
%
f_clean = 'clean.wav';
[x_c, fs] = readwav(f_clean);

z = v_addnoise(x_c, fs, 0, 'deEkx');
x_ref = z(:, 1);
ref_name = 'clean_ref';
wavwrite(x_ref, fs, 'clean_ref');

% open segSNR output text
segSNRtxt = fopen('segSNR.txt', 'wt');
fprintf(segSNRtxt, "SNR\tnoise\tmmse\n")

for snr=snr_test 
  
  % add noise
  % 'd'  SNR input and p output given in dB [default]
  % 'e'  Use energy to calculate signal level
  % 'E'  Use energy to calculate noise level [default]
  % 'k'  preserve original signal power
  % 'x'  the output z contains input and noise as separate columns  
  x_noise = v_addnoise(x_c, fs, snr, 'deEk');
  noise_name = sprintf('white_%ddB', snr);  
  wavwrite(x_noise, fs, noise_name);
  
  % mmse process
  % enhance the noisy speech using default parameters  
  y=v_ssubmmse(x_noise,fs);               
  mmse_name = sprintf('white_%ddB_mmse', snr);  
  wavwrite(y, fs, mmse_name)

  % segSNR
  [seg_noise, glo_noise] = v_snrseg(x_noise, x_ref, fs, 'V', 0.03);
  [seg_mmse, glo_mmse] = v_snrseg(y, x_ref, fs, 'V', 0.03);
  fprintf(segSNRtxt, "%d\t%.2f\t%.2f\n", snr, seg_noise, seg_mmse);
  
  % pesq  
  proc = sprintf('pesq +8000 %s.wav %s.wav', ref_name, noise_name);
  system(proc);
  proc = sprintf('pesq +8000 %s.wav %s.wav', ref_name, mmse_name);
  system(proc);
end
fclose(segSNRtxt);