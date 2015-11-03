Patching ReadMe - Sept 11, 2015

Original patching structure:

- measurements were sorted according to phase indicies only and measurements were overwritten.

Updated patching structure:

- sorting is done according to segment index, phase index, line index, set index and ushChannelID.

- subsequently line index and EvalInfoMask flags are overwritten

- For multi set file (phase-contrast) check if set 0 ulTimeStamp is less than set 1 ulTimeStamp if otherwise corrected.  

