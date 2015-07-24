% Copyright (c) 2015, UC San Diego CURE Program
% All rights reserved.
% 
% Redistribution and use in source and binary forms, with or without
% modification, are permitted provided that the following conditions are
% met:
% 
% 1. Redistributions of source code must retain the above copyright
%    notice, this list of conditions and the following disclaimer.
% 
% 2. Redistributions in binary form must reproduce the above copyright
%    notice, this list of conditions and the following disclaimer in the
%    documentation and/or other materials provided with the distribution.
% 
% 3. Neither the name of the copyright holder nor the names of its
%    contributors may be used to endorse or promote products derived from
%    this software without specific prior written permission.
% 
% THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS
% "AS IS" AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT
% LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A
% PARTICULAR PURPOSE ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER
% OR CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
% EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
% PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
% PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF
% LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING
% NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF THIS
% SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.

function trees = genTrees( n_vertices, export )
    % Generates all alternating trees on n_vertices for n_vertices >= 3.
    %
    % Parameters:
    %   n_vertices - Number of vertices
    %   export     - Exports PDF if =1
    %
    % Output:
    %
    %   trees      - n*2 Cell array of {Adjacency Matrices, Prufer Codes}
    %                  corresponding to all alternating trees

    
    %
    % --------------------------------------------------------- USER CONFIG
    %
    
    % For export to work, these have to be set up correctly
    
    global NEATO_PATH;    NEATO_PATH    = '/usr/local/bin/dot';
    global PDFLATEX_PATH; PDFLATEX_PATH = '/usr/texbin/pdflatex';
    
    %
    % ----------------------------------------------------- END USER CONFIG
    %
    
    tic;

    % Adjacency Matrix, Prufer Sequence
    trees = cell(0,2);
    
    if n_vertices < 3
        error('n_vertices < 3');
    end
    
    if nargin < 2
        export = 0;
    end
    
    % Start with Prufer sequence (1111 ... 1)
    prufer_seq = ones(1, n_vertices - 2);
    
    done = 0;
    
    trees_total = 1;
    seqs_checked = 0;
    
    h_wait = waitbar(0, 'Finding trees');
    seqs_total = n_vertices^(n_vertices - 2); % Cayley's formula
    
    while (done ~= 1)
        
        waitbar(seqs_checked/seqs_total);

        % Get adjacency matrix from Prufer
        adj_matrix = pruferToTree(prufer_seq, n_vertices);
        
        % Check if alternating (and save if it is)
        if isAlternating(adj_matrix, n_vertices) == 1
            trees{end+1,1} = adj_matrix;
            trees{end, 2} = prufer_seq;
        end
        
        prufer_seq = nextPruferSeq(prufer_seq, n_vertices);
        
        if prufer_seq == 0
            done = 1;
        else
            trees_total = trees_total + 1;
        end
        
        seqs_checked = seqs_checked + 1;
        
    end
    
    delete(h_wait);
    
    t = toc;
    
    fprintf('Generated (%d alternating/%d total) trees in %f s.\n', ...
        size(trees,1), trees_total, t);

    fprintf('Time: %d.\n', t);
    
    if export == 1
        exportGraphs(trees, n_vertices);
    end
    
end

function seq = nextPruferSeq( current, n_vertices )
    % Generates Prufer sequences recursively from (1111 ... 1) to
    % (9999 ... 9) and returns 0 when all sequences have already
    % been generated
    %
    % Parameters:
    %   current    - The current Prufer sequence
    %   n_vertices - Number of vertices in alternating tree
    %
    % Output:
    %   seq        - The next Prufer sequence after current

    seq = current;
    
    carry = 1;
    
    for i=n_vertices-2:-1:1
        if carry == 1

            carry = 0;
            
            seq(1,i) = seq(1,i) + 1;

            if seq(1,i) > n_vertices
                seq(1,i) = 1;
                carry = 1;
            end
        else
            break;
        end
    end
    
    if carry == 1
       seq = 0; 
    end
    
end

function adj_matrix = pruferToTree( prufer_seq, n_vertices )
    % Converts a Prufer sequence to an alternating tree.
    %
    % Parameters:
    %    prufer_seq - Prufer sequence
    %    n_vertices - Number of vertices in tree
    %
    % Output:
    %    adj_matrix - The adjacency matrix corresponding to the tree

    adj_matrix = zeros(n_vertices);
    
    list_all = 1:n_vertices;

    while (size(list_all, 2) > 2)
        
        % Pick the smallest element on the list that is not in the sequence
        smallest = min(intersect(setxor(prufer_seq, list_all), list_all));
        
        % Add corresponding edge
        adj_matrix(smallest, prufer_seq(1,1)) = 1;
        
        % Cross off list and sequence entries
        prufer_seq = prufer_seq(1,2:end);
        list_all =  setxor(list_all, smallest);
        
    end
    
    % Connect remaining two vertices
    adj_matrix(list_all(1,1),list_all(1,2)) = 1;
    
    % Connect "backwards" edges
    adj_matrix = adj_matrix + adj_matrix';
    
