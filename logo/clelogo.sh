#
# Script to render CLE logo on terminal
#
# source this code to have available colors in $_C*
#    . clelogo.sh

# render 'CLE'
cat <<EOL

$_Cb$_CL   ___| |     ____| 
$_Cc$_CL  |     |     __|   
$_Cy$_CL  |     |     |     
$_Cr$_CL \\____|_____|_____| 

EOL

# cmdline with underline cursor
cur_ul () {
cat <<EOL
$_Cg$_CD  \\$_Cg\\$_CG\\
$_Cg$_CD  /$_Cg/$_CG/
$_CG$_CL     == $_CN

EOL
}

# cmdline with block cursor
cur_blk () {
cat <<EOL
$_Cg$_CD  \\$_Cg\\$_CG\\ `tput setab 8`  $_CN
$_Cg$_CD  /$_Cg/$_CG/ `tput setab 8`  $_CN

EOL
}

# choose cmdline
#cur_ul

