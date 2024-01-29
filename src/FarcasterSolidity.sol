// SPDX-License-Identifier: GPL-3.0
pragma solidity ^0.8.9;

import {
  MessageDataCodec,
  MessageData,
  MessageType,
  ReactionType,
  CastId
} from 'farcaster-solidity/protobufs/message.proto.sol';

import {
  Blake3
} from 'farcaster-solidity/libraries/Blake3.sol';

import {
  Ed25519
} from 'farcaster-solidity/libraries/Ed25519.sol';


library FarcasterSolidity {
  error InvalidSignature();
  error InvalidEncoding();
  error InvalidMessageType();

  function _verifyMessage(
    bytes32 public_key,
    bytes32 signature_r,
    bytes32 signature_s,
    bytes memory message
  ) internal pure returns(MessageData memory) {
    // Calculate Blake3 hash of FC message (first 20 bytes)
    bytes memory message_hash = Blake3.hash(message, 20);

    // Verify signature
    bool valid = Ed25519.verify(
      public_key,
      signature_r,
      signature_s,
      message_hash
    );

    if (!valid) {
      revert InvalidSignature();
    }

    (
      bool success,
      ,
      MessageData memory message_data
    ) = MessageDataCodec.decode(0, message, uint64(message.length));

    if (!success) {
      revert InvalidEncoding();
    }

    return message_data;
  }

  function _verifyMessage2(
    bytes32 public_key,
    bytes32 signature_r,
    bytes32 signature_s,
    bytes memory message
  ) internal pure returns(MessageData memory) {
    // Calculate Blake3 hash of FC message (first 20 bytes)
    bytes memory message_hash = Blake3.hash(message, 20);

    // Verify signature
    bool valid = Ed25519.verify(
      public_key,
      signature_r,
      signature_s,
      message_hash
    );

    if (!valid) {
      revert InvalidSignature();
    }

    (
      bool success,
      ,
      MessageData memory message_data
    ) = MessageDataCodec.decode(0, message, uint64(message.length));

    if (!success) {
      revert InvalidEncoding();
    }

    return message_data;
  }

  function verifyFrameActionBodyMessage(
    bytes32 public_key,
    bytes32 signature_r,
    bytes32 signature_s,
    bytes memory message
  ) external {
    MessageData memory message_data = _verifyMessage(
      public_key,
      signature_r,
      signature_s,
      message
    );

    if (message_data.type_ != MessageType.MESSAGE_TYPE_FRAME_ACTION) {
      revert InvalidMessageType();
    }
  }
}