% Course: Information Systems
% Association Rule Analysis with Apriori
% Author: Dr. George Azzopardi
% Date: December 2019

% input parameters: minsup = minimum support, minconf = minimum confidence
function associationRules(minsup,minconf)
tic
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
function generateAssociation(frequentItems, support, minconf)
tic
% Data-Structure to store the association rules that satisfy min-confidence
associationRules = {};
% Iterate over the Frequent Items level in reverse order
for i=size(frequentItems,2)-1:-1:2
    % Iterate over the Frequent items
    for k =1:size(frequentItems{1,i},1)
        % Store the Frequent Item at level 'i' and Position 'k'
        row = frequentItems{1,i}(k,:);
        % Get the support value for the antecedent (sup(AUB) or numerator)
        support_nume = support{1, size(row, 2)}(k);
        % Create a list to store the subsets with confidence less than min-conf
        % The subsets will be pruned and it is discontinued susequent stages
        pruneList = [];
        % Iterate over row to generate association rules
        for j=length(row)-1:-1:1
            % Create subsets of row with size 'j'
            subsets = nchoosek(row,j);
            % Prune the subsets from the list of subsets generated with
            % confidence less than min-confidence
            if  isempty(pruneList) isSubset = []; else isSubset = ismember(subsets, pruneList{1}); end
            subsets(all(isSubset==1,2),:) = [];
            % Iteration over the subsets that are not pruned
            for x =1:size(subsets,1)
                % Get the antecedent
                X_S = subsets(x,:);
                % Get the Frequent Item set that belongs to antecedent
                % Ex: if antecdent = [1, 2]; FrequentItem(2) will be used
                fi_X_S = frequentItems{size(X_S,2)};
                % Find the index of the antecedent in the FrequentItem
                % Use the Index found to fetch the support of antecedent
                support_X_S = support{size(X_S,2)}(ismember(fi_X_S, X_S, 'rows'));
                %Calculate confidence value
                confidence = round(support_nume/support_X_S,2);
                % If confidence is greater than minimum confidence store it
                % in the associationRule Data-structure as results
                if confidence >= minconf
                    associationRules = [associationRules;[{X_S}, {setdiff(row,X_S)}, {confidence}]];
                else
                    % If the confidence is less than the min-confidence
                    % add an entry in the prune list to skip the
                    % computation of its subset association rules.
                    pruneList{end+1,1} = X_S;
                end
            end
        end
    end
end
toc
% Display the top 30 association rules
show_top_30(associationRules);
end

function show_top_30(associationRules)
    % Open the dataset file
    fid = fopen('myDataFile.csv');
    % Get the header of the CSV file that contains the item names
    items = textscan(fid,'%s',1);
    % close the file
    fclose(fid);
    % Split the header by delimiter comma to obatain the list of item names
    header = split(items{1},',');
    % Sort the association rules in descending order
    sortedRes = sortrows(associationRules,3,'descend');
    % pick the top 30 association rules from the sorted list
     sortedRes = sortedRes(1:30,:);
    % For each of the picked association rules
    for i=1:size(sortedRes,1)
        % retrive the original name of the item from the header extracted 
        % from the dataset file and concatenate it to a string
        antecedent = sprintf(' %s,' , header{sortedRes{i,1}});
        consequent = sprintf(' %s,' , header{sortedRes{i,2}});
        % Get the confidence value for the antecedent => consequent
        confidence = sprintf(' %f' , sortedRes{i,3});
        % Print the association Rule
        fprintf("{%s} => {%s} ::: Confidence = %s \n", antecedent(1:end-1), consequent(1:end-1), ""+confidence)
    end
    fprintf("-----------------------------------------------------------------------------------------------\n");
    fprintf("The Number of Association that satisfy the input constrints is = %d\n", size(associationRules,1));
    fprintf("-----------------------------------------------------------------------------------------------\n");
end