end

function alternating = isAlternating(adj_matrix, n_vertices)
    % Checks if an adjacency matrix corresponds to an alternating tree
    %
    % Parameters:
    %    adj_matrix - Adjacency matrix to check
    %    n_vertices - Number of vertices in tree
    %
    % Output:
    %    alternating - 0: not alternating
    %                  1: alternating

    alternating = 1; % Assume alternating
    
    for i=2:n_vertices
        
        left_positive = 0;
        right_positive = 0;
        
        for j=1:i-1
            if adj_matrix(i,j) == 1
                left_positive = 1;
                break;
            end
        end
        
        for j=i+1:n_vertices
            if adj_matrix(i,j) == 1
                right_positive = 1;
            end
        end
        
        % If adj_matrix has ones on both sides of the main diagonal,
        % the tree is not alternating, so return 0.
        if left_positive == 1 && right_positive == 1
            alternating = 0;
            break;
        end
        
    end
end

function exportGraphs(trees, n_vertices)
    % Exports graphs to PDF. This requires neato (graphviz) and pdflatex
    % to be installed.
    %
    % Parameters:
    %    trees      - Cell array of trees
    %    n_vertices - Number of vertices in the trees

    global NEATO_PATH;
    global PDFLATEX_PATH;

    if ~exist('graphs', 'dir')
        mkdir('graphs');
    end
    
    latex_header = ['\\documentclass{article}' '\\usepackage{multicol}' ...
        '\\usepackage{graphicx}' '\\usepackage{float}' ...
        '\\usepackage[margin=1in]{geometry}' '\\begin{document}' ...
        '\\begin{multicols}{3}'];
    
    latex_footer = ['\\end{multicols}' '\\end{document}'];
    
    file_name_latex = 'tex/trees.tex';
    
    
    file_id_latex = fopen(file_name_latex, 'w');
    
    fprintf(file_id_latex, latex_header);
    
    header_string = 'graph tree {\n';
    
    node_string = '   node [shape=circle]; ';
    
    for i=1:n_vertices
        node_string = [node_string num2str(i) '; '];
    end
    
    node_string = [node_string '\n\n'];
    
    footer_string = '   overlap=false\n   fontsize=24\n}';
    
    h_wait = waitbar(0, 'Exporting graphs');
    
    % Loop through trees and connect edges
    for tree_idx=1:size(trees, 1)
        
        file_name_base = ['graphs/seq_' ...
            pruferString(trees{tree_idx,2}, n_vertices)];
        
        file_name = [file_name_base '.gv'];
        file_name_pdf = [file_name_base '.pdf'];
        
        fprintf(['Exporting ' file_name '...\n']);
        
        if (~exist(file_name, 'file'))
        
            file_id = fopen(file_name,'w');

            fprintf(file_id, header_string);
            fprintf(file_id, node_string);

            for i=1:n_vertices
                for j=i+1:n_vertices
                    if trees{tree_idx,1}(i,j) == 1
                        fprintf(file_id, ['   ' num2str(i) '--' ...
                            num2str(j) ';\n']);
                    end
                end
            end

            label_string = ['   label="\\n(' ...
                pruferString(trees{tree_idx,2}, n_vertices) ')"\n\n'];

            fprintf(file_id, label_string);

            fprintf(file_id, footer_string);

            fclose(file_id);
        else
            fprintf('   Skipping gv (already created)...');
        end
        
        % Convert to pdf unless plot already exists
        if (~exist(file_name_pdf, 'file'))
        
            fprintf(['Creating ' file_name_pdf]);
            
            neato_command = [NEATO_PATH ' -Tpdf ' file_name ' > ' ...
                file_name_pdf];
            
            console_log_item = evalc('system(neato_command)');
        else
            fprintf('   Skipping pdf (already created)...');
        end
        
        fprintf('\n');
        
        latex_figure_string = ['\\begin{figure}[H]' ...
            '\\includegraphics[width=0.9\\linewidth]{' ...
            file_name_base '}' '\\end{figure}'];
        
        fprintf(file_id_latex, latex_figure_string);
        
        waitbar(tree_idx/size(trees,1));
    end
    
    delete(h_wait);
    
    fprintf(file_id_latex, latex_footer);
    fclose(file_id_latex);
    
    % TeX big file
    
    pdflatex_command = [PDFLATEX_PATH ' ' file_name_latex];
    console_log_item = evalc('system(pdflatex_command)');
    
end

function prufer_string = pruferString(prufer_seq, n_vertices)
    % String representation of Prufer sequence
    %
    % Parameters:
    %    prufer_seq    - Prufer sequence to convert
    %    n_vertices    - Number of vertices in tree
    %
    % Output:
    %    prufer_string - String representation of Prufer sequence
    %                      i.e., [1,2,3] becomes '123'

    prufer_string = '';

    for i=1:n_vertices-2
        prufer_string = [prufer_string num2str(prufer_seq(i))];
    end

end
