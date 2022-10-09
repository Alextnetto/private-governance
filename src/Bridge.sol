// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.8.4;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {AztecTypes} from "./aztec/AztecTypes.sol";
import {ErrorLib} from "./aztec/ErrorLib.sol";
import {BridgeBase} from "./aztec/BridgeBase.sol";


contract VotingBridge is BridgeBase {
    address public token;

    uint256 public option1;
    uint256 public option2;

    constructor(address _rollupProcessor, address _token) BridgeBase(_rollupProcessor) {
        token = _token;
    }

    /**
     * @notice A function which returns an _totalInputValue amount of _inputAssetA
     * @param _inputAssetA - Arbitrary ERC20 token
     * @param _outputAssetA - Equal to _inputAssetA
     * @param _rollupBeneficiary - Address of the contract which receives subsidy in case subsidy was set for a given
     *                             criteria
     * @return outputValueA - the amount of output asset to return
     * @dev In this case _outputAssetA equals _inputAssetA
     */
    function convert(
        AztecTypes.AztecAsset calldata _inputAssetA,
        AztecTypes.AztecAsset calldata _inputAssetB,
        AztecTypes.AztecAsset calldata _outputAssetA,
        AztecTypes.AztecAsset calldata _outputAssetB,
        uint256 _totalInputValue,
        uint256,
        uint64 _auxData,
        address _rollupBeneficiary
    )
        external
        payable
        override(BridgeBase)
        onlyRollup
        returns (
            uint256 outputValueA,
            uint256,
            bool
        )
    {
        // Check the input asset is ERC20
        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();
        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();
        // Return the input value of input asset
        outputValueA = _totalInputValue;
        // Approve rollup processor to take input value of input asset
        IERC20(_outputAssetA.erc20Address).approve(ROLLUP_PROCESSOR, _totalInputValue);

        if (_auxData == 0) {
            option1 += 1;
        } else {
            option2 += 1;
        }

        //Lock the tokens until votation is finished
    }
}
