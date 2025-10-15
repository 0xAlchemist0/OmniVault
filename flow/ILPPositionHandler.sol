pragma solidity ^0.8.2;// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;

//right now the target is getting the tokens deposited and bringing back to soncic and checkeing where lz message is send from from what endpoint
// SPDX-License-Identifier: MIT
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
interface ILPPositionHandler is INonfungiblePositionManager {
    //deposits tokens and creates position 
      function mint(MintParams calldata params)
        external
        payable
        override
        checkDeadline(params.deadline)
        returns (uint256 tokenId, uint128 liquidity, uint256 amount0, uint256 amount1);

}