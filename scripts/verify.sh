#!/bin/bash
npx snarkjs powersoftau new bn128 12 zk/ptau/pot12_0000.ptau -v
npx snarkjs powersoftau contribute zk/ptau/pot12_0000.ptau zk/ptau/pot12_0001.ptau --name="First contribution" -v
npx snarkjs powersoftau prepare phase2 zk/ptau/pot12_0001.ptau zk/ptau/pot12_final.ptau -v
npx snarkjs groth16 setup zk/compiled/password.r1cs zk/ptau/pot12_final.ptau zk/zkey/password_0000.zkey
npx snarkjs zkey contribute zk/zkey/password_0000.zkey zk/zkey/password_0001.zkey --name="1st Contributor Name" -v
npx snarkjs zkey export verificationkey zk/zkey/password_0001.zkey zk/verification_key.json
node zk/compiled/password_js/generate_witness.js zk/compiled/password_js/password.wasm zk/input.json zk/witness.wtns
npx snarkjs groth16 prove zk/zkey/password_0001.zkey zk/witness.wtns zk/proof.json zk/public.json
npx snarkjs groth16 verify zk/verification_key.json zk/public.json zk/proof.json
npx snarkjs zkey export solidityverifier zk/zkey/password_0001.zkey src/Verifier.sol