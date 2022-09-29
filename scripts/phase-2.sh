#!/bin/bash
npx snarkjs powersoftau prepare phase2 zk/ptau/pot12_0001.ptau zk/ptau/pot12_final.ptau -v
npx snarkjs groth16 setup zk/compiled/password.r1cs zk/ptau/pot12_final.ptau zk/zkey/password_0000.zkey
npx snarkjs zkey contribute zk/zkey/password_0000.zkey zk/zkey/password_0001.zkey --name="1st Contributor Name" -v
npx snarkjs zkey export verificationkey zk/zkey/password_0001.zkey zk/verification_key.json