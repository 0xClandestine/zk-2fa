// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.0;

struct G1Point {
    uint256 X;
    uint256 Y;
}

struct G2Point {
    uint256[2] X;
    uint256[2] Y;
}

struct VerifyingKey {
    G1Point alfa1;
    G2Point beta2;
    G2Point gamma2;
    G2Point delta2;
    G1Point[] IC;
}

struct Proof {
    G1Point A;
    G2Point B;
    G1Point C;
}

contract Verifier {

    uint256 internal constant SNARK_SCALER_FIELD = 21888242871839275222246405745257275088548364400416034343698204186575808495617;
    uint256 internal constant PRIME_Q = 21888242871839275222246405745257275088696311157297823662689037894645226208583;

    /// -----------------------------------------------------------------------
    /// Verifying Key
    /// -----------------------------------------------------------------------

    function VERIFYING_KEY() internal pure returns (VerifyingKey memory vk) {
        vk.alfa1 = G1Point(
            566901183605439099244008549071481791512742753257140662736636412576776624427,
            14821748873863384683289199376964982260628558851275861476516214307599094157516
        );

        vk.beta2 = G2Point(
            [19371564638149475551896747882529325166102462853478632455922041151810010811864,
             8097505577235984899247569416876249972733133717601686435901342692683012893581],
            [6163116556553419998282035742356278187079538954914605311936542628623125368646,
             10925604275637651521269271360276377581677314028651737409561304586420181364899]
        );
        vk.gamma2 = G2Point(
            [11559732032986387107991004021392285783925812861821192530917403151452391805634,
             10857046999023057135944570762232829481370756359578518086990519993285655852781],
            [4082367875863433681332203403145435568316851327593401208105741076214120093531,
             8495653923123431417604973247489272438418190587263600148770280649306958101930]
        );
        vk.delta2 = G2Point(
            [5501910457542027649028780664920767816281174628838618712404281177471430462424,
             10175769364829125902984128088310208278186720328554044047528738319691430559129],
            [12525138362751672834370848149540555202295208419213924069134569131746564962998,
             19499179444511470748550237455964787521084452240605108789168078868965674779447]
        );
        vk.IC = new G1Point[](3);
        
        vk.IC[0] = G1Point( 
            8532422276098650338024897910391188725889331071822935684899586014948364886778,
            15211610596576920499082528288619783528237788340144042089949568175021182303101
        );                                      
        
        vk.IC[1] = G1Point( 
            5501616623923139416553448968459887625655645013643677954327047205790259754265,
            12598553443896300500828470270999416687861150449738144309187459825102847406157
        );                                      
        
        vk.IC[2] = G1Point( 
            12796848167546454633301252672803941114191531190865400945999053938788637975195,
            13809804019534723273957265058948870084952839561557153612717745797372562798121
        );    
    }

    function verify(
        Proof memory proof, 
        uint256 secretHash, 
        uint256 nullifierHash
    ) internal view returns (bool) {

        require(
            secretHash < SNARK_SCALER_FIELD && secretHash < SNARK_SCALER_FIELD,
            "verifier-gte-snark-scalar-field"
        );

        VerifyingKey memory vk = VERIFYING_KEY();
        G1Point memory vk_x = G1Point(0, 0);

        vk_x = addition(vk_x, scalar_mul(vk.IC[1], secretHash));
        vk_x = addition(vk_x, scalar_mul(vk.IC[2], nullifierHash));
        vk_x = addition(vk_x, vk.IC[0]);

        G1Point[] memory p1 = new G1Point[](4);
        G2Point[] memory p2 = new G2Point[](4);
        
        p1[0] = negate(proof.A);
        p2[0] = proof.B;
        p1[1] = vk.alfa1;
        p2[1] = vk.beta2;
        p1[2] = vk_x;
        p2[2] = vk.gamma2;
        p1[3] = proof.C;
        p2[3] = vk.delta2;

        if (pairing(p1, p2)) return true;
    }

    function verifyProof(
        Proof memory proof,
        uint256 secretHash,
        uint256 nullifierHash
    ) public view returns (bool r) {

        uint256[] memory inputValues = new uint256[](2);

        inputValues[0] = secretHash;
        inputValues[1] = nullifierHash;

        return verify(proof, secretHash, nullifierHash);
    }

    function negate(G1Point memory p) internal pure returns (G1Point memory r) {
        unchecked {
            if (p.X == 0 && p.Y == 0) return G1Point(0, 0);

            return G1Point(p.X, PRIME_Q - (p.Y % PRIME_Q));
        }        
    }

    function addition(G1Point memory p1, G1Point memory p2) internal view returns (G1Point memory r) {
        uint256[4] memory input;
        input[0] = p1.X;
        input[1] = p1.Y;
        input[2] = p2.X;
        input[3] = p2.Y;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 6, input, 0xc0, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }
        require(success,"pairing-add-failed");
    }

    function scalar_mul(G1Point memory p, uint256 s) internal view returns (G1Point memory r) {
        uint256[3] memory input;
        input[0] = p.X;
        input[1] = p.Y;
        input[2] = s;
        bool success;

        assembly {
            success := staticcall(sub(gas(), 2000), 7, input, 0x80, r, 0x60)
            // Use "invalid" to make gas estimation work
            switch success case 0 { invalid() }
        }

        require (success,"pairing-mul-failed");
    }

    function pairing(G1Point[] memory p1, G2Point[] memory p2) internal view returns (bool) {
        unchecked {
            require(p1.length == p2.length,"pairing-lengths-failed");
            
            uint256 elements = p1.length;
            uint256 inputSize = elements * 6;
            uint256[] memory input = new uint256[](inputSize);
            
            for (uint256 i; i < elements; ++i) {
                input[i * 6 ]    = p1[i].X;
                input[i * 6 + 1] = p1[i].Y;
                input[i * 6 + 2] = p2[i].X[0];
                input[i * 6 + 3] = p2[i].X[1];
                input[i * 6 + 4] = p2[i].Y[0];
                input[i * 6 + 5] = p2[i].Y[1];
            }
            
            uint256[1] memory out;
            bool success;

            assembly {
                success := staticcall(sub(gas(), 2000), 8, add(input, 0x20), mul(inputSize, 0x20), out, 0x20)
                // Use "invalid" to make gas estimation work
                switch success case 0 { invalid() }
            }

            require(success,"pairing-opcode-failed");
            
            return out[0] != 0;
        }
    }
}
