pragma circom 2.0.1;

include "../../node_modules/circomlib/circuits/poseidon.circom";

template Password () {

    /// -----------------------------------------------------------------------
    /// Signals
    /// -----------------------------------------------------------------------

    signal input secret; // private
    signal input nullifier; // private

    signal input secretHash; // public
    signal input nullifierHash; // public

    /// -----------------------------------------------------------------------
    /// Constraints
    /// -----------------------------------------------------------------------

    component secretHasher = Poseidon(1);
    component nullifierHasher = Poseidon(1);
    
    secretHasher.inputs[0] <== secret;
    nullifierHasher.inputs[0] <== nullifier;

    secretHash === secretHasher.out;
    nullifierHash === nullifierHasher.out;
}

component main { public [ secretHash, nullifierHash ] } = Password();