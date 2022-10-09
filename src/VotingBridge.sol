// SPDX-License-Identifier: Apache-2.0
// Copyright 2022 Aztec.
pragma solidity >=0.8.4;

import {IERC20} from "openzeppelin-contracts/token/ERC20/IERC20.sol";
import {AztecTypes} from "./aztec/AztecTypes.sol";
import {ErrorLib} from "./aztec/ErrorLib.sol";
import {BridgeBase} from "./aztec/BridgeBase.sol";


contract VotingBridge is BridgeBase {
    address immutable public token;
    uint256 immutable public votationEnd;

    uint256 public option1;
    uint256 public option2;

    mapping(uint256 => uint256) transactionMapping;

    error VotationEnded();
    error VotationNotEnded();

    event VotationResult(uint256 option1Amount, uint256 option2Amount);

    constructor(address _rollupProcessor, address _token, uint256 timeUntilVotationEnd) BridgeBase(_rollupProcessor) {
        token = _token;
        votationEnd = timeUntilVotationEnd + block.timestamp;
        IERC20(token).approve(ROLLUP_PROCESSOR, type(uint256).max);
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
        uint256 _interactionNonce,
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
        // Check if votation still going on
        if (votationEnd >= block.timestamp) revert VotationEnded();
        // Check the input asset is ERC20
        if (_inputAssetA.assetType != AztecTypes.AztecAssetType.ERC20) revert ErrorLib.InvalidInputA();
        if (_outputAssetA.erc20Address != _inputAssetA.erc20Address) revert ErrorLib.InvalidOutputA();

        transactionMapping[_interactionNonce] = _totalInputValue;

        if (_auxData == 0) {
            option1 += _totalInputValue;
        } else {
            option2 += _totalInputValue;
        }

        return (0, 0, true);
    }

    function finalise(
        AztecTypes.AztecAsset calldata _inputAssetA,
        AztecTypes.AztecAsset calldata _inputAssetB,
        AztecTypes.AztecAsset calldata _outputAssetA,
        AztecTypes.AztecAsset calldata _outputAssetB,
        uint256 _interactionNonce,
        uint64 _auxData
    )
        external
        payable
        override(BridgeBase)
        onlyRollup
        returns (
            uint256 outputValueA,
            uint256 outputValueB,
            bool interactionComplete
        )
    {
        // Check if votation ended
        if (votationEnd < block.timestamp) revert VotationNotEnded();

        emit VotationResult(option1, option2);

        return (transactionMapping[_interactionNonce], 0 , true);
    }
}
