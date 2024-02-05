// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {MessageData, FrameVerifier} from "../FrameVerifier.sol";

// To attempt to save gas verifying Frames in multiple contracts
// we can use a shared verifier that saves the result
contract SharedVerifier {
    mapping(bytes32 => bool) public isValid;

    struct VerifyRequest {
        bytes32 public_key;
        bytes32 signature_r;
        bytes32 signature_s;
        MessageData messageData;
    }

    function verifyMessageData(VerifyRequest memory request) external returns (bool) {
        bytes32 hash = keccak256(abi.encode(request.messageData));
        if (isValid[hash]) {
            return true;
        }

        bool valid = FrameVerifier.verifyMessageData(
            request.public_key, request.signature_r, request.signature_s, request.messageData
        );

        if (valid) {
            isValid[hash] = true;
        }

        return valid;
    }
}
