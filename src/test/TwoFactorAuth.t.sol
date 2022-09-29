// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./mocks/TwoFactorAuthMock.sol";
import "ds-test/test.sol";

// TODO: include nonce such that each proof is different
contract ContractTest is DSTest {

    TwoFactorAuthMock mock;

    Proof proof;

    function setUp() public {

        /// -----------------------------------------------------------------------
        /// Deploy Mock
        /// -----------------------------------------------------------------------

        mock = new TwoFactorAuthMock(
            address(this), 
            0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98 // input
        );

        /// -----------------------------------------------------------------------
        /// Create Proof
        /// -----------------------------------------------------------------------

        uint256[2] memory b0;
        uint256[2] memory b1;

        G1Point memory a = G1Point(
            0x1e9de2bfb66f768ba21f8a72ddd1143c7944af338293763eb1d31167aea8ebd7,
            0x22864a84215ba843bb955b1fc63c5a68c7eb42d944bb495176f5e508d97f96d6
        );
        
        b0[0] = 0x251337f354bbe0bec3b92b06bda89d44c4e21d67d557613824ab6f8043373693;
        b0[1] = 0x0bd8e2bbb15cffcd58b0e43e314325b8919402fb6cb296aab87a7104fd533a3f;

        b1[0] = 0x1fae3f85cbe403ed2746a7cd735b537018db85aaf6c33d238d0c8a50b7b18573;
        b1[1] = 0x1abfa2d9a837ec1328e0f4c254d6aa119d409bb3d08b07acd9012cb08a08acfd;

        G2Point memory b = G2Point(b0, b1);

        G1Point memory c = G1Point(
            0x0b00818c83ab17b4e6651972609c268ac7d387e9691db061e1088e2400266b9b,
            0x1e555a1c1ce509ab7cb3dbe9e1b9a27ccdac4340702dc38f37a88c28b61e93d8
        );

        proof = Proof(a, b, c);
    }

    function testGoodProof() public {

        // Owner must 
        mock.setOwner(address(0xB0b), proof);
    }
}
