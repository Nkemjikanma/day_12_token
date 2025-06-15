// SPDX-License-Identifier: UNLICENSED
pragma solidity ^0.8.13;

import {Test, console} from "forge-std/Test.sol";
import {Tokem} from "../src/Tokem.sol";

contract TokemTest is Test {
    // Counter public counter;
    Tokem public tokem;

    function setUp() public {
        // counter = new Counter();
        // counter.setNumber(0);
        tokem = new Tokem();
    }
}
