addpath(genpath('C:\sap-voicebox'))

clear

% parameter
snr_test = [9, 6, 3, 0, -3, -6];

%
% read clean speech signal
%
f_clean = 'clean.wav';
[x_c, fs] = readwav(f_clean);
writewav(x_c, fs, 'ori.wav');

% add noise
for snr=snr_test  
  z = v_addnoise(x_c, fs, snr, 'deEk');
  out_name = sprintf('noisey_white_%ddB_eEk_c', snr);
  writewav(z, fs, out_name);
end

% mmse process

for i=1:length(snr_test)
  snr=snr_test(i);
  in_name = sprintf('noisey_white_%ddB_eEk', snr);
  out_name = sprintf('noisey_white_%ddB_eEk_mmse', snr);
  [x_in,fs]=readwav(in_name);
  
  x_c = x_in(:, 1);
  x_cn = x_in(:, 1) + x_in(:, 2);
  
  y=v_ssubmmse(x_cn,fs);               % enhance the noisy speech using default parameters
  
  wavwrite(y, fs, out_name);  
end

%
% segSNR
%
snrseg = zeros(length(snr_test), 1);
snrglo = zeros(length(snr_test), 1);
ref_name = 'clean_c.wav'
[x_ref,fs]=readwav(ref_name);
for i=1:length(snr_test)
  snr=snr_test(i)
  enh_name = sprintf('noisey_white_%ddB_eEk_c', snr);
  [y, fs]=readwav(enh_name);
  [seg, glo] = v_snrseg(y, x_ref, fs, 'V', 0.03);
  
  snrseg(i) = seg;
  snrglo(i) = glo;
end

%
% PESQ
%
snr_test = [9, 6, 3, 0, -3, -6];
for snr=snr_test  
  proc = sprintf('pesq +8000 clean_c.wav noisey_white_%ddB_eEk_c.wav', snr);
  system(proc)
end
