function load_state() {
    mkdir -p $WORK_DIR
    touch $WORK_DIR/state.env
    source $WORK_DIR/state.env
}

function write_state() {
    mkdir -p $WORK_DIR
    touch $WORK_DIR/state.env
    echo "# Updated $(date)" > $WORK_DIR/state.env
    echo "export GITHUB_USERNAME=${GITHUB_USERNAME}" >> $WORK_DIR/state.env
    echo "export GH_TOKEN=${GH_TOKEN}" >> $WORK_DIR/state.env
   
}
