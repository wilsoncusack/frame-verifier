// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import {
    MessageDataCodec,
    MessageData,
    MessageType,
    ReactionType,
    CastId
} from "farcaster-solidity/protobufs/message.proto.sol";

import {Blake3} from "farcaster-solidity/libraries/Blake3.sol";

import {Ed25519} from "farcaster-solidity/libraries/Ed25519.sol";

library FarcasterSolidity {
    error InvalidSignature();
    error InvalidEncoding();
    error InvalidMessageType();

    function _verifyMessage(bytes32 public_key, bytes32 signature_r, bytes32 signature_s, bytes memory message)
        internal
        pure
        returns (bool)
    {
        // Calculate Blake3 hash of FC message (first 20 bytes)
        bytes memory message_hash = Blake3.hash(message, 20);

        // Verify signature
        return Ed25519.verify(public_key, signature_r, signature_s, message_hash);
    }

    function verifyFrameActionBodyMessage(
        bytes32 public_key,
        bytes32 signature_r,
        bytes32 signature_s,
        bytes memory message
    ) external {
        _verifyMessage(public_key, signature_r, signature_s, message);
    }
}
