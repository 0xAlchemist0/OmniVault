// SPDX-License-Identifier: MIT
pragma solidity ^0.8.20;
import {AssetVault} from "./flow/AssetVault.sol";
import {IPoolManager} from "./IPoolManager.sol";
import "https://github.com/Shadow-Exchange/shadow-core/blob/main/contracts/CL/periphery/interfaces/INonfungiblePositionManager.sol";
import {UD60x18, ud, powu, sqrt} from "@prb/math/src/UD60x18.sol";

contract VaultUnifier {
    struct Position {
        address token0;
        address token1;
        int24 tickSpacing;
        int24 tickLower;
        int24 tickUpper;
        uint128 liquidity;
        uint256 feeGrowthInside0LastX128;
        uint256 feeGrowthInside1LastX128;
        uint128 tokensOwed0;
        uint128 tokens;
        uint160 sqrtPriceX96;
        int24 tick;
        uint16 observationIndex;
        uint16 observationCardinality;
        uint16 observationCardinalityNext;
        uint8 feeProtocol;
        bool unlocked;
    }

    //get both vaults were we can get assets for both
    AssetVault vaultA;
    AssetVault vaultB;
    IPoolManager poolManager;
    IDragonPool pool;
    mapping(address => uint256[]) poolPositions; //we store here and update positions
    mapping(address => uint256) positions;
    //checks if the depositor acutallly has a position
    mapping(address => bool) hasPosition;
    //index 0 vaulta , inex1 vaultb
    mapping(address => uint256[]) depositNotInPosition;

    //wunifies both vaults vaults to perform the lp depositt
    constructor(address _vaultA, address vaultB, address _poolManager) {
        vaultA = _vaultA;
        vaultB = _vaultB;
        poolManager = _poolManager;
    }

    //we can just use the vaults public mappint of assets held lets inherit it
    //this is what is returned from the quote we use this so we dont have to write a shit ton of code
    //prolly better t put in another file

    //MintParams struct
    // address token0;
    // address token1;
    // int24 tickSpacing;
    // int24 tickLower;
    // int24 tickUpper;
    // uint256 amount0Desired;
    // uint256 amount1Desired;
    // uint256 amount0Min;
    // uint256 amount1Min;
    // address recipient;
    // uint256 deadline;
    //very layer zero message should pass in the sender of the transaction this way e can check nd store each users info properly and their positons
    function addLiquidity(MintParams calldata params, address _user) {
        //funds being in the contrat already we can control what happens make lp store data in mappings by depositor
        performVaultWithdraw();
        //we set the mapping owner => positionID
        //adds liquidity to the pool and mints the nft
        //the nft id is stored in a mappping matching the user addresss
        //each mint returns the posito id /tokenid of the nft minted
        poolPositions[_user] = poolManager.mint(params);

        //sets to true that the user has a position already
        hasPosition[_user] = True;
    }

    ///this struct is only here temporarily we make another library for this to make the code cleanrer
    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    struct IncreaseLiquidityParams {
        uint256 tokenId;
        uint256 amount0Desired;
        uint256 amount1Desired;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    //adds liquidity if the position exists already this is where the mapping comes in handy
    function addLiquidityExisting(
        MintParams calldata params,
        address _user
    ) external {
        //amount0 - vaultA, amount1 vaultB
        (uint128 liquidity, uint256 amount0, uint256 amount1) = poolManager
            .increaseLiquidity(params);
    }

    //this just trransfers from vault here so we can deposit lp from both tokens
    //and we store how much the person add and periodically update based on lp position
    function performVaultWithdraw(address _user) private {
        //we dont have to store holdings here too we got the vault so we chillin
        //withdraws from both vaults
        uint256 _vaultABal = vaultA.assestsDeposited[user];
        uint256 _vaultBBal = vaultB.assestsDeposited[user];

        vaultA.approveSpending(address(this), _vaultABal);
        vaultB.approveSpending(address(this), _vaultBBal);

        //sends funds over from both vaults to this contract
        //each withdraw returns the amount being withdrawn
        uint256 _vaultAAmount = vaultA.excecuteWithdraw(_user, address(this));
        uint256 _vaultBAmount = vaultB.excuteWithdraw(_user, address(this));
    }

    //inorder to add liuiditywhat we do is trnsfer the vaults assets to this contract deposit into lp and store deposits in a mapping

    //uint - positive, int- both
    //returns an array contains the balance of tokena and tokenb use equation then return and we update values
    //calldta type means the valu is read only no copy is made most efficient and heapest
    function calculateAndUpdatePostions(
        bytes calldata _postionEncoded,
        address _user
    ) returns (uint256[]) {
        uint256 amount0 = 0;
        uint256 amount1 = 0;

        //eveythkng will be in one struct
        //we dont want an overflow weeoe for 1001
        Position _position = abi.decode(_postionEncoded, (Position));
        uint256 p_current = _position.sqrtPriceX96 / 2 ** 96;
        UD60x18 base = ud(1000100000000000000);
        // Handle negative ticks properly
        UD60x18 lowerPow = _position.tickLower >= 0
            ? powu(base, uint256(int256(_position.tickLower)))
            : div(ud(1e18), powu(base, uint256(int256(-_position.tickLower))));

        UD60x18 upperPow = _position.tickUpper >= 0
            ? powu(base, uint256(int256(_position.tickUpper)))
            : div(ud(1e18), powu(base, uint256(int256(-_position.tickUpper))));

        // Take square roots
        p_lower = sqrt(lowerPow);
        p_upper = sqrt(upperPow);
        if (P_current <= P_lower) {
            // position is entirely in token0
            amount0 = (liquidity * (P_upper - P_lower)) / (P_lower * P_upper);
            amount1 = 0;
        } else if (P_current < P_upper) {
            // active range — mix of both tokens
            amount0 =
                (liquidity * (P_upper - P_current)) /
                (P_current * P_upper);
            amount1 = liquidity * (P_current - P_lower);
        } else {
            // position fully converted to token1
            amount0 = 0;
            amount1 = liquidity * (P_upper - P_lower);
        }

        //updates amount based on position

        vaultA.updateAmountDeposited(amount0, _user);
        vaultB.updateAmountDeposited(amount1, _user);

        return [amount0, amount1, liquidity];
    }

    //now we work on the withdrawing flow
    //removes entirley the position

    struct DecreaseLiquidityParams {
        uint256 tokenId;
        uint128 liquidity;
        uint256 amount0Min;
        uint256 amount1Min;
        uint256 deadline;
    }

    function removePosition(address _user) external {
        uint256[] position = calculatePositions(abi.encode((_position)));
        DecreaseLiquidityParams _params = DecreaseLiquidityParams(
            poolPositions[_user],
            position[0],
            posiiton[1],
            //5 minte deadline block.timestamp now + 300 secoonds
            block.timestamp() + 300
        );
        decreaseLiquidity(_params, _user);
    }

    //remvoes lp position burns nft and sends back funds to vaults with uupdated values

    function removeAndWithdraw(address _user) {
        //make sure fees are collected and checked beofre withdrawing and update values as well
        removePosition(_user);
    }

    struct CollectParams {
        uint256 tokenId;
        address recipient;
        uint128 amount0Max;
        uint128 amount1Max;
    }

    //we will put all these structs ina library dont worry :)

    function collectFeesEarned(address _user) {
        (
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            ,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = getPosition(_user);
        CollectParams params = CollectParams(
            poolPositions[_user],
            address(this),
            tokensOwed0,
            tokensOwed2
        );
        //collects fees and returns the fees amount collected for vaultA asset and vaultB asset
        (uint128 amount0, uint128 amoount1) = poolManager.collect(params);
        ////needs a security overview
        //since we ar collecting fees we have to update how much user should have in the vault deposited
        vaultA.updateAmountDeposited(amount0, _user);
        vaultB.updateAmountDeposited(amount1, _user);
        ///////////////////////////
        updateDepositsNotInVault([amount0, amonunt1], _user, true);
        ///////////////////////////////
    }

    function withdrawToVaults(address _user) extenral {
        //withdraws from the unifier back to the vault
        vaultA.asset.transferFrom(
            address(this),
            vaultA,
            depositNotInPosition[_user][0]
        );
        vaultB.asset.transferFrom(
            address(this),
            vaultA,
            depositNotInPosition[_user][1]
        );
    }

    function getDepositedNotInVault(address _user) returns (uint256[]) {
        //returns the assets the user has i the vault  unifier tat are not in the position
        return depositNotInPosition[_user];
    }

    //updates it here no repetive code i will mke this as clean as a mr clean
    function updateDepositsNotInVault(
        uint256[] _amounts,
        address _user,
        bool isIncrease
    ) private {
        if (isIncrease) {
            //updates by adding to each
            depositNotInPosition[_user][0] += _amounts[0];
            depositNotInPosition[_user][1] += _amounts[1];
        } else {
            //updates by subtracting  to each
            //dont thik w will use this but may come in handy if user redeposits into the positon witht he asset in the vault no deposited into lp
            depositNotInPosition[_user][0] -= _amounts[0];
            depositNotInPosition[_user][1] -= _amounts[1];
        }
    }

    //now create a logic to handle the decrease or position removal

    //this removes only some tokens from the position
    function decreaseLiquidity(
        DecreaseLiquidityParams calldata params,
        address _user
    ) external {
        (uint256 amount0, unt256 amount1) = poolManager.decrease(params);
        //will fix later on when we refactor this stores how much was decreased we later on calculate when sending tokens back to the user
        //increae cuz if u dont add its gonna make a prob in ca solidity is tricky :)
        updateDepositsNotInVault([amount0, amount1], _user, true);
    }

    function getPosition(
        address _user
    )
        returns (
            address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        )
    {
        (
            address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = poolManager.positions(poolManager[_owner]);
        return (
            token0,
            token1,
            tickSpacing,
            tickLower,
            tickUpper,
            liquidity,
            feeGrowthInside0LastX128,
            feeGrowthInside1LastX128,
            tokensOwed0,
            tokensOwed1
        );
    }

    //follows th shadowswap dex fucntions
    //returns balances for vault a and b for user
    function getPositionBalances(address _user) external returns (uint256[]) {
        (
            address token0,
            address token1,
            int24 tickSpacing,
            int24 tickLower,
            int24 tickUpper,
            uint128 liquidity,
            uint256 feeGrowthInside0LastX128,
            uint256 feeGrowthInside1LastX128,
            uint128 tokensOwed0,
            uint128 tokensOwed1
        ) = getPosition(_user);

        (
            uint160 sqrtPriceX96,
            int24 tick,
            uint16 observationIndex,
            uint16 observationCardinality,
            uint16 observationCardinalityNext,
            uint8 feeProtocol,
            bool unlocked
        ) = pool.slot0();

        Position _position = Position(
            token0,
            token1,
            tickSpacing,
            tickLower,
            tickUpper,
            liquidity,
            feeGrowthInside0LastX128,
            feeGrowthInside1LastX128,
            tokensOwed0,
            tokensOwed1,
            sqrtPriceX96,
            tick,
            observationIndex,
            observationCardinality,
            observationCardinalityNext,
            feeProtocol,
            unlocked
        );
        //set and return too jut in case it doesnt update on time
        uint256[] position = calculatePositions(abi.encode((_position)));

        return position;
    }
}
