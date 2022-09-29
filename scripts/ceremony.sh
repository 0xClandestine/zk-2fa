#!/bin/bash
npx snarkjs powersoftau new bn128 12 zk/ptau/pot12_0000.ptau -v
npx snarkjs powersoftau contribute zk/ptau/pot12_0000.ptau zk/ptau/pot12_0001.ptau --name="First contribution" -v