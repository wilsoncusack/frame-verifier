// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import {Blake3} from "./libraries/Blake3.sol";
import {Ed25519} from "./libraries/Ed25519.sol";
import {MessageData, MessageDataCodec} from "./Encoder.sol";

library FrameVerifier {
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

    function verifyMessageData(
        bytes32 public_key,
        bytes32 signature_r,
        bytes32 signature_s,
        MessageData memory messageData
    ) external pure {
        _verifyMessage(public_key, signature_r, signature_s, MessageDataCodec.encode(messageData));
    }
}
