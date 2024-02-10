// SPDX-License-Identifier: MIT
pragma solidity ^0.8.9;

import {UserOperation} from "./UserOperation.sol";
import {Account} from "./Account.sol";
import {SharedVerifier} from "../SharedVerifier.sol";

/// @dev WARNING: This was written quickly with no tests, almost certainly has bugs
contract Paymaster {
    enum PostOpMode {
        opSucceeded,
        opReverted,
        postOpReverted
    }
    
    mapping(bytes32 => uint256) public castBalance;
    mapping(uint256 => uint256) public fidBalance;

    enum SponsorType {
        cast,
        fid
    }

    SharedVerifier public sharedVerifier;

    function validatePaymasterUserOp(UserOperation calldata userOp, bytes32, uint256 maxCost)
        external
        returns (bytes memory context, uint256 validationData)
    {
        // check msg.sender is entrypoint

        Account.FrameUserOpSignature memory frameStruct = abi.decode(userOp.signature, (Account.FrameUserOpSignature));

        // assume invalid
        validationData = 1;

        if (
            sharedVerifier.verifyMessageData(
                SharedVerifier.VerifyRequest(
                    Account(userOp.sender).publicKey(),
                    frameStruct.signature_r,
                    frameStruct.signature_s,
                    frameStruct.messageData
                )
            )
        ) {
            bytes32 castHash = bytes32(frameStruct.messageData.frame_action_body.cast_id.hash);
            if (castBalance[castHash] >= maxCost) {
                castBalance[castHash] -= maxCost;
                validationData = 0;
                context = abi.encode(maxCost, uint256(castHash), SponsorType.cast);
            }

            if (fidBalance[frameStruct.messageData.fid] >= maxCost) {
                fidBalance[frameStruct.messageData.fid] -= maxCost;
                validationData = 0;
                context = abi.encode(maxCost, frameStruct.messageData.fid, SponsorType.fid);
            }
        }
    }

    function postOp(PostOpMode mode, bytes calldata context, uint256 actualGasCost) external {
        // check msg.sender is entrypoint

        if (mode == PostOpMode.postOpReverted) {
            return;
        }

        (uint256 maxCost, uint256 identifier, SponsorType sType) = abi.decode(context, (uint256, uint256, SponsorType));
        uint256 credit = maxCost - actualGasCost;
        if (sType == SponsorType.cast) {
            castBalance[bytes32(identifier)] += credit;
        } else {
            fidBalance[identifier] += credit;
        }
    }
}
