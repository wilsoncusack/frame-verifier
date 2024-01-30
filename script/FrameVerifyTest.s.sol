// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Script, console} from "forge-std/Script.sol";
import {FarcasterSolidity} from "../src/FarcasterSolidity.sol";

contract FrameVerifyTest is Script {
    function setUp() public {}

    function run() public {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        bytes memory message =
            hex"080d1095c90218e3d8a52e20028201330a1368747470733a2f2f6578616d706c652e636f6d10011a1a0895c902121473a773451c6b36d0a8dc8c806407a8a3f5f7da9e";
        bytes memory sigHex =
            hex"68c44d89761d24d6a33f9fc0373a4fbc047c9f22835177d1a5eb33c91a0f2687be15a695fc7039845d9ce37f87d850cdef7f16b944a3d6f92a09825cb7a0fd09";
        (bytes32 r, bytes32 s) = abi.decode(sigHex, (bytes32, bytes32));
        bytes32 public_key = 0x4fe8406370be9f8cbaddc6f0e909b2fc75c9d1f56d19395f9a90d9741b4f42d0;
        Dummy d = Dummy(0x1030aFaA62BcD43de6273D89b1c127C642d5A63F);
        vm.startBroadcast(deployerPrivateKey);
        d.verifyFrameActionBodyMessage({public_key: public_key, signature_r: r, signature_s: s, message: message});
    }
}

contract Dummy {
    function verifyFrameActionBodyMessage(
        bytes32 public_key,
        bytes32 signature_r,
        bytes32 signature_s,
        bytes memory message
    ) external {
        FarcasterSolidity.verifyFrameActionBodyMessage({
            public_key: public_key,
            signature_r: signature_r,
            signature_s: signature_s,
            message: message
        });
    }
}
