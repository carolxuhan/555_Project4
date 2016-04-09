function valid = testStructContents(inputStruct,fieldList)
% Validates a structure for the required parameters  
%
% Checks if the given structure has the required set of fields 
%
% INPUTS
%   inputStruct - Structure which needs to be validated
%   fieldList   - List of fields that must be contained in the structure
%
% OUTPUTS
%   valid       - Boolean value indicating if the structure is valid or not


fieldInput     = fieldnames(inputStruct);
missingField   = setdiff(fieldList,fieldInput); % All the missing Fields

if length(missingField) >0
    for i=1:length(missingField)
        fprintf('[Field Missing] %s\n',missingField{i})
    end
    valid = 0;
else
    valid = 1;
end
