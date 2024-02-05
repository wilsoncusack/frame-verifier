// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {UserOperation} from "./UserOperation.sol";
import {SharedVerifier} from "../SharedVerifier.sol";

contract Paymaster {
    mapping(bytes32 => uint256) public castBalance;
    mapping(uint256 => uint256) public fidBalance;

    function validatePaymasterUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 maxCost)
        external
        returns (bytes memory context, uint256 validationData)
    {}

    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external {}

    enum PostOpMode {
        opSucceeded, // user op succeeded
        opReverted, // user op reverted. still has to pay for gas.
        postOpReverted // user op succeeded, but caused postOp to revert

    }
}
