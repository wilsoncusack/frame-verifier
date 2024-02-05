// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {MessageData} from "../../FrameVerifier.sol";
// import Strings

import {UserOperation} from "./UserOperation.sol";
import {SharedVerifier} from "../SharedVerifier.sol";

contract Account {
    bytes32 public publicKey;
    string public baseUrl;
    SharedVerifier public sharedVerifier;
    uint256 public lastFrameTimstamp;

    struct FrameUserOpSignature {
        bytes32 signature_r;
        bytes32 signature_s;
        MessageData messageData;
    }

    function validateUserOp(UserOperation calldata userOp, bytes32 userOpHash, uint256 missingAccountFunds)
        external
        returns (uint256 validationData)
    {
        FrameUserOpSignature memory frameStruct = abi.decode(userOp.signature, (FrameUserOpSignature));
        string memory expectedUrl = string.concat(baseUrl, Strings.toString(block.chainId), ":", userOp.callData);
        frameStruct.messageData.frame_action_body.url = expectedUrl;

        if (
            SharedVerifier.verifyMessageData(
                SharedVerifier.VerifyRequest(
                    publicKey, frameStruct.signature_r, frameStruct.signature_s, frameStruct.messageData
                )
            )
        ) {
            if (frameStruct.messageData.frame_action_body.timestamp < lastFrameTimstamp) {
                return 1;
            }
            lastFrameTimstamp = frameStruct.messageData.frame_action_body.timestamp;
            return 0;
        }

        return 1;

        // pay missing account funds
    }
}
