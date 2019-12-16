% Course: Information Systems
% Association Rule Analysis with Apriori
% Author: Dr. George Azzopardi
% Date: December 2019

% input parameters: minsup = minimum support, minconf = minimum confidence
function associationRules(minsup,minconf)
shoppingList = readDataFile;
ntrans = size(shoppingList,1);
items = unique([shoppingList{:}]);
plotHistogram(shoppingList);
nitems = numel(items);

[tridx,trlbl] = grp2idx(items);

% Create the binary matrix
dataset = zeros(ntrans,nitems);
for i = 1:ntrans
   dataset(i,tridx(ismember(items,shoppingList{i}))) = 1;
end

% Generate frequent items of length 1
support{1} = sum(dataset)/ntrans;
f = find(support{1} >= minsup);
frequentItems{1} = tridx(f);
support{1} = support{1}(f);

% Generate frequent item sets
k = 1;
while k < nitems && size(frequentItems{k},1) > 1
    % Generate length (k+1) candidate itemsets from length k frequent itemsets
    frequentItems{k+1} = [];
    support{k+1} = [];
    
    % Consider joining possible pairs of item sets
    for i = 1:size(frequentItems{k},1)-1
        for j = i+1:size(frequentItems{k},1)
            if k == 1 || isequal(frequentItems{k}(i,1:end-1),frequentItems{k}(j,1:end-1))
                candidateFrequentItem = union(frequentItems{k}(i,:),frequentItems{k}(j,:));  
                if all(ismember(nchoosek(candidateFrequentItem,k),frequentItems{k},'rows'))                
                    sup = sum(all(dataset(:,candidateFrequentItem),2))/ntrans;                    
                    if sup >= minsup
                        frequentItems{k+1}(end+1,:) = candidateFrequentItem;
                        support{k+1}(end+1) = sup;
                    end
                end
            else
                break;
            end            
        end
    end         
    k = k + 1;
end
generateAssociation(frequentItems,support, minconf)
end

% Generate association rules. To be implemented by students

function generateAssociation(fi, sup, minconf)

confidenceList = {};
pruneList = [];
for i=size(fi,2)-1:-1:1
    tmpfi = fi(i);
    tmpfi = tmpfi{1};
    supersetSize = size(tmpfi,2);
    for k =1:size(tmpfi,1)
        row = tmpfi(k,:);
        pruneList = [];
        for j=supersetSize-1:-1:1
            subsets = sortrows(nchoosek(row,j));
            if  isempty(pruneList) isSubset = []; else isSubset = ismember(subsets(:,j), pruneList(size(pruneList,2)-j)); end
            %out=subsets;
            subsets(any(isSubset==1,2),:) = [];
            for x =1:size(subsets,1)
                %subset = subsets(x);
                %subset
                %X_S = setdiff(row,subset);
                X_S = subsets(x,:);
                S = row;
                fi_s = fi{size(S,2)};
                s_idx = find(ismember(fi_s, sort(S), 'rows'));
                support_S = sup{size(S,2)}(s_idx);
                
                fi_X_S = fi{size(X_S,2)};
                X_S_idx = find(ismember(fi_X_S, sort(X_S), 'rows'));
                support_X_S = sup{size(X_S,2)}(X_S_idx);
                confidence = round(support_S/support_X_S,2);
                if confidence >= minconf
                    confidenceList = [confidenceList;[{X_S}, {size(X_S,2)} {setdiff(row,X_S)}, {confidence}]];
                else
                    d = setdiff(row,subsets(x,:));
                    d(end+1:6)=0;
                    pruneList = [pruneList; sortrows(d) ];
                end
            end
        end
    end
end
show_top_30(confidenceList, dataset)

end

function show_top_30(confidenceList, db)
    fid = fopen('myDataFile.csv');
    a = textscan(fid,'%s',1);
    fclose(fid);
    header = split(a{1},',');
    sortedRes = sortrows(confidenceList,4,'descend');
    toDisp =sortedRes(1:30,:);
    for i=1:size(toDisp,1)
        c1 = toDisp(i,1);
        c1 = arrayfun(@(x) header(x),c1{1});
        c2 = toDisp(i,2);
        c2 = arrayfun(@(x) header(x),c2{1});
        c3 = toDisp(i,4);
        a = strjoin(c1);
        b = strjoin(c2);
        ax = c3{1};
        fprintf("%s => %s Confidence = %f \n", a, b, ""+ax)
    end
end

