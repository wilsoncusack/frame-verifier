// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FrameVerifier} from "../src/FrameVerifier.sol";
import "../src/Encoder.sol";

contract CounterTest is Test {
    function test_EncodeAndVerify() public {
        MessageData memory md = MessageData({
                type_: MessageType.MESSAGE_TYPE_FRAME_ACTION,
                fid: 64417,
                timestamp: 97190733,
                network: FarcasterNetwork.FARCASTER_NETWORK_TESTNET,
                frame_action_body: FrameActionBody({
                    url: hex"68747470733a2f2f6578616d706c652e636f6d",
                    button_index: 1,
                    cast_id: CastId({fid: 64417, hash: hex"e9eca527e4d2043b1f77b5b4d847d4f71172116b"})
                })
            });
        assertEq(
            MessageDataCodec.encode(md),
            // result from hub monorepo 
            hex"080d10a1f70318cd86ac2e20028201330a1368747470733a2f2f6578616d706c652e636f6d10011a1a08a1f7031214e9eca527e4d2043b1f77b5b4d847d4f71172116b"
        );

        // from hub mono repo 
        bytes memory sigHex =
            hex"17bdafddf9cf7464959a28d57fb5da7c596de4796f663588ea24d804c13ca043f46a546ca474d1b4420cc48e8720d8051786b21a689cdf485f78e51e36a12b05";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 pk = 0x292404752ddd67080bbfe93af4017e51388ebc3c9fb96b8984658155de590b38;
        FrameVerifier.verifyMessageData({public_key: pk, signature_r: r, signature_s: s, messageData: md});
    }
}
