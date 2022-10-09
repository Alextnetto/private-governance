// SPDX-License-Identifier: MIT
pragma solidity >=0.8.0;

import "forge-std/Test.sol";     
import {ZKGovToken} from "../src/ERC20.sol";

contract ERC20Test is Test {
    ZKGovToken token;

    address alice = vm.addr(0x1);
    address bob = vm.addr(0x2);

    function setUp() public virtual {
        token = new ZKGovToken();
    }

    function testMint() public {
        token.mint(alice, 100);
        assertEq(100, token.balanceOf(alice));
    }
}