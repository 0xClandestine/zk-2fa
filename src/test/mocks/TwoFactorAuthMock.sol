// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.0;

import "../../TwoFactorAuth.sol";

contract TwoFactorAuthMock is TwoFactorAuth {
    constructor(
        address _owner, 
        uint256 _secretHash
    ) TwoFactorAuth(_owner, _secretHash) {}
}