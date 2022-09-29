pragma circom 2.0.1;

include "../../node_modules/circomlib/circuits/poseidon.circom";

template Password () {

    // signals

    signal input preimage; // private

    signal input hash; // public

    // constraints

    component algo = Poseidon(1);
    
    algo.inputs[0] <== preimage;
    
    log("hash", algo.out);

    // assert algo hash of preimage is equal to input hash
    hash === algo.out;
}

component main { public [ hash ] } = Password();