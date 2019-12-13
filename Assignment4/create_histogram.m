list = readDataFile();
arr = [];
for i = 1 : length(list)
    arr = [arr list{i}];
end
% all unique items are stored in a
a = unique(arr,'stable');
% b stores the frequency of each  item in arr
b = cellfun(@(x) sum(ismember(arr,x)),a,'un',0);



% basically call the histogram function here using b as parameter - couldnt
% figure out how to.
