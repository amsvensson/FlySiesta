function F=fragmentation_F(ievs)
% Calculates Fragmentation (Number of Episodes / Total Duration)
F=length(ievs)/sum(ievs);
end
