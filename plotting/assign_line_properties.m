blu = [     0    0.4470    0.7410]; % 0 114 189
red = [0.8500    0.3250    0.0980]; % 217 83 25
yel = [0.9290    0.6940    0.1250]; % 237 177 32
pur = [0.4940    0.1840    0.5560]; % 126 47 142
gre = [0.4660    0.6740    0.1880]; % 119 172 48
lbl = [0.3010    0.7450    0.9330];
drd = [0.6350    0.0780    0.1840];

linewidth = 2;
fontsize = 12;

model_strs2 = model_strs;
model_colors = model_strs;
model_lines = model_strs;

for i = 1:length(model_strs)
    
    % default: black, solid lines
    model_colors{i} = [1, 0, 0];
    model_lines{i} = '-';
    
    switch model_strs{i}
        
        % independent
        case 'ind'
            model_strs2{i} = 'IND';
            model_colors{i} = [0, 0, 0];
            model_lines{i} = '-';
            
        % additive
        case 'add-pop_01'
            model_strs2{i} = 'ADD-POP-1';
            model_colors{i} = red;
            model_lines{i} = '-';
                    
        % multiplicative
        case {'mult-pop_01', 'mult-pop_01_oneplus'}
            model_strs2{i} = 'MULT-POP-1';
            model_colors{i} = blu;
            model_lines{i} = '-';
                    
        % affine
        case {'aff-pop_01', 'aff-pop_01_oneplus'}
            model_strs2{i} = 'AFF-POP-1';
            model_colors{i} = gre;
            model_lines{i} = '-';
                    
        % rlvm
        case 'add_01'
            model_strs2{i} = 'ADD-1';
            model_colors{i} = pur;
            model_lines{i} = '-';
        case 'add_02'
            model_strs2{i} = 'ADD-2';
            model_colors{i} = pur;
            model_lines{i} = '-';
        case 'add_03'
            model_strs2{i} = 'ADD-3';
            model_colors{i} = pur;
            model_lines{i} = '-';
        case 'add_04'
            model_strs2{i} = 'ADD-4';
            model_colors{i} = pur;
            model_lines{i} = '-';
        case 'add_05'
            model_strs2{i} = 'ADD-5';
            model_colors{i} = pur;
            model_lines{i} = '-';
        
        % srlvm
        case 'add_10-01'
            model_strs2{i} = 'ADD-10-1';
            model_colors{i} = yel;
            model_lines{i} = '-';
        case 'add_10-02'
            model_strs2{i} = 'ADD-10-2';
            model_colors{i} = yel;
            model_lines{i} = '-';
        case 'add_10-03'
            model_strs2{i} = 'ADD-10-3';
            model_colors{i} = yel;
            model_lines{i} = '-';
        case 'add_10-04'
            model_strs2{i} = 'ADD-10-4';
            model_colors{i} = yel;
            model_lines{i} = '-';
        case 'add_10-05'
            model_strs2{i} = 'ADD-10-5';
            model_colors{i} = yel;
            model_lines{i} = '-';

    end
end
