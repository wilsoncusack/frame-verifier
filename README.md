Inspired by [Farcaster-Solidity](https://github.com/pavlovdog/farcaster-solidity), a lib for building, encoding, and verifying Farcaster MessageData structs containing Frame actions. This might be useful, for example, if you want to use Frames to control a ERC-4337 account, and you want to do more than just check a valid signature. You could accept some fields from the caller, like fid, and populate others yourself: e.g. you could expect the url to match `user-op/<chainId>:<calldata>`, in order to verify something about the data that was signed. 

Code is not audited, provided as is. Use at your own risk :)


```
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
    bool ret = FrameVerifier.verifyMessageData({public_key: pk, signature_r: r, signature_s: s, messageData: md});
    assertTrue(ret);
}
```