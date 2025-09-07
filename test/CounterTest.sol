// SPDX-License-Identifier: UNLICENSED
pragma solidity 0.8.29;

import {Test} from "forge-std/Test.sol";
import {Counter} from "src/Counter.sol";

contract CounterTest is Test {
    Counter public counter;

    function fixture() public {
        counter = new Counter();
        counter.setNumber(0);
    }
}
