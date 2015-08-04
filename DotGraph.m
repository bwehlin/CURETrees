classdef DotGraph < handle
    %DOTGRAPH Summary of this class goes here
    %   Detailed explanation goes here
    
    properties (Access = public)
        m_type;
        m_command_list;
        m_valid_nodes;
    end
    
    methods
        function obj = DotGraph(type)
            if nargin < 1
                error('Not enough parameters');
            end
            
            obj.m_command_list = cell(0,2);
            obj.m_valid_nodes = cell(0,1);
            
            setType(obj, type);
        end
        
        function setType(obj, type)
            if nargin < 2
                error('Not enough parameters');
            end
            
            if type ~= DotType.graph && type ~= DotType.digraph
                error(['Incorrect graph type: ', type]);
            else
                obj.m_type = type;
            end
        end
        
        function addNode(obj, node_name, shape, visible)
            if nargin < 4
                error('Not enough parameters');
            end
            
            obj.m_command_list{end+1,1} = DotCommand.cmd_add_node;
            obj.m_command_list{end,  2} = struct( ...
                'node_name', node_name, ...
                'shape', shape, ...
                'visible', visible);
            
            obj.m_valid_nodes{end+1, 1} = node_name;
        end
        
        function addConnection(obj, node_from, node_to, visible, arrowhead)
                            fprintf('f: %s, t: %s \n', node_from, node_to);
            
            if nargin < 4
                error('Not enough parameters');
            end
            
            node_from_found = 0;
            node_to_found = 0;
            
            for i=1:size(obj.m_valid_nodes, 1)
                cur_node = obj.m_valid_nodes{i,1};
                
                if strcmp(cur_node, node_from) == 1
                    node_from_found = 1;
                end
                
                if strcmp(cur_node, node_to) == 1
                    node_to_found = 1;
                end
                
                if node_from_found == 1 && node_to_found == 1
                    break;
                end
            end
            
            if node_from_found == 0
                error(['Could not find node: ', node_from]);
            end
            
            if node_to_found == 0
                error(['Could not find node: ', node_to]);
            end
            
            if nargin < 5
                arrowhead = '';
            end
            
            obj.m_command_list{end+1, 1} = DotCommand.cmd_add_connection;
            obj.m_command_list{end,   2} = struct( ...
                'node_from', node_from, ...
                'node_to', node_to, ...
                'visible', visible, ...
                'arrowhead', arrowhead);
            
        end
        
        function cmd_string = getCommandStringAddNode(obj, params)
                      
            cmd_string = ['node [shape=', params.shape '] ' ...
                params.node_name];
            
            if params.visible == 0
                cmd_string = [cmd_string ' [style=invis]'];
            end
            
            cmd_string = [cmd_string ';'];
            
        end
        
        function cmd_string = getCommandStringAddConnection(obj, params)

            cmd_string = params.node_from;
            
            switch obj.m_type
                case DotType.graph
                    cmd_string = [cmd_string ' -- '];
                case DotType.digraph
                    cmd_string = [cmd_string ' -> '];
                otherwise
                    error('Invalid graph type');
            end
            
            cmd_string = [cmd_string params.node_to];
            
            if params.visible == 0
                cmd_string = [cmd_string ' [style=invis]'];
            end
            
            if strcmp(params.arrowhead, '') == 0
                cmd_string = [cmd_string ' [arrowhead=' ...
                    params.arrowhead ']'];
            end
            
            cmd_string = [cmd_string ';'];
        end
        
        function cmd_string = getCommandString(obj, current_idx)
            if current_idx > size(obj.m_command_list, 1)
                cmd_string = '';
                return;
            end
            
            current_cmd_type = obj.m_command_list{current_idx, 1};
            current_cmd_params = obj.m_command_list{current_idx, 2};
            
            switch current_cmd_type
                case DotCommand.cmd_add_node
                    cmd_string = getCommandStringAddNode(obj, ...
                        current_cmd_params);
                case DotCommand.cmd_add_connection
                    cmd_string = getCommandStringAddConnection(obj, ...
                        current_cmd_params);
                otherwise
                    cmd_string = ' ';
            end
            
        end
        
        function writeDotFile(obj, file_name)
            file_id = fopen(file_name, 'w');
            
            % Begin main scope
            switch obj.m_type
                case DotType.graph
                    fprintf(file_id, 'graph G {\n');
                case DotType.digraph
                    fprintf(file_id, 'digraph G {\n');
                otherwise
                    error('Invalid graph type');
            end
            
            for current_idx = 1:size(obj.m_command_list, 1)
                cmd_string = getCommandString(obj, current_idx);
                
                fprintf(file_id, '%s\n', cmd_string);
            end

            fprintf(file_id, '}'); % End main scope
            fclose(file_id);
        end
        
        function appendGraph(obj, graph, skip_root)
            start_idx = 1;
            
            if skip_root == 1
                start_idx = 2;
            end
            
            if start_idx > size(graph.m_command_list, 1)
                return;
            end
            
            old_length = size(obj.m_command_list, 1);
            graph_length = size(graph.m_command_list, 1);
            
            new_command_list = cell( ...
                old_length + graph_length - start_idx + 1, 2);
            
            for i=1:old_length
                new_command_list{i, 1} = obj.m_command_list{i, 1};
                new_command_list{i, 2} = obj.m_command_list{i, 2};
            end
            
            for i=start_idx:graph_length
                place_idx = old_length + i - (start_idx - 1);
                
                new_command_list{place_idx, 1} = ...
                    graph.m_command_list{i, 1};
                new_command_list{place_idx, 2} = ...
                    graph.m_command_list{i, 2};
            end

            obj.m_command_list = new_command_list;
        end
    end
end

