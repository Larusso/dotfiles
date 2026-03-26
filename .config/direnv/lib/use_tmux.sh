#!/usr/bin/env bash

# use_tmux helper script for direnv
# Creates or attaches to a tmux session from a tmux_conf.yml file

_use_tmux_setup() {
    local session_name=""
    local config_file=""
    
    # Parse arguments - figure out what's what
    if [ $# -eq 0 ]; then
        # No args: use directory name and look for tmux_conf.yml
        session_name=$(basename "$PWD")
        config_file="$PWD/tmux_conf.yml"
    elif [ $# -eq 1 ]; then
        # One arg: could be session name OR config file
        if [[ "$1" == *.yml ]] || [[ "$1" == *.yaml ]]; then
            # It's a config file - look up in order: PWD, ~/.config/tmux
            config_file="$1"
            session_name=$(basename "$PWD")
            
            # If it's just a filename (no path), look it up
            if [[ "$config_file" != */* ]]; then
                if [ -f "$PWD/$config_file" ]; then
                    config_file="$PWD/$config_file"
                elif [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/$config_file" ]; then
                    config_file="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/$config_file"
                fi
            fi
        else
            # It's a session name
            session_name="$1"
            config_file="$PWD/tmux_conf.yml"
        fi
    else
        # Two args: session name and config file
        session_name="$1"
        config_file="$2"
        
        # If config file is just a filename, look it up
        if [[ "$config_file" != */* ]]; then
            if [ -f "$PWD/$config_file" ]; then
                config_file="$PWD/$config_file"
            elif [ -f "${XDG_CONFIG_HOME:-$HOME/.config}/tmux/$config_file" ]; then
                config_file="${XDG_CONFIG_HOME:-$HOME/.config}/tmux/$config_file"
            fi
        fi
    fi
    
    # Expand config file path if it's relative
    if [[ "$config_file" != /* ]]; then
        config_file="$PWD/$config_file"
    fi

    # Check if we're already inside tmux
    if [ -n "$TMUX" ]; then
        local current_session=$(tmux display-message -p '#S')
        if [ "$current_session" = "$session_name" ]; then
            return 0
        fi
    fi

    # Check if the session exists
    if ! tmux has-session -t "$session_name" 2>/dev/null; then
        # Create new session in detached mode
        tmux new-session -d -s "$session_name" -c "$PWD"

        # If config file exists, parse and create layout
        if [ -f "$config_file" ]; then
            # Use yq if available
            if command -v yq &> /dev/null; then
                local window_count=$(yq eval '.windows | length' "$config_file" 2>/dev/null || echo "0")
                
                for ((w=0; w<window_count; w++)); do
                    local window_name=$(yq eval ".windows[$w].name" "$config_file")
                    local window_dir=$(yq eval ".windows[$w].dir // \"$PWD\"" "$config_file")
                    
                    # Expand relative paths
                    if [[ "$window_dir" != /* ]]; then
                        window_dir="$PWD/$window_dir"
                    fi
                    
                    # Create or rename first window
                    if [ $w -eq 0 ]; then
                        tmux rename-window -t "$session_name:0" "$window_name"
                        tmux send-keys -t "$session_name:0" "cd '$window_dir'" C-m
                    else
                        tmux new-window -t "$session_name" -n "$window_name" -c "$window_dir"
                    fi
                    
                    # Get panes for this window
                    local pane_count=$(yq eval ".windows[$w].panes | length" "$config_file" 2>/dev/null || echo "0")
                    
                    for ((p=0; p<pane_count; p++)); do
                        local split=$(yq eval ".windows[$w].panes[$p].split // \"\"" "$config_file")
                        local pane_dir=$(yq eval ".windows[$w].panes[$p].dir // \"$window_dir\"" "$config_file")
                        local pane_cmd=$(yq eval ".windows[$w].panes[$p].cmd // \"\"" "$config_file")
                        local pane_size=$(yq eval ".windows[$w].panes[$p].size // \"\"" "$config_file")
                        
                        # Expand relative paths
                        if [[ "$pane_dir" != /* ]]; then
                            pane_dir="$PWD/$pane_dir"
                        fi
                        
                        if [ $p -eq 0 ]; then
                            # First pane - no split, just run command in existing pane
                            if [ -n "$pane_cmd" ] && [ "$pane_cmd" != "null" ]; then
                                if [ "$pane_dir" != "$window_dir" ]; then
                                    tmux send-keys -t "$session_name:$w.0" "cd '$pane_dir'" C-m
                                fi
                                tmux send-keys -t "$session_name:$w.0" "$pane_cmd" C-m
                            fi
                        else
                            # Subsequent panes - create split
                            local split_flag=""
                            case "$split" in
                                horizontal|h) split_flag="-v" ;;
                                vertical|v) split_flag="-h" ;;
                            esac
                            
                            # Create split if specified
                            if [ -n "$split_flag" ]; then
                                # Add size parameter if specified
                                local size_param=""
                                if [ -n "$pane_size" ] && [ "$pane_size" != "null" ]; then
                                    size_param="-l $pane_size"
                                fi
                                
                                tmux split-window -t "$session_name:$w" $split_flag $size_param -c "$pane_dir"
                                
                                # Run command in the new pane
                                if [ -n "$pane_cmd" ] && [ "$pane_cmd" != "null" ]; then
                                    local current_pane_count=$(tmux list-panes -t "$session_name:$w" | wc -l)
                                    local pane_index=$((current_pane_count - 1))
                                    tmux send-keys -t "$session_name:$w.$pane_index" "$pane_cmd" C-m
                                fi
                            fi
                        fi
                    done
                    
                    # Apply layout if specified
                    local layout=$(yq eval ".windows[$w].layout // \"\"" "$config_file")
                    if [ -n "$layout" ] && [ "$layout" != "null" ]; then
                        tmux select-layout -t "$session_name:$w" "$layout"
                    fi
                done
            else
                echo "Warning: yq not found. Install with: brew install yq" >&2
            fi
            
            # Select the first window and first pane as default
            tmux select-window -t "$session_name:0"
            tmux select-pane -t "$session_name:0.0"
        fi
    fi

    # Export session name
    echo "export TMUX_SESSION='$session_name'"
    
    # Only attach if not already in tmux
    if [ -z "$TMUX" ]; then
        # Output exec command for direnv to eval
        echo "exec tmux attach-session -t '$session_name'"
    fi
}

_use_tmux_setup "$@"
