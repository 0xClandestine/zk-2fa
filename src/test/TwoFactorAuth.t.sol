// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "./mocks/TwoFactorAuthMock.sol";
import "forge-std/Test.sol";

contract ContractTest is Test {

    TwoFactorAuthMock mock;

    Proof proof;

    function setUp() public {

        /// -----------------------------------------------------------------------
        /// Deploy Mock
        /// -----------------------------------------------------------------------

        mock = new TwoFactorAuthMock(
            address(this), 
            0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98
        );

        /// -----------------------------------------------------------------------
        /// Create Proof
        /// -----------------------------------------------------------------------

        uint256[2] memory b0;
        uint256[2] memory b1;

        G1Point memory a = G1Point(
            0x147f6ef8abdd2561b644b59b1f8992b305c7fbf89158897f587499fe307661d0,
            0x2a7a0cd85b3e18e60b727b0d47ccb03e9953d0f120f49e4c26a8f166ac48a107
        );
        
        b0[0] = 0x0875cb1de7e2c279e05c0a0e5f40c4fb90cf698f4f73b7640ffa6520c7b59048;
        b0[1] = 0x126de70eacce0cea629171f8a09674241f3ecab152196c94a68cf8b4767e3986;

        b1[0] = 0x04ba32f3f46191d611c5f7d75bb650c88a5071ac94ea95a1e4e0137a9ce2001a;
        b1[1] = 0x07aa2d1e319d2045f3bc63b380babb3c7e1bd0c7d50c44a754738bd995fbbd3f;

        G2Point memory b = G2Point(b0, b1);

        G1Point memory c = G1Point(
            0x1d6345c82edb41cd8fdda29d9d5840dcf1632943a01e15785efcd065f7df0ff5,
            0x165167a1ac89ef9638e0784501226b8ec6b7ce910331562e74b36ff3fb718af2
        );

        proof = Proof(a, b, c);
    }

    function testSetOwner() public {

        address newOwner = address(0xB0b);
        uint256 nullifierHash = 0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98;

        mock.setOwner(newOwner, nullifierHash, proof);

        assertEq(mock.owner(), newOwner);
        assertEq(mock.nullifierSpent(nullifierHash), true);
    }

    function testSetOwner_BadProofFails() public {

        address newOwner = address(0xB0b);
        uint256 nullifierHash = 0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98;

        uint256[2] memory b0;
        uint256[2] memory b1;

        G1Point memory a = G1Point(0,0);
        G2Point memory b = G2Point(b0, b1);
        G1Point memory c = G1Point(0, 0);

        proof = Proof(a, b, c);

        // Should revert as proof is simply invalid.
        vm.expectRevert(InvalidProof.selector);
        mock.setOwner(newOwner, nullifierHash, proof);
    }

    function testSetOwner_WrongNullifierFails() public {

        address newOwner = address(0xB0b);
        uint256 nullifierHash = 0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98;

        vm.expectRevert(InvalidProof.selector);
        mock.setOwner(newOwner, 0, proof);
    }

    function testSetOwner_SpentNullifierFails() public {

        address newOwner = address(0xB0b);
        uint256 nullifierHash = 0x2d93b56b90980b56eeb1b3ac6a9959ab9480bfe53a1356b6afae137d9f90cb98;

        mock.setOwner(newOwner, nullifierHash, proof);
        
        // Should revert as nullifier/proof pair has already been used.
        vm.prank(newOwner);
        vm.expectRevert(NullifierAlreadySpent.selector);
        mock.setOwner(newOwner, nullifierHash, proof);
    }
}