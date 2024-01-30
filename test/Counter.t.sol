// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console2} from "forge-std/Test.sol";
import {FarcasterSolidity} from "../src/FarcasterSolidity.sol";
import "../src/Encoder.sol";

contract CounterTest is Test {
    function test() public {
        bytes memory message =
            hex"080d1095c90218e3d8a52e20028201330a1368747470733a2f2f6578616d706c652e636f6d10011a1a0895c902121473a773451c6b36d0a8dc8c806407a8a3f5f7da9e";
        bytes memory sigHex =
            hex"68c44d89761d24d6a33f9fc0373a4fbc047c9f22835177d1a5eb33c91a0f2687be15a695fc7039845d9ce37f87d850cdef7f16b944a3d6f92a09825cb7a0fd09";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 pk = 0x4fe8406370be9f8cbaddc6f0e909b2fc75c9d1f56d19395f9a90d9741b4f42d0;
        FarcasterSolidity.verifyFrameActionBodyMessage({
            public_key: pk,
            signature_r: r,
            signature_s: s,
            message: message
        });
    }

    function test_2() public {
        bytes memory b = MessageDataCodec.encode(
            MessageData({
                type_: MessageType.MESSAGE_TYPE_FRAME_ACTION,
                fid: 64417,
                timestamp: 97190733,
                network: FarcasterNetwork.FARCASTER_NETWORK_TESTNET,
                frame_action_body: FrameActionBody({
                    // frame.base.org / chainId:calldata
                    url: hex"68747470733a2f2f6578616d706c652e636f6d",
                    button_index: 1,
                    cast_id: CastId({fid: 64417, hash: hex"e9eca527e4d2043b1f77b5b4d847d4f71172116b"})
                })
            })
        );
        console2.logBytes(b);
        assertEq(
            b,
            hex"080d10a1f70318cd86ac2e20028201330a1368747470733a2f2f6578616d706c652e636f6d10011a1a08a1f7031214e9eca527e4d2043b1f77b5b4d847d4f71172116b"
        );

        bytes memory sigHex =
            hex"17bdafddf9cf7464959a28d57fb5da7c596de4796f663588ea24d804c13ca043f46a546ca474d1b4420cc48e8720d8051786b21a689cdf485f78e51e36a12b05";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 pk = 0x292404752ddd67080bbfe93af4017e51388ebc3c9fb96b8984658155de590b38;
        FarcasterSolidity.verifyFrameActionBodyMessage({
            public_key: pk,
            signature_r: r,
            signature_s: s,
            message: b
        });
    }
}
