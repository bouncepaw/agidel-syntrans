#!/usr/sh
goal=~/.agidel/syntrans/
function add {
    cp $1.scm $goal
}
add discomment
add disbrace
add disbracket
add quotify
