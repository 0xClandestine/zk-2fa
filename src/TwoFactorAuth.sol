// SPDX-License-Identifier: MIT
pragma solidity ^0.8.0;

import "./Verifier.sol";

abstract contract TwoFactorAuth is Verifier {
    /// -----------------------------------------------------------------------
    /// Events
    /// -----------------------------------------------------------------------

    event OwnerUpdated(address indexed user, address indexed newOwner);

    /// -----------------------------------------------------------------------
    /// Ownership Storage
    /// -----------------------------------------------------------------------

    uint256[] public input;

    address public owner;

    modifier onlyOwner(
        Proof memory proof
    ) virtual {
        require(
            msg.sender == owner && verify(input, proof) == 1, 
            "UNAUTHORIZED"
        );

        _;
    }

    /// -----------------------------------------------------------------------
    /// Constructor
    /// -----------------------------------------------------------------------

    constructor(address _owner, uint256 _input) {

        input.push(_input);

        owner = _owner;
        
        emit OwnerUpdated(address(0), _owner);
    }

    /// -----------------------------------------------------------------------
    /// Ownership Logic
    /// -----------------------------------------------------------------------

    function setOwner(
        address newOwner,
        Proof memory proof
    ) public virtual onlyOwner(proof) {
        owner = newOwner;

        emit OwnerUpdated(msg.sender, newOwner);
    }
}
