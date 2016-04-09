function defaultedParam = testParamValidity(defaultParams,inputParams)
% This function check the parameter validity with a set of parameters
%
% Given two sets of parameters, this function calculates which options have
% not been set and defaults them.
%
% INPUTS
%   defaultParams  - Structure containing all the default values for them
%                    various options.
%
%   inputParams    - Structure containing the currently used set of options.
%
% OUTPUTS
%   defaultedParam - Structure containing the input parameters and the
%                    defaulted values for the missing options.

fieldDefault   = fieldnames(defaultParams);
fieldInput     = fieldnames(inputParams);
missingField   = setdiff(fieldDefault,fieldInput); % All the missing Fields
defaultedParam = inputParams;

for i=1:length(missingField)
    defaultedParam = setfield(defaultedParam,missingField{i},getfield(defaultParams,missingField{i}));
end

